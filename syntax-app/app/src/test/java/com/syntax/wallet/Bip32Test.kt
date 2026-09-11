package com.syntax.wallet

import com.syntax.wallet.crypto.Bip32
import com.syntax.wallet.crypto.Hex
import java.math.BigInteger
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Vektor resmi BIP-32 test vector #1 (seed 000102…0f).
 */
class Bip32Test {

    @Test
    fun `master key vektor 1`() {
        val seed = Hex.hexToBytes("000102030405060708090a0b0c0d0e0f")
        val master = Bip32.master(seed)
        assertEquals(
            "e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35",
            Hex.bytesToHex(Hex.toPadded(master.key, 32))
        )
        assertEquals(
            "873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d508",
            Hex.bytesToHex(master.chainCode)
        )
    }

    @Test
    fun `derivasi m-slash-0-hardened vektor 1`() {
        val seed = Hex.hexToBytes("000102030405060708090a0b0c0d0e0f")
        val node = Bip32.derivePath(seed, "m/0'")
        assertEquals(
            "edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea",
            Hex.bytesToHex(Hex.toPadded(node.key, 32))
        )
        assertEquals(
            "47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141",
            Hex.bytesToHex(node.chainCode)
        )
    }

    @Test
    fun `path ethereum menghasilkan kunci valid`() {
        val seed = Hex.hexToBytes("000102030405060708090a0b0c0d0e0f")
        val node = Bip32.derivePath(seed, Bip32.ethPath())
        val key = node.key
        assertEquals(1, key.signum())
        assert(key < Secp256k1N)
    }

    private val Secp256k1N: BigInteger =
        BigInteger("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16)
}
