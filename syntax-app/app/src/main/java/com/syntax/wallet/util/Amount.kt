package com.syntax.wallet.util

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode

/** Konversi ETH <-> wei. */
object Amount {

    private val WEI_PER_ETH: BigInteger = BigInteger.TEN.pow(18)

    /** "1.5" -> 1500000000000000000 wei. Null jika tidak valid. */
    fun parseEther(s: String): BigInteger? {
        val t = s.trim()
        if (t.isEmpty()) return null
        if (!t.matches(Regex("\\d+(\\.\\d+)?"))) return null
        val parts = t.split(".")
        val whole = parts[0]
        val frac = if (parts.size == 2) parts[1] else ""
        if (frac.length > 18) return null
        val fracPadded = frac.padEnd(18, '0')
        return try {
            BigInteger(whole).multiply(WEI_PER_ETH) + BigInteger(fracPadded)
        } catch (e: NumberFormatException) {
            null
        }
    }

    /** wei -> "1.2345" (nol di belakang dipangkas). */
    fun formatWei(wei: BigInteger): String {
        val whole = wei.divide(WEI_PER_ETH)
        val frac = wei.mod(WEI_PER_ETH).toString().padStart(18, '0').trimEnd('0')
        return if (frac.isEmpty()) whole.toString() else "$whole.$frac"
    }

    /** Estimasi biaya gas dalam ETH (6 desimal). */
    fun formatFee(gas: BigInteger, price: BigInteger): String {
        val wei = gas.multiply(price)
        return BigDecimal(wei).divide(BigDecimal(WEI_PER_ETH), 6, RoundingMode.HALF_UP).toPlainString()
    }

    fun shortAddress(address: String): String =
        address.take(8) + "…" + address.takeLast(6)
}
