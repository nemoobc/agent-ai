package com.syntax.wallet

import com.syntax.wallet.crypto.Keccak256
import com.syntax.wallet.crypto.Hex
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Vektor resmi Keccak-256 (dari dokumentasi Keccak/Ethereum).
 */
class Keccak256Test {

    private fun keccak(s: String) = Hex.bytesToHex(Keccak256.digest(s.toByteArray(Charsets.US_ASCII)))

    @Test
    fun `string kosong`() {
        assertEquals(
            "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470",
            keccak("")
        )
    }

    @Test
    fun `abc`() {
        assertEquals(
            "4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45",
            keccak("abc")
        )
    }

    @Test
    fun `testing`() {
        assertEquals(
            "5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02",
            keccak("testing")
        )
    }

    @Test
    fun `panjang melewati batas blok rate 136`() {
        // 135, 136, 137 byte — tidak boleh crash, hasil 32 byte
        for (n in intArrayOf(135, 136, 137, 272)) {
            val out = Keccak256.digest(ByteArray(n) { 0x61 })
            assertEquals(32, out.size)
        }
    }

    @Test
    fun `deterministik`() {
        val a = Keccak256.digest("syntax".toByteArray())
        val b = Keccak256.digest("syntax".toByteArray())
        assertArrayEquals(a, b)
    }
}
