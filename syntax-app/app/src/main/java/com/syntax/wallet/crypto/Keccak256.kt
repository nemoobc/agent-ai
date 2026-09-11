package com.syntax.wallet.crypto

import java.lang.Long.rotateLeft

/**
 * Keccak-256 (padding Keccak asli 0x01 — BUKAN SHA3-256 0x06), seperti dipakai Ethereum.
 * Implementasi murni, teruji terhadap vektor resmi di Keccak256Test.
 */
object Keccak256 {

    private const val RATE = 136 // 1088 bit untuk output 256 bit
    private const val ROUNDS = 24

    private val RC = longArrayOf(
        0x0000000000000001L, 0x0000000000008082L, 0x800000000000808AL,
        0x8000000080008000L, 0x000000000000808BL, 0x0000000080000001L,
        0x8000000080008081L, 0x8000000000008009L, 0x000000000000008AL,
        0x0000000000000088L, 0x0000000080008009L, 0x000000008000000AL,
        0x000000008000808BL, 0x800000000000008BL, 0x8000000000008089L,
        0x8000000000008003L, 0x8000000000008002L, 0x8000000000000080L,
        0x000000000000800AL, 0x800000008000000AL, 0x8000000080008081L,
        0x8000000000008080L, 0x0000000080000001L, 0x8000000080008008L
    )

    /** rot[x + 5*y] — offset rotasi rho per lane (tabel standar Keccak). */
    private val ROT = intArrayOf(
        0, 1, 62, 28, 27,
        36, 44, 6, 55, 20,
        3, 10, 43, 25, 39,
        41, 45, 15, 21, 8,
        18, 2, 61, 56, 14
    )

    fun digest(input: ByteArray): ByteArray {
        // padding Keccak: 0x01 ... 0x80 (byte terakhir selalu di-or 0x80)
        val blockCount = input.size / RATE + 1
        val padded = ByteArray(blockCount * RATE)
        input.copyInto(padded, 0)
        padded[input.size] = padded[input.size] xor 0x01
        padded[padded.size - 1] = padded[padded.size - 1] xor 0x80

        val st = LongArray(25)
        for (b in 0 until blockCount) {
            val off = b * RATE
            for (lane in 0 until RATE / 8) {
                var l = 0L
                val base = off + lane * 8
                for (j in 7 downTo 0) {
                    l = (l shl 8) or (padded[base + j].toLong() and 0xFFL)
                }
                st[lane] = st[lane] xor l
            }
            keccakF(st)
        }

        val out = ByteArray(32)
        for (lane in 0 until 4) {
            var l = st[lane]
            for (j in 0 until 8) {
                out[lane * 8 + j] = (l and 0xFFL).toByte()
                l = l ushr 8
            }
        }
        return out
    }

    private fun keccakF(a: LongArray) {
        val b = LongArray(25)
        val c = LongArray(5)
        val d = LongArray(5)
        for (round in 0 until ROUNDS) {
            // theta
            for (x in 0..4) {
                c[x] = a[x] xor a[x + 5] xor a[x + 10] xor a[x + 15] xor a[x + 20]
            }
            for (x in 0..4) {
                d[x] = c[(x + 4) % 5] xor rotateLeft(c[(x + 1) % 5], 1)
            }
            for (y in 0..4) {
                for (x in 0..4) {
                    a[x + 5 * y] = a[x + 5 * y] xor d[x]
                }
            }
            // rho + pi
            for (x in 0..4) {
                for (y in 0..4) {
                    b[y + 5 * ((2 * x + 3 * y) % 5)] = rotateLeft(a[x + 5 * y], ROT[x + 5 * y])
                }
            }
            // chi
            for (y in 0..4) {
                for (x in 0..4) {
                    a[x + 5 * y] = b[x + 5 * y] xor (b[(x + 1) % 5 + 5 * y].inv() and b[(x + 2) % 5 + 5 * y])
                }
            }
            // iota
            a[0] = a[0] xor RC[round]
        }
    }
}
