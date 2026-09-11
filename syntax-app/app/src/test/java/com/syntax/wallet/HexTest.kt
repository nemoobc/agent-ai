package com.syntax.wallet

import com.syntax.wallet.crypto.Hex
import java.math.BigInteger
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class HexTest {

    @Test
    fun `bytes ke hex dan sebaliknya round-trip`() {
        val bytes = byteArrayOf(0x00, 0x0f, 0x7f.toByte(), 0x80.toByte(), 0xff.toByte())
        val hex = Hex.bytesToHex(bytes)
        assertEquals("000f7f80ff", hex)
        assertArrayEquals(bytes, Hex.hexToBytes(hex))
    }

    @Test
    fun `hexToBytes terima 0x prefix besar dan kecil`() {
        assertArrayEquals(byteArrayOf(0xab.toByte()), Hex.hexToBytes("0xAB"))
        assertArrayEquals(byteArrayOf(0xab.toByte()), Hex.hexToBytes("0xab"))
    }

    @Test(expected = IllegalArgumentException::class)
    fun `panjang ganjil ditolak`() {
        Hex.hexToBytes("abc")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `karakter non-hex ditolak`() {
        Hex.hexToBytes("zz")
    }

    @Test
    fun `intToMinimalBytes buang semua nol depan`() {
        // 128 = 0x80: toByteArray memberi [0x00, 0x80] (sign byte) — harus jadi [0x80]
        assertArrayEquals(byteArrayOf(0x80.toByte()), Hex.intToMinimalBytes(BigInteger.valueOf(128)))
        assertArrayEquals(
            byteArrayOf(0x80.toByte(), 0xff.toByte()),
            Hex.intToMinimalBytes(BigInteger.valueOf(0x80FF))
        )
        assertArrayEquals(byteArrayOf(0x01), Hex.intToMinimalBytes(BigInteger.ONE))
        assertEquals(0, Hex.intToMinimalBytes(BigInteger.ZERO).size)
        // 5 byte dengan top byte kecil: 34.4 gwei → 0x0802665800
        assertArrayEquals(
            byteArrayOf(0x08, 0x02, 0x66, 0x58, 0x00),
            Hex.intToMinimalBytes(BigInteger.valueOf(34_400_000_000L))
        )
    }

    @Test
    fun `toPadded`() {
        assertArrayEquals(
            byteArrayOf(0, 0, 0, 0x0f),
            Hex.toPadded(BigInteger.valueOf(15), 4)
        )
        assertArrayEquals(
            byteArrayOf(0x7f.toByte()),
            Hex.toPadded(BigInteger.valueOf(0x7F), 1)
        )
    }

    @Test
    fun `isValidAddress`() {
        assertTrue(Hex.isValidAddress("0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed"))
        assertTrue(Hex.isValidAddress("0x5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED"))
        assertFalse(Hex.isValidAddress("0x123")) // terlalu pendek
        assertFalse(Hex.isValidAddress("5aaeb6053f3e94c9b9a09f33669435e7ef1beaed")) // tanpa 0x
        assertFalse(Hex.isValidAddress("0xzz")) // non-hex
    }

    @Test
    fun `intToHex`() {
        assertEquals("0x0", Hex.intToHex(BigInteger.ZERO))
        assertEquals("0x10", Hex.intToHex(BigInteger.valueOf(16)))
    }
}
