package com.syntax.wallet

import com.syntax.wallet.crypto.Eip55
import com.syntax.wallet.crypto.Eip191
import com.syntax.wallet.crypto.Hex
import com.syntax.wallet.crypto.Secp256k1
import com.syntax.wallet.crypto.WalletCore
import java.math.BigInteger
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * EIP-55 (checksum alamat) + integrasi end-to-end:
 * mnemonic resmi → address Ethereum yang diketahui publik.
 */
class Eip55Test {

    /** Daftar alamat resmi dari spesifikasi EIP-55. */
    private val canonical = listOf(
        "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
        "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
        "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        "0x52908400098527886E0F7030069857D2E4169EE7",
        "0x8617E340B3D01FA5F11F306F4090FD50E238070D"
    )

    @Test
    fun `checksum alamat kanonik`() {
        canonical.forEach { addr ->
            assertEquals(addr, Eip55.checksum(addr))
        }
    }

    @Test
    fun `checksum valid terdeteksi`() {
        canonical.forEach { addr ->
            assertTrue(Eip55.isValidChecksummed(addr))
        }
        assertFalse(Eip55.isValidChecksummed(canonical[0].lowercase()))
    }

    @Test
    fun `address dari mnemonic vektor publik`() {
        // mnemonic uji standar (dipakai luas di dokumentasi wallet)
        val mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        val wallet = WalletCore.fromMnemonic(mnemonic, testWordlist())
        assertEquals("0x9858EfFD232B4033E47d90003D41EC34EcaEda94", wallet.address)
    }

    @Test
    fun `address dari private key vektor eip-155`() {
        // kunci 0x46…46 (dari contoh EIP-155) → address 0x9d8A62f6…
        val wallet = WalletCore.fromPrivateKey("0x" + "46".repeat(32))
        assertEquals("0x9d8A62f656a8d1615C1294fd71e9CFb3E4855A4F", wallet.address)
    }

    @Test
    fun `personal_sign konsisten dengan recovery`() {
        val wallet = WalletCore.fromPrivateKey("0x" + "46".repeat(32))
        val sigHex = wallet.signPersonalMessage("hello syntax")
        val sig = Hex.hexToBytes(sigHex)
        assertEquals(65, sig.size)
        val recovered = Eip191.recover("hello syntax", sig)
        assertArrayEquals(wallet.publicKey, recovered)
    }

    private fun testWordlist(): List<String> =
        javaClass.classLoader!!.getResourceAsStream("bip39-english.txt")!!
            .bufferedReader().readLines().filter { it.isNotBlank() }
}
