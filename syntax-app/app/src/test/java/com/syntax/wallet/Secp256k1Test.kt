package com.syntax.wallet

import com.syntax.wallet.crypto.Hex
import com.syntax.wallet.crypto.Secp256k1
import java.math.BigInteger
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * secp256k1: titik generator, tanda tangan EIP-155 (vektor resmi), recovery.
 */
class Secp256k1Test {

    @Test
    fun `privkey 1 adalah titik generator`() {
        val pub = Secp256k1.publicKey(BigInteger.ONE)
        assertEquals(
            "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
            Hex.bytesToHex(pub.copyOfRange(0, 32))
        )
        assertEquals(
            "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8",
            Hex.bytesToHex(pub.copyOfRange(32, 64))
        )
    }

    /**
     * Vektor resmi EIP-155:
     * nonce=9, gasPrice=20gwei, gas=21000, to=0x3535..35, value=1ETH, data kosong, chainId=1
     * private key 0x46…46 → v=37, r/s sesuai EIP.
     */
    @Test
    fun `tanda tangan vektor eip-155`() {
        val priv = BigInteger("46".repeat(32), 16)
        val signingHash = Hex.hexToBytes("daf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53")
        val sig = Secp256k1.sign(signingHash, priv)

        assertEquals(
            BigInteger("18515461264373351373200002665853028612451056578545711640558177340181847433846"),
            sig.r
        )
        assertEquals(
            BigInteger("46948507304638947509940763649030358759909902576025900602547168820602576006531"),
            sig.s
        )
        // v = 37 → recId = 0
        assertEquals(0, sig.recId)
    }

    @Test
    fun `recovery mengembalikan kunci publik penandatangan`() {
        val priv = Secp256k1.generatePrivateKey()
        val pub = Secp256k1.publicKey(priv)
        val hash = Hex.hexToBytes("5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02")
        val sig = Secp256k1.sign(hash, priv)
        val recovered = Secp256k1.recover(hash, sig)
        assertArrayEquals(pub, recovered)
    }

    @Test
    fun `normalisasi low-s`() {
        val priv = Secp256k1.generatePrivateKey()
        val hash = Hex.hexToBytes("c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470")
        val sig = Secp256k1.sign(hash, priv)
        assertTrue(sig.s <= Secp256k1.N.shiftRight(1))
    }

    @Test
    fun `recovery low-s konsisten dengan address derivation`() {
        // pastikan flip low-s tetap dipulihkan ke publik yang sama
        val priv = BigInteger("46".repeat(32), 16)
        val pub = Secp256k1.publicKey(priv)
        val hash = Hex.hexToBytes("daf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53")
        val sig = Secp256k1.sign(hash, priv)
        assertArrayEquals(pub, Secp256k1.recover(hash, sig))
    }
}
