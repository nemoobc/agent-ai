package com.syntax.wallet

import com.syntax.wallet.crypto.Bip39
import com.syntax.wallet.crypto.Hex
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Vektor resmi BIP-39 (trezor test vectors).
 */
class Bip39Test {

    private val wordlist: List<String> =
        javaClass.classLoader!!.getResourceAsStream("bip39-english.txt")!!
            .bufferedReader().readLines().filter { it.isNotBlank() }

    @Test
    fun `wordlist resmi 2048 kata terurut unik`() {
        assertEquals(2048, wordlist.size)
        assertEquals(2048, wordlist.toSet().size)
        assertEquals(wordlist, wordlist.sorted())
    }

    @Test
    fun `seed vektor resmi abandon-about`() {
        val mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        val seed = Bip39.toSeed(mnemonic)
        assertEquals(
            "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4",
            Hex.bytesToHex(seed)
        )
    }

    @Test
    fun `validasi mnemonic benar`() {
        val mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        assertTrue(Bip39.validate(mnemonic, wordlist))
    }

    @Test
    fun `validasi mnemonic salah checksum`() {
        // kata terakhir diganti → checksum tidak cocok
        val bad = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon zoo"
        assertFalse(Bip39.validate(bad, wordlist))
    }

    @Test
    fun `validasi kata tak dikenal`() {
        assertFalse(Bip39.validate("abandon ability able about above absent absurd banana zebra zoo", wordlist))
    }

    @Test
    fun `validasi jumlah kata salah`() {
        assertFalse(Bip39.validate("abandon abandon abandon", wordlist))
    }

    @Test
    fun `generate selalu valid 12 kata`() {
        repeat(8) {
            val m = Bip39.generate(wordlist)
            assertEquals(12, m.split(" ").size)
            assertTrue(Bip39.validate(m, wordlist))
        }
    }

    @Test
    fun `normalisasi spasi ganda`() {
        assertTrue(Bip39.validate(
            "abandon  abandon   abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
            wordlist
        ))
    }
}
