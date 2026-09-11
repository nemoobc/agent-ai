package com.syntax.wallet.crypto

import java.math.BigInteger

/** Utilitas hex — satu sumber kebenaran konversi. */
object Hex {

    private val HEX = "0123456789abcdef".toCharArray()

    fun bytesToHex(bytes: ByteArray): String {
        val out = CharArray(bytes.size * 2)
        for (i in bytes.indices) {
            val v = bytes[i].toInt() and 0xFF
            out[i * 2] = HEX[v ushr 4]
            out[i * 2 + 1] = HEX[v and 0x0F]
        }
        return String(out)
    }

    fun hexToBytes(hex: String): ByteArray {
        var h = hex.trim()
        if (h.startsWith("0x") || h.startsWith("0X")) h = h.substring(2)
        require(h.length % 2 == 0) { "panjang hex ganjil" }
        require(h.all { it.isDigit() || it.lowercaseChar() in 'a'..'f' }) { "karakter hex tidak valid" }
        val out = ByteArray(h.length / 2)
        for (i in out.indices) {
            out[i] = ((nibble(h[i * 2]) shl 4) or nibble(h[i * 2 + 1])).toByte()
        }
        return out
    }

    private fun nibble(c: Char): Int = when (c) {
        in '0'..'9' -> c - '0'
        in 'a'..'f' -> c - 'a' + 10
        in 'A'..'F' -> c - 'A' + 10
        else -> throw IllegalArgumentException("bukan hex: $c")
    }

    /** BigInteger ke hex "0x…" tanpa nol depan (untuk JSON-RPC). */
    fun intToHex(v: BigInteger): String = "0x" + v.toString(16)

    /** BigInteger ke string hex genap (tanpa prefix), mis. untuk RLP. */
    fun intToMinimalBytes(v: BigInteger): ByteArray {
        if (v.signum() == 0) return ByteArray(0)
        var out = v.toByteArray()
        // buang SEMUA zero-byte depan (termasuk sign byte 0x00)
        var i = 0
        while (i < out.size - 1 && out[i].toInt() == 0) i++
        if (i > 0) out = out.copyOfRange(i, out.size)
        return out
    }

    fun toPadded(v: BigInteger, len: Int): ByteArray {
        val out = ByteArray(len)
        val src = v.toByteArray()
        if (src.size > len) {
            // ambil len byte terakhir (asumsi zero-padding depan)
            src.copyOfRange(src.size - len, src.size).copyInto(out, 0)
        } else {
            src.copyInto(out, len - src.size)
        }
        return out
    }

    fun isValidAddress(s: String): Boolean {
        val t = s.trim()
        if (!t.startsWith("0x")) return false
        val body = t.substring(2)
        if (body.length != 40) return false
        return body.all { it in '0'..'9' || it in 'a'..'f' || it in 'A'..'F' }
    }

    fun addressBytesToHex(a: ByteArray): String = "0x" + bytesToHex(a)
}
