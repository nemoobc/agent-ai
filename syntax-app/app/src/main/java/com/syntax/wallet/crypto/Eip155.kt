package com.syntax.wallet.crypto

import java.math.BigInteger

/**
 * Transaksi legacy dengan proteksi replay EIP-155.
 * Format: rlp([nonce, gasPrice, gasLimit, to, value, data, v, r, s]).
 */
object Eip155 {

    class Tx(
        val nonce: BigInteger,
        val gasPrice: BigInteger,
        val gasLimit: BigInteger,
        val to: ByteArray,
        val value: BigInteger,
        val data: ByteArray,
        val chainId: Long
    )

    class Signed(val rawHex: String, val hash: String, val r: BigInteger, val s: BigInteger, val v: BigInteger)

    /** Hash untuk ditandatangani: keccak(rlp([nonce, gasPrice, gasLimit, to, value, data, chainId, 0, 0])). */
    fun signingHash(tx: Tx): ByteArray {
        val encoding = Rlp.encode(
            Rlp.Item.list(
                Rlp.Item.int(tx.nonce),
                Rlp.Item.int(tx.gasPrice),
                Rlp.Item.int(tx.gasLimit),
                Rlp.Item.bytes(tx.to),
                Rlp.Item.int(tx.value),
                Rlp.Item.bytes(tx.data),
                Rlp.Item.int(BigInteger.valueOf(tx.chainId)),
                Rlp.Item.bytes(ByteArray(0)),
                Rlp.Item.bytes(ByteArray(0))
            )
        )
        return Keccak256.digest(encoding)
    }

    /** Tanda tangani; keluarkan transaksi mentah siap kirim (hex "0x…"). */
    fun sign(tx: Tx, privateKey: BigInteger): Signed {
        val sig = Secp256k1.sign(signingHash(tx), privateKey)
        val v = BigInteger.valueOf(tx.chainId * 2 + 35 + sig.recId)
        val encoding = Rlp.encode(
            Rlp.Item.list(
                Rlp.Item.int(tx.nonce),
                Rlp.Item.int(tx.gasPrice),
                Rlp.Item.int(tx.gasLimit),
                Rlp.Item.bytes(tx.to),
                Rlp.Item.int(tx.value),
                Rlp.Item.bytes(tx.data),
                Rlp.Item.int(v),
                Rlp.Item.int(sig.r),
                Rlp.Item.int(sig.s)
            )
        )
        return Signed(
            rawHex = "0x" + Hex.bytesToHex(encoding),
            hash = "0x" + Hex.bytesToHex(Keccak256.digest(encoding)),
            r = sig.r,
            s = sig.s,
            v = v
        )
    }
}
