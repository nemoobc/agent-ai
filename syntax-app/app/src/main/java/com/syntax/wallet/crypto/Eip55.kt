package com.syntax.wallet.crypto

/**
 * EIP-55: alamat dengan checksum kapitalisasi.
 */
object Eip55 {

    /** Terima "0x…" 40-hex (huruf besar/kecil bebas), keluarkan bentuk checksummed. */
    fun checksum(address: String): String {
        val clean = address.trim().removePrefix("0x").removePrefix("0X")
        require(clean.length == 40) { "alamat harus 40 hex" }
        val lower = clean.lowercase()
        val hash = Keccak256.digest(lower.toByteArray(Charsets.US_ASCII))
        val out = StringBuilder("0x")
        for (i in 0 until 40) {
            val c = lower[i]
            if (c in 'a'..'f') {
                val nibble = if (i % 2 == 0) {
                    (hash[i / 2].toInt() ushr 4) and 0xF
                } else {
                    hash[i / 2].toInt() and 0xF
                }
                out.append(if (nibble >= 8) c.uppercaseChar() else c)
            } else {
                out.append(c)
            }
        }
        return out.toString()
    }

    /** Cek apakah alamat sudah berbentuk checksum valid. */
    fun isValidChecksummed(address: String): Boolean =
        Hex.isValidAddress(address) && checksum(address) == address
}
