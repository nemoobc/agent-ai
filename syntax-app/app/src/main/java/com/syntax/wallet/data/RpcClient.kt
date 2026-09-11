package com.syntax.wallet.data

import java.io.BufferedReader
import java.io.InputStreamReader
import java.math.BigInteger
import java.net.HttpURLConnection
import java.net.URL

/**
 * Klien JSON-RPC Ethereum via HttpURLConnection (murni, tanpa OkHttp).
 */
class RpcException(message: String) : Exception(message)

class RpcClient(var url: String, var timeoutMs: Int = 12_000) {

    fun chainId(): BigInteger = hexToBig(call("eth_chainId"))

    fun balance(address: String): BigInteger = hexToBig(call("eth_getBalance", q(address), q("latest")))

    fun transactionCount(address: String): BigInteger = hexToBig(call("eth_getTransactionCount", q(address), q("pending")))

    fun code(address: String): String = call("eth_getCode", q(address), q("latest")) ?: "0x"

    fun gasPrice(): BigInteger = hexToBig(call("eth_gasPrice"))

    fun estimateGas(from: String, to: String, value: BigInteger, gasPrice: BigInteger): BigInteger =
        hexToBig(
            call(
                "eth_estimateGas",
                "{\"from\":" + q(from) + ",\"to\":" + q(to) +
                    ",\"value\":\"" + "0x" + value.toString(16) + "\"" +
                    ",\"gasPrice\":\"" + "0x" + gasPrice.toString(16) + "\"}"
            )
        )

    fun sendRawTransaction(rawHex: String): String = call("eth_sendRawTransaction", q(rawHex))
        ?: throw RpcException("rpc tidak mengembalikan hash transaksi")

    private fun q(s: String): String = "\"" + s
        .replace("\\", "\\\\")
        .replace("\"", "\\\"") + "\""

    private fun hexToBig(hex: String?): BigInteger {
        val h = hex ?: throw RpcException("rpc mengembalikan null")
        val body = h.removePrefix("0x").removePrefix("0X")
        if (body.isEmpty()) return BigInteger.ZERO
        return BigInteger(body, 16)
    }

    private fun call(method: String, vararg params: String): String? {
        val body = buildString {
            append("{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"")
            append(method)
            append("\",\"params\":[")
            append(params.joinToString(","))
            append("]}")
        }
        var conn: HttpURLConnection? = null
        try {
            conn = (URL(url).openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                connectTimeout = timeoutMs
                readTimeout = timeoutMs
                doOutput = true
                setRequestProperty("Content-Type", "application/json")
                setRequestProperty("User-Agent", "SyntaxWallet/1.0")
            }
            conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }

            val status = conn.responseCode
            val stream = if (status in 200..299) conn.inputStream else conn.errorStream
            val text = stream?.let { readCapped(it) }
                ?: throw RpcException("rpc kosong (HTTP $status)")

            val parsed = Json.parse(text)
            val obj = Json.obj(parsed)
            (obj["error"] as? Map<*, *>)?.let { err ->
                val msg = (err["message"] as? String) ?: err.toString()
                throw RpcException(msg)
            }
            return Json.str(obj["result"])
        } catch (e: RpcException) {
            throw e
        } catch (e: StackOverflowError) {
            // parser rekursif menolak nesting > 64, tapi jaga-jaga jika ada di jalur lain
            throw RpcException("respons rpc rusak (nesting terlalu dalam)")
        } catch (e: Exception) {
            throw RpcException("rpc tidak terjangkau: ${e.message ?: e.javaClass.simpleName}")
        } finally {
            conn?.disconnect()
        }
    }

    private companion object {
        const val MAX_RESPONSE_CHARS = 1_000_000
    }

    /** Baca stream dengan batas 1 MB — respons raksasa dari rpc jahat tidak boleh OOM. */
    private fun readCapped(stream: java.io.InputStream): String {
        val reader = java.io.BufferedReader(java.io.InputStreamReader(stream, Charsets.UTF_8))
        val sb = StringBuilder()
        val buf = CharArray(8192)
        var total = 0
        while (true) {
            val n = reader.read(buf)
            if (n < 0) break
            total += n
            if (total > MAX_RESPONSE_CHARS) throw RpcException("respons rpc terlalu besar (>1MB)")
            sb.append(buf, 0, n)
        }
        return sb.toString()
    }
}
