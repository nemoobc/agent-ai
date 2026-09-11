package com.syntax.wallet.crypto

/**
 * EIP-191 personal_sign: hash pesan dengan prefix "\x19Ethereum Signed Message:\n<len>".
 */
object Eip191 {

    fun messageHash(message: String): ByteArray {
        val msgBytes = message.toByteArray(Charsets.UTF_8)
        val prefix = ("\u0019Ethereum Signed Message:\n" + msgBytes.size).toByteArray(Charsets.US_ASCII)
        val full = ByteArray(prefix.size + msgBytes.size)
        prefix.copyInto(full, 0)
        msgBytes.copyInto(full, prefix.size)
        return Keccak256.digest(full)
    }

    /** Tanda tangan pesan, hasil 65-byte hex "0x…": r(32) || s(32) || v(27+recId). */
    fun sign(message: String, privateKey: java.math.BigInteger): String {
        val sig = Secp256k1.sign(messageHash(message), privateKey)
        val out = ByteArray(65)
        Hex.toPadded(sig.r, 32).copyInto(out, 0)
        Hex.toPadded(sig.s, 32).copyInto(out, 32)
        out[64] = (27 + sig.recId).toByte()
        return "0x" + Hex.bytesToHex(out)
    }

    /** Pulihkan kunci publik 64-byte dari tanda tangan personal_sign. */
    fun recover(message: String, signature65: ByteArray): ByteArray {
        require(signature65.size == 65) { "tanda tangan harus 65 byte" }
        val r = java.math.BigInteger(1, signature65.copyOfRange(0, 32))
        val s = java.math.BigInteger(1, signature65.copyOfRange(32, 64))
        val v = signature65[64].toInt() and 0xFF
        val recId = when (v) {
            27, 28 -> v - 27
            0, 1 -> v
            else -> throw IllegalArgumentException("v tidak valid: $v")
        }
        return Secp256k1.recover(messageHash(message), Secp256k1.Signature(r, s, recId))
    }
}
