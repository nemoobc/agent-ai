package com.syntax.wallet.crypto

import java.math.BigInteger
import java.security.SecureRandom

/**
 * Facade dompet: generate/import mnemonic atau private key -> address EIP-55,
 * tanda tangan pesan, otorisasi 7702.
 */
class WalletCore private constructor(val privateKey: BigInteger) {

    val publicKey: ByteArray = Secp256k1.publicKey(privateKey)
    val address: String = Eip55.checksum(addressHex(publicKey))

    companion object {
        fun fromPrivateKey(hex: String): WalletCore {
            val v = BigInteger(1, Hex.hexToBytes(hex))
            require(v.signum() > 0 && v < Secp256k1.N) { "private key di luar rentang valid" }
            return WalletCore(v)
        }

        fun fromMnemonic(mnemonic: String, wordlist: List<String>): WalletCore {
            require(Bip39.validate(mnemonic, wordlist)) { "mnemonic tidak valid (checksum gagal)" }
            return fromSeed(Bip39.toSeed(mnemonic))
        }

        fun fromSeed(seed: ByteArray): WalletCore {
            val node = Bip32.derivePath(seed, Bip32.ethPath())
            return WalletCore(node.key)
        }

        fun generate(wordlist: List<String>, random: SecureRandom = SecureRandom()): Pair<String, WalletCore> {
            val mnemonic = Bip39.generate(wordlist, random)
            return mnemonic to fromMnemonic(mnemonic, wordlist)
        }

        fun isValidMnemonic(mnemonic: String, wordlist: List<String>): Boolean =
            Bip39.validate(mnemonic, wordlist)

        /** Deteksi bentuk input import: mnemonic valid / private key valid / tidak valid. */
        fun classifyImport(input: String, wordlist: List<String>): ImportKind {
            val t = input.trim()
            if (t.startsWith("0x") && t.length == 66) {
                return try {
                    val v = BigInteger(1, Hex.hexToBytes(t))
                    if (v.signum() > 0 && v < Secp256k1.N) ImportKind.PRIVATE_KEY else ImportKind.INVALID
                } catch (e: Exception) {
                    ImportKind.INVALID
                }
            }
            if (Bip39.validate(t, wordlist)) return ImportKind.MNEMONIC
            return ImportKind.INVALID
        }
    }

    enum class ImportKind { MNEMONIC, PRIVATE_KEY, INVALID }

    /** Alamat dari kunci publik: keccak(X||Y)[12..31]. */
    private fun addressHex(pub: ByteArray): String =
        Hex.bytesToHex(Keccak256.digest(pub).copyOfRange(12, 32))

    fun signPersonalMessage(message: String): String = Eip191.sign(message, privateKey)

    fun signAuthorization(
        chainId: Long,
        delegateAddress: ByteArray,
        nonce: BigInteger
    ): Eip7702.Authorization =
        Eip7702.signAuthorization(chainId, delegateAddress, nonce, privateKey)

    fun shortAddress(): String = address.take(8) + "…" + address.takeLast(6)
}
