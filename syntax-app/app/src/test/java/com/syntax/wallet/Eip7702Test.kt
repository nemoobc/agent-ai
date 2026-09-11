package com.syntax.wallet

import com.syntax.wallet.crypto.Eip155
import com.syntax.wallet.crypto.Eip7702
import com.syntax.wallet.crypto.Hex
import com.syntax.wallet.crypto.Secp256k1
import java.math.BigInteger
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * EIP-7702: struktur otorisasi (magic 0x05 + rlp), konsistensi tanda tangan
 * (sign → recover == authority), dan parsing kode delegasi 0xef0100.
 */
class Eip7702Test {

    private val priv = BigInteger("46".repeat(32), 16)
    private val pub = Secp256k1.publicKey(priv)
    private val delegate = Hex.hexToBytes("757941bf940ecd0f74c57fbb1b1b0b8b9c1e7d20")

    @Test
    fun `hash otorisasi 32 byte dan deterministik`() {
        val h1 = Eip7702.authorizationHash(1L, delegate, BigInteger.TEN)
        val h2 = Eip7702.authorizationHash(1L, delegate, BigInteger.TEN)
        assertEquals(32, h1.size)
        assertArrayEquals(h1, h2)
        // beda nonce → beda hash
        val h3 = Eip7702.authorizationHash(1L, delegate, BigInteger.valueOf(11))
        assertTrue(!h1.contentEquals(h3))
    }

    @Test
    fun `sign authorization lalu recover ke authority`() {
        val auth = Eip7702.signAuthorization(1L, delegate, BigInteger.TEN, priv)
        val recovered = Eip7702.recoverAuthority(auth)
        assertArrayEquals(pub, recovered)
    }

    @Test
    fun `alamat clear delegation sesuai spesifikasi final`() {
        // Spec final EIP-7702: clear delegation = address nol (bukan 0x…dEaD dari draft lama)
        assertEquals("0x0000000000000000000000000000000000000000", Eip7702.CLEAR_DELEGATION_ADDRESS)
        val auth = Eip7702.signAuthorization(
            1L, Hex.hexToBytes("0000000000000000000000000000000000000000"),
            BigInteger.ZERO, priv
        )
        assertArrayEquals(pub, Eip7702.recoverAuthority(auth))
    }

    @Test
    fun `transaksi type-4 bentuk tanda tangan valid`() {
        val auth = Eip7702.signAuthorization(1L, delegate, BigInteger.ZERO, priv)
        val tx = Eip7702.Tx(
            chainId = 1L,
            nonce = BigInteger.ZERO,
            maxPriorityFeePerGas = BigInteger.valueOf(1_500_000_000),
            maxFeePerGas = BigInteger.valueOf(30_000_000_000),
            gasLimit = BigInteger.valueOf(100_000),
            to = Hex.hexToBytes("9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f"),
            value = BigInteger.ZERO,
            data = ByteArray(0),
            authorizations = listOf(auth)
        )
        val signed = Eip7702.sign(tx, priv)
        // prefix type-4
        assertTrue(signed.rawHex.startsWith("0x04"))
        // hash dihitung dari raw
        assertEquals(66, signed.hash.length)
        // verifikasi: hash signing bisa dipulihkan ke penandatangan
        val signingHash = Eip7702.signingHash(tx)
        val sig = Secp256k1.Signature(signed.r, signed.s, signed.yParity)
        assertArrayEquals(pub, Secp256k1.recover(signingHash, sig))
    }

    @Test
    fun `parse kode delegasi 0xef0100 (46 hex)`() {
        assertEquals(
            "0x757941bf940ecd0f74c57fbb1b1b0b8b9c1e7d20",
            Eip7702.parseDelegationCode("0xef0100757941bf940ecd0f74c57fbb1b1b0b8b9c1e7d20")
        )
        assertNull(Eip7702.parseDelegationCode("0x"))
        assertNull(Eip7702.parseDelegationCode("0x60806040"))
        // prefix cocok tapi panjang salah (66 hex — alamat 30 byte) → null
        assertNull(
            Eip7702.parseDelegationCode(
                "0xef0100" + "757941bf940ecd0f74c57fbb1b1b0b8b9c1e7d20" + "757941bf940ecd0f74c57fbb1b1b0b8b9c1e7d20"
            )
        )
    }

    @Test
    fun `transaksi 7702 wajib punya to`() {
        val auth = Eip7702.signAuthorization(1L, delegate, BigInteger.ZERO, priv)
        val boom = runCatching {
            Eip7702.Tx(
                chainId = 1L,
                nonce = BigInteger.ZERO,
                maxPriorityFeePerGas = BigInteger.ONE,
                maxFeePerGas = BigInteger.ONE,
                gasLimit = BigInteger.valueOf(50_000),
                to = ByteArray(0),
                value = BigInteger.ZERO,
                data = ByteArray(0),
                authorizations = listOf(auth)
            )
        }
        assertTrue(boom.isFailure)
    }

    @Test
    fun `transaksi legacy eip155 vektor resmi`() {
        // nonce=9 gasprice=20gwei gas=21000 to=0x35..35 value=1e18 chainId=1
        val tx = Eip155.Tx(
            nonce = BigInteger.valueOf(9),
            gasPrice = BigInteger.valueOf(20_000_000_000L),
            gasLimit = BigInteger.valueOf(21_000),
            to = Hex.hexToBytes("3535353535353535353535353535353535353535"),
            value = BigInteger.TEN.pow(18),
            data = ByteArray(0),
            chainId = 1L
        )
        val signed = Eip155.sign(tx, priv)
        assertEquals(BigInteger.valueOf(37), signed.v)
        assertEquals(
            BigInteger("18515461264373351373200002665853028612451056578545711640558177340181847433846"),
            signed.r
        )
        assertEquals(
            BigInteger("46948507304638947509940763649030358759909902576025900602547168820602576006531"),
            signed.s
        )
        assertNotNull(signed.rawHex)
        assertTrue(signed.rawHex.startsWith("0xf8"))
    }
}
