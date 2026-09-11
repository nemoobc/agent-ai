package com.syntax.wallet.crypto

import java.math.BigInteger

/**
 * EIP-7702 — delegasi EOA ke kode kontrak.
 *
 * Otorisasi: hash = keccak256(0x05 || rlp([chain_id, address, nonce])), ditandatangani
 * kunci authority (EOA). Tuple otorisasi: rlp([chain_id, address, nonce, y_parity, r, s]).
 *
 * Transaksi type-4:
 *   unsigned: 0x04 || rlp([chain_id, nonce, max_priority_fee, max_fee, gas_limit,
 *                           to, value, data, access_list, authorization_list])
 *   signed:   sama + y_parity, r, s di akhir.
 */
object Eip7702 {

    const val MAGIC: Int = 0x05

    /** Alamat khusus untuk membersihkan delegasi: address nol (spesifikasi FINAL EIP-7702). */
    const val CLEAR_DELEGATION_ADDRESS = "0x0000000000000000000000000000000000000000"

    /** Prefix kode EVM yang menandai EOA terdelegasi: 0xef0100 || address. */
    const val DELEGATION_PREFIX = "0xef0100"

    class Authorization(
        val chainId: Long,
        val address: ByteArray,
        val nonce: BigInteger,
        val yParity: Int,
        val r: BigInteger,
        val s: BigInteger
    ) {
    /** Tuple otorisasi untuk dimasukkan ke authorization_list (r, s = integer minimal). */
    fun toRlpItem(): Rlp.Item = Rlp.Item.list(
            Rlp.Item.int(BigInteger.valueOf(chainId)),
            Rlp.Item.bytes(address),
            Rlp.Item.int(nonce),
            Rlp.Item.int(BigInteger.valueOf(yParity.toLong())),
            Rlp.Item.int(r),
            Rlp.Item.int(s)
        )

        /** Bentuk hex tuple lengkap (untuk ditampilkan/diekspor). */
        fun rawHex(): String = "0x" + Hex.bytesToHex(Rlp.encode(toRlpItem()))
    }

    /** Hash otorisasi: keccak256(0x05 || rlp([chain_id, address, nonce])). */
    fun authorizationHash(chainId: Long, address: ByteArray, nonce: BigInteger): ByteArray {
        require(address.size == 20) { "alamat delegasi harus 20 byte" }
        val payload = Rlp.encode(
            Rlp.Item.list(
                Rlp.Item.int(BigInteger.valueOf(chainId)),
                Rlp.Item.bytes(address),
                Rlp.Item.int(nonce)
            )
        )
        val withMagic = ByteArray(payload.size + 1)
        withMagic[0] = MAGIC.toByte()
        payload.copyInto(withMagic, 1)
        return Keccak256.digest(withMagic)
    }

    /** Tanda tangani otorisasi dengan kunci authority. */
    fun signAuthorization(
        chainId: Long,
        delegateAddress: ByteArray,
        nonce: BigInteger,
        authorityPrivateKey: BigInteger
    ): Authorization {
        val hash = authorizationHash(chainId, delegateAddress, nonce)
        val sig = Secp256k1.sign(hash, authorityPrivateKey)
        return Authorization(chainId, delegateAddress, nonce, sig.recId, sig.r, sig.s)
    }

    /** Verifikasi: pulihkan kunci publik authority dari otorisasi. */
    fun recoverAuthority(auth: Authorization): ByteArray {
        val hash = authorizationHash(auth.chainId, auth.address, auth.nonce)
        return Secp256k1.recover(hash, Secp256k1.Signature(auth.r, auth.s, auth.yParity))
    }

    class Tx(
        val chainId: Long,
        val nonce: BigInteger,
        val maxPriorityFeePerGas: BigInteger,
        val maxFeePerGas: BigInteger,
        val gasLimit: BigInteger,
        val to: ByteArray,
        val value: BigInteger,
        val data: ByteArray,
        val authorizations: List<Authorization>
    ) {
        init {
            require(to.size == 20) { "transaksi 7702 wajib punya 'to' (tidak boleh kontrak-deploy)" }
        }
    }

    private fun unsignedRlp(tx: Tx): ByteArray = Rlp.encode(
        Rlp.Item.list(
            Rlp.Item.int(BigInteger.valueOf(tx.chainId)),
            Rlp.Item.int(tx.nonce),
            Rlp.Item.int(tx.maxPriorityFeePerGas),
            Rlp.Item.int(tx.maxFeePerGas),
            Rlp.Item.int(tx.gasLimit),
            Rlp.Item.bytes(tx.to),
            Rlp.Item.int(tx.value),
            Rlp.Item.bytes(tx.data),
            Rlp.Item.list(), // access_list kosong
            Rlp.Item.List(tx.authorizations.map { it.toRlpItem() })
        )
    )

    fun signingHash(tx: Tx): ByteArray {
        val body = unsignedRlp(tx)
        val withType = ByteArray(body.size + 1)
        withType[0] = 0x04
        body.copyInto(withType, 1)
        return Keccak256.digest(withType)
    }

    class Signed(val rawHex: String, val hash: String, val yParity: Int, val r: BigInteger, val s: BigInteger)

    fun sign(tx: Tx, privateKey: BigInteger): Signed {
        val sig = Secp256k1.sign(signingHash(tx), privateKey)
        val body = Rlp.encode(
            Rlp.Item.list(
                Rlp.Item.int(BigInteger.valueOf(tx.chainId)),
                Rlp.Item.int(tx.nonce),
                Rlp.Item.int(tx.maxPriorityFeePerGas),
                Rlp.Item.int(tx.maxFeePerGas),
                Rlp.Item.int(tx.gasLimit),
                Rlp.Item.bytes(tx.to),
                Rlp.Item.int(tx.value),
                Rlp.Item.bytes(tx.data),
                Rlp.Item.list(), // access_list kosong
                Rlp.Item.List(tx.authorizations.map { it.toRlpItem() }),
                Rlp.Item.int(BigInteger.valueOf(sig.recId.toLong())),
                Rlp.Item.int(sig.r),
                Rlp.Item.int(sig.s)
            )
        )
        val raw = ByteArray(body.size + 1)
        raw[0] = 0x04
        body.copyInto(raw, 1)
        return Signed(
            rawHex = "0x" + Hex.bytesToHex(raw),
            hash = "0x" + Hex.bytesToHex(Keccak256.digest(raw)),
            yParity = sig.recId,
            r = sig.r,
            s = sig.s
        )
    }

    /** Parse kode akun hasil eth_getCode: "0xef0100<addr 20 byte>" = 46 hex → alamat delegasi, null jika tidak. */
    fun parseDelegationCode(code: String): String? {
        val clean = code.trim().removePrefix("0x").removePrefix("0X")
        if (!clean.lowercase().startsWith("ef0100")) return null
        if (clean.length != 46) return null
        return "0x" + clean.substring(6)
    }
}
