package com.syntax.wallet.crypto

import java.math.BigInteger

/**
 * RLP (Recursive Length Prefix) — encoder saja (decoder tidak dibutuhkan).
 * Sesuai spesifikasi Ethereum, teruji terhadap vektor resmi di RlpTest.
 */
object Rlp {

    sealed class Item {
        data class Bytes(val data: ByteArray) : Item() {
            override fun equals(other: Any?): Boolean =
                other is Bytes && data.contentEquals(other.data)
            override fun hashCode(): Int = data.contentHashCode()
        }
        data class Int(val value: BigInteger) : Item()
        data class List(val items: kotlin.collections.List<Item>) : Item()

        companion object {
            fun bytes(data: ByteArray): Item = Bytes(data)
            fun int(v: Long): Item = Int(BigInteger.valueOf(v))
            fun int(v: BigInteger): Item = Int(v)
            fun list(vararg items: Item): Item = List(items.toList())
        }
    }

    fun encode(item: Item): ByteArray {
        val sb = StringBuilder()
        encodeTo(item, sb)
        return hexToBytes(sb.toString())
    }

    private fun hexToBytes(h: String): ByteArray {
        val out = ByteArray(h.length / 2)
        for (i in out.indices) {
            out[i] = ((Character.digit(h[i * 2], 16) shl 4) or Character.digit(h[i * 2 + 1], 16)).toByte()
        }
        return out
    }

    private fun hexOf(b: ByteArray): String = Hex.bytesToHex(b)

    private fun encodeTo(item: Item, out: StringBuilder) {
        when (item) {
            is Item.Int -> {
                val v = item.value
                require(v.signum() >= 0) { "RLP int harus >= 0" }
                encodeTo(Item.Bytes(Hex.intToMinimalBytes(v)), out)
            }
            is Item.Bytes -> {
                val data = item.data
                if (data.size == 1 && data[0].toInt() in 0..0x7F) {
                    out.append(hexOf(data))
                } else {
                    out.append(lengthPrefix(0x80, data.size))
                    out.append(hexOf(data))
                }
            }
            is Item.List -> {
                val payload = StringBuilder()
                for (child in item.items) encodeTo(child, payload)
                val payloadHex = payload.toString()
                val payloadLen = payloadHex.length / 2
                out.append(lengthPrefix(0xC0, payloadLen))
                out.append(payloadHex)
            }
        }
    }

    private fun lengthPrefix(offset: Int, length: Int): String {
        return if (length <= 55) {
            byteToHex((offset + length).toByte())
        } else {
            val lenBytes = Hex.intToMinimalBytes(BigInteger.valueOf(length.toLong()))
            byteToHex((offset + 55 + lenBytes.size).toByte()) + Hex.bytesToHex(lenBytes)
        }
    }

    private fun byteToHex(b: Byte): String {
        val v = b.toInt() and 0xFF
        val digits = "0123456789abcdef"
        return "" + digits[v ushr 4] + digits[v and 0x0F]
    }
}
