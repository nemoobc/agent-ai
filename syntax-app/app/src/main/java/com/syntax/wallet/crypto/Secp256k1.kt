package com.syntax.wallet.crypto

import java.math.BigInteger
import java.security.SecureRandom
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Kurva eliptik secp256k1: aritmetika titik, tanda tangan ECDSA deterministik (RFC 6979),
 * pemulihan kunci publik (recovery) — murni BigInteger, tanpa dependensi eksternal.
 */
object Secp256k1 {

    val P: BigInteger = BigInteger("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", 16)
    val N: BigInteger = BigInteger("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16)
    private val HALF_N: BigInteger = N.shiftRight(1)
    private val GX: BigInteger = BigInteger("79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", 16)
    private val GY: BigInteger = BigInteger("483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8", 16)
    private val SEVEN: BigInteger = BigInteger.valueOf(7)

    class Point internal constructor(val x: BigInteger?, val y: BigInteger?) {
        val isInfinity: Boolean get() = x == null || y == null

        companion object {
            val INFINITY = Point(null, null)
        }
    }

    data class Signature(val r: BigInteger, val s: BigInteger, val recId: Int)

    private fun add(p1: Point, p2: Point): Point {
        if (p1.isInfinity) return p2
        if (p2.isInfinity) return p1
        val x1 = p1.x!!; val y1 = p1.y!!; val x2 = p2.x!!; val y2 = p2.y!!
        if (x1 == x2) {
            return if (y1 == y2) double(p1) else Point.INFINITY
        }
        val lam = (y2 - y1).multiply((x2 - x1).modInverse(P)).mod(P)
        val x3 = lam.multiply(lam).subtract(x1).subtract(x2).mod(P)
        val y3 = lam.multiply(x1 - x3).subtract(y1).mod(P)
        return Point(x3, y3)
    }

    private fun double(p: Point): Point {
        if (p.isInfinity || p.y!!.signum() == 0) return Point.INFINITY
        val x = p.x!!; val y = p.y!!
        val lam = x.multiply(x).multiply(BigInteger.valueOf(3)).multiply(y.add(y).modInverse(P)).mod(P)
        val x3 = lam.multiply(lam).subtract(x).subtract(x).mod(P)
        val y3 = lam.multiply(x - x3).subtract(y).mod(P)
        return Point(x3, y3)
    }

    private fun mul(k: BigInteger, p: Point): Point {
        var result = Point.INFINITY
        var addend = p
        var n = k
        while (n.signum() > 0) {
            if (n.testBit(0)) result = add(result, addend)
            addend = double(addend)
            n = n.shiftRight(1)
        }
        return result
    }

    /** Kunci publik 64-byte tidak terkompresi: X || Y. */
    fun publicKey(privateKey: BigInteger): ByteArray {
        require(privateKey.signum() > 0 && privateKey < N) { "private key di luar rentang 1..n-1" }
        val pub = mul(privateKey, Point(GX, GY))
        val out = ByteArray(64)
        Hex.toPadded(pub.x!!, 32).copyInto(out, 0)
        Hex.toPadded(pub.y!!, 32).copyInto(out, 32)
        return out
    }

    fun generatePrivateKey(random: SecureRandom = SecureRandom()): BigInteger {
        while (true) {
            val bytes = ByteArray(32)
            random.nextBytes(bytes)
            val k = BigInteger(1, bytes)
            if (k.signum() > 0 && k < N) return k
        }
    }

    /** k deterministik per RFC 6979 (SHA-256). */
    private fun rfc6979(priv: BigInteger, hash: ByteArray): Iterator<BigInteger> {
        val x = Hex.toPadded(priv, 32)
        var v = ByteArray(32) { 0x01 }
        var k = ByteArray(32)
        fun hmac(key: ByteArray, data: ByteArray): ByteArray {
            val mac = Mac.getInstance("HmacSHA256")
            mac.init(SecretKeySpec(key, "HmacSHA256"))
            return mac.doFinal(data)
        }
        fun concat(vararg arr: ByteArray): ByteArray {
            val out = ByteArray(arr.sumOf { it.size })
            var i = 0
            for (a in arr) { a.copyInto(out, i); i += a.size }
            return out
        }
        k = hmac(k, concat(v, byteArrayOf(0x00), x, hash))
        v = hmac(k, v)
        k = hmac(k, concat(v, byteArrayOf(0x01), x, hash))
        v = hmac(k, v)
        return object : Iterator<BigInteger> {
            override fun hasNext() = true
            override fun next(): BigInteger {
                while (true) {
                    v = hmac(k, v)
                    val candidate = BigInteger(1, v)
                    if (candidate.signum() > 0 && candidate < N) return candidate
                    k = hmac(k, concat(v, byteArrayOf(0x00)))
                    v = hmac(k, v)
                }
            }
        }
    }

    /**
     * Tanda tangan ECDSA deterministik dengan normalisasi low-s
     * (wajib untuk transaksi Ethereum).
     */
    fun sign(hash: ByteArray, privateKey: BigInteger): Signature {
        require(hash.size == 32) { "hash harus 32 byte" }
        val z = BigInteger(1, hash)
        val ks = rfc6979(privateKey, hash)
        while (true) {
            val k = ks.next()
            val rp = mul(k, Point(GX, GY))
            if (rp.isInfinity) continue
            val rx = rp.x!!
            val r = rx.mod(N)
            if (r.signum() == 0) continue
            var s = k.modInverse(N).multiply(z.add(r.multiply(privateKey))).mod(N)
            if (s.signum() == 0) continue
            var recId = if (rp.y!!.testBit(0)) 1 else 0
            if (rx >= N) recId = recId or 2
            if (s > HALF_N) {
                s = N.subtract(s)
                recId = recId xor 1
            }
            return Signature(r, s, recId)
        }
    }

    /** Pulihkan kunci publik 64-byte dari hash + tanda tangan. */
    fun recover(hash: ByteArray, sig: Signature): ByteArray {
        require(hash.size == 32) { "hash harus 32 byte" }
        require(sig.recId in 0..3) { "recId tidak valid" }
        val nS = sig.s
        val nR = sig.r
        require(nR.signum() > 0 && nR < N && nS.signum() > 0 && nS < N) { "komponen tanda tangan tidak valid" }

        var x = nR
        if (sig.recId >= 2) x = x.add(N)
        require(x < P) { "x di luar kurva" }

        // y^2 = x^3 + 7 (mod P)
        val ySq = x.multiply(x).multiply(x).add(SEVEN).mod(P)
        var y = ySq.modPow(P.add(BigInteger.ONE).shiftRight(2), P)
        // akar kuadrat mungkin tidak ada; cek
        require(y.multiply(y).mod(P) == ySq) { "titik tidak di kurva" }
        val yOdd = y.testBit(0)
        val wantOdd = (sig.recId and 1) == 1
        if (yOdd != wantOdd) y = P.subtract(y)

        val rPoint = Point(x, y)
        val z = BigInteger(1, hash)
        val rInv = nR.modInverse(N)
        // Q = r^-1 (s*R - z*G) = (s*r^-1) R + (z*r^-1)(-G)
        val q1 = mul(nS.multiply(rInv).mod(N), rPoint)
        val gNeg = Point(GX, P.subtract(GY))
        val q2 = mul(z.multiply(rInv).mod(N), gNeg)
        val q = add(q1, q2)
        require(!q.isInfinity) { "titik tak hingga saat recover" }
        val out = ByteArray(64)
        Hex.toPadded(q.x!!, 32).copyInto(out, 0)
        Hex.toPadded(q.y!!, 32).copyInto(out, 32)
        return out
    }
}
