package com.syntax.wallet.crypto

import java.math.BigInteger
import java.security.MessageDigest
import java.security.SecureRandom
import java.text.Normalizer
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec

/**
 * BIP-39: mnemonic -> seed (PBKDF2-HMAC-SHA512, 2048 iterasi) + validasi checksum.
 * Wordlist disuntik sebagai parameter supaya murni (bisa dites JVM tanpa Android).
 */
object Bip39 {

    fun normalize(mnemonic: String): String =
        Normalizer.normalize(mnemonic.trim(), Normalizer.Form.NFKD)
            .split(Regex("\\s+"))
            .joinToString(" ")

    /** Entropi 128-bit -> 12 kata. */
    fun generate(wordlist: List<String>, random: SecureRandom = SecureRandom()): String {
        require(wordlist.size == 2048) { "wordlist harus 2048 kata" }
        val entropy = ByteArray(16)
        random.nextBytes(entropy)
        return toMnemonic(entropy, wordlist)
    }

    fun toMnemonic(entropy: ByteArray, wordlist: List<String>): String {
        require(wordlist.size == 2048) { "wordlist harus 2048 kata" }
        require(entropy.size in intArrayOf(16, 20, 24, 28, 32)) {
            "entropi harus 16/20/24/28/32 byte (128/160/192/224/256 bit)"
        }
        val checksum = MessageDigest.getInstance("SHA-256").digest(entropy)
        // gabung entropy + checksum (bit pertama SHA-256: entBits/32 bit)
        val csBits = entropy.size * 8 / 32
        val bits = ArrayList<Boolean>(entropy.size * 8 + csBits)
        for (b in entropy) {
            for (i in 7 downTo 0) bits.add((b.toInt() shr i) and 1 == 1)
        }
        for (i in 7 downTo 8 - csBits) bits.add((checksum[0].toInt() shr i) and 1 == 1)
        val words = mutableListOf<String>()
        for (chunk in bits.chunked(11)) {
            var idx = 0
            for (bit in chunk) idx = (idx shl 1) or (if (bit) 1 else 0)
            words.add(wordlist[idx])
        }
        return words.joinToString(" ")
    }

    /** Validasi: jumlah kata 12/24, semua ada di wordlist, checksum cocok. */
    fun validate(mnemonic: String, wordlist: List<String>): Boolean {
        if (wordlist.size != 2048) return false
        val words = normalize(mnemonic).split(" ")
        if (words.size != 12 && words.size != 24) return false
        val index = HashMap<String, Int>(2048)
        wordlist.forEachIndexed { i, w -> index[w] = i }
        val indices = mutableListOf<Int>()
        for (w in words) {
            val i = index[w] ?: return false
            indices.add(i)
        }
        val entBits = words.size * 11 - words.size * 11 / 33
        val csBits = words.size * 11 / 33
        val allBits = mutableListOf<Int>()
        for (i in indices) {
            for (b in 10 downTo 0) allBits.add((i shr b) and 1)
        }
        val entropyBits = allBits.subList(0, entBits)
        val checksumBits = allBits.subList(entBits, entBits + csBits)
        val entropy = ByteArray(entBits / 8)
        for (i in entropy.indices) {
            var b = 0
            for (j in 0 until 8) b = (b shl 1) or entropyBits[i * 8 + j]
            entropy[i] = b.toByte()
        }
        var expected = 0
        for (j in 0 until csBits) expected = (expected shl 1) or checksumBits[j]
        val hash = MessageDigest.getInstance("SHA-256").digest(entropy)
        // ambil csBits pertama dari hash
        val actual = (hash[0].toInt() and 0xFF) shr (8 - csBits)
        return expected == actual
    }

    /** Mnemonic -> seed 64-byte. */
    fun toSeed(mnemonic: String, passphrase: String = ""): ByteArray {
        val norm = normalize(mnemonic)
        val salt = "mnemonic" + passphrase
        val spec = PBEKeySpec(
            norm.toCharArray(),
            salt.toByteArray(Charsets.UTF_8),
            2048,
            512
        )
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512")
        return factory.generateSecret(spec).encoded
    }

    fun wordIndex(word: String, wordlist: List<String>): Int? = wordlist.indexOf(word).takeIf { it >= 0 }

    fun toBigIntegerSeed(seed: ByteArray): BigInteger = BigInteger(1, seed)
}
