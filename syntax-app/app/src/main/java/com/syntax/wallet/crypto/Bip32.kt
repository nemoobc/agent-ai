package com.syntax.wallet.crypto

import java.math.BigInteger
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * BIP-32 (derivasi HD): master key dari seed BIP-39 + derivasi path m/44'/60'/0'/0/0.
 */
object Bip32 {

    private const val HARDENED_OFFSET = 0x80000000L

    class ExtendedKey(val key: BigInteger, val chainCode: ByteArray) {
        fun publicKey(): ByteArray = Secp256k1.publicKey(key)
    }

    fun master(seed: ByteArray): ExtendedKey {
        val mac = Mac.getInstance("HmacSHA512")
        mac.init(SecretKeySpec("Bitcoin seed".toByteArray(Charsets.UTF_8), "HmacSHA512"))
        val i = mac.doFinal(seed)
        return ExtendedKey(BigInteger(1, i.copyOfRange(0, 32)), i.copyOfRange(32, 64))
    }

    fun deriveChild(parent: ExtendedKey, index: Long): ExtendedKey {
        val hardened = index >= HARDENED_OFFSET
        val indexBytes = ByteArray(4)
        for (i in 0 until 4) {
            indexBytes[3 - i] = ((index ushr (8 * i)) and 0xFF).toByte()
        }
        // 0x00||key32||idx4 (hardened) = 37 byte; pub33||idx4 (normal) = 37 byte
        val data = ByteArray(37)
        if (hardened) {
            data[0] = 0x00
            Hex.toPadded(parent.key, 32).copyInto(data, 1)
        } else {
            // kunci publik terkompresi 33-byte (0x02/0x03 || X)
            val pub = parent.publicKey()
            val prefix = if (pub[63].toInt() and 0x01 == 1) 0x03 else 0x02
            data[0] = prefix.toByte()
            pub.copyOfRange(0, 32).copyInto(data, 1)
        }
        indexBytes.copyInto(data, data.size - 4)

        val mac = Mac.getInstance("HmacSHA512")
        mac.init(SecretKeySpec(parent.chainCode, "HmacSHA512"))
        val i = mac.doFinal(data)
        val il = BigInteger(1, i.copyOfRange(0, 32))
        val child = il.add(parent.key).mod(Secp256k1.N)
        require(child.signum() != 0) { "derivasi menghasilkan kunci nol (sangat jarang), coba index lain" }
        return ExtendedKey(child, i.copyOfRange(32, 64))
    }

    /** Derivasi path "m/44'/60'/0'/0/0" (apostrof = hardened). */
    fun derivePath(seed: ByteArray, path: String): ExtendedKey {
        require(path.startsWith("m/")) { "path harus diawali m/" }
        var node = master(seed)
        for (part in path.removePrefix("m/").split("/")) {
            if (part.isEmpty()) continue
            val hardened = part.endsWith("'") || part.endsWith("h")
            val num = part.trimEnd('\'', 'h').toLong()
            require(num in 0 until HARDENED_OFFSET) { "index tidak valid: $part" }
            val index = if (hardened) num + HARDENED_OFFSET else num
            node = deriveChild(node, index)
        }
        return node
    }

    fun ethPath(): String = "m/44'/60'/0'/0/0"
}
