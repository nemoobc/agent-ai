package com.syntax.wallet

import com.syntax.wallet.crypto.Hex
import com.syntax.wallet.crypto.Rlp
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Vektor resmi RLP (dari wiki Ethereum / EIP-155).
 */
class RlpTest {

    private fun hex(b: ByteArray) = Hex.bytesToHex(b)

    @Test
    fun `string dog`() {
        assertEquals("83646f67", hex(Rlp.encode(Rlp.Item.bytes("dog".toByteArray()))))
    }

    @Test
    fun `string kosong`() {
        assertEquals("80", hex(Rlp.encode(Rlp.Item.bytes(ByteArray(0)))))
    }

    @Test
    fun `list kosong`() {
        assertEquals("c0", hex(Rlp.encode(Rlp.Item.list())))
    }

    @Test
    fun `list dua list kosong`() {
        assertEquals("c2c0c0", hex(Rlp.encode(Rlp.Item.list(Rlp.Item.list(), Rlp.Item.list()))))
    }

    @Test
    fun `list cat dog`() {
        assertEquals(
            "c88363617483646f67",
            hex(Rlp.encode(Rlp.Item.list(
                Rlp.Item.bytes("cat".toByteArray()),
                Rlp.Item.bytes("dog".toByteArray())
            )))
        )
    }

    @Test
    fun `integer`() {
        assertEquals("80", hex(Rlp.encode(Rlp.Item.int(0))))
        assertEquals("0f", hex(Rlp.encode(Rlp.Item.int(15))))
        assertEquals("820400", hex(Rlp.encode(Rlp.Item.int(1024))))
    }

    @Test
    fun `integer boundary 127 128 255 256 — minimal tanpa nol depan`() {
        assertEquals("7f", hex(Rlp.encode(Rlp.Item.int(127))))
        assertEquals("8180", hex(Rlp.encode(Rlp.Item.int(128))))
        assertEquals("81ff", hex(Rlp.encode(Rlp.Item.int(255))))
        assertEquals("820100", hex(Rlp.encode(Rlp.Item.int(256))))
        // gas price >= ~34.4 gwei: magnitude 5 byte, top byte 0x08 — regresi bug sign-byte
        assertEquals(
            "850802665800",
            hex(Rlp.encode(Rlp.Item.int(34_400_000_000L)))
        )
        // sanity: nilai EIP-155 (20 gwei) tidak berubah
        assertEquals(
            "8504a817c800",
            hex(Rlp.encode(Rlp.Item.int(20_000_000_000L)))
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun `integer negatif ditolak`() {
        Rlp.encode(Rlp.Item.int(BigInteger.valueOf(-1)))
    }

    @Test
    fun `string panjang`() {
        assertEquals(
            "b8384c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c6974",
            hex(Rlp.encode(Rlp.Item.bytes(
                "Lorem ipsum dolor sit amet, consectetur adipisicing elit".toByteArray()
            )))
        )
    }
}
