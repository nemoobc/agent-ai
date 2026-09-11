package com.syntax.wallet.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.syntax.wallet.crypto.Eip155
import com.syntax.wallet.crypto.Eip55
import com.syntax.wallet.crypto.Eip7702
import com.syntax.wallet.crypto.Hex
import com.syntax.wallet.crypto.WalletCore
import com.syntax.wallet.data.ChainPreset
import com.syntax.wallet.data.Chains
import com.syntax.wallet.data.RpcClient
import com.syntax.wallet.data.RpcException
import com.syntax.wallet.data.WalletStore
import com.syntax.wallet.ui.components.LineType
import com.syntax.wallet.ui.components.TermLine
import com.syntax.wallet.util.Amount
import java.math.BigInteger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/**
 * Sesi terminal: parser command + state baris output + RPC async.
 * Semua fitur dompet diakses lewat command ala terminal.
 */
class TerminalViewModel(app: Application) : AndroidViewModel(app) {

    private val store = WalletStore(app)
    private val wordlist: List<String> = app.assets
        .open("bip39-english.txt")
        .bufferedReader()
        .readLines()
        .filter { it.isNotBlank() }

    private var wallet: WalletCore? = null

    val lines = MutableStateFlow<List<TermLine>>(emptyList())
    val input = MutableStateFlow("")
    val chainName = MutableStateFlow(store.chainName())
    val customRpc = MutableStateFlow(store.customRpc())
    val wiped = MutableStateFlow(false)

    private var nextId = 1L
    private val history = mutableListOf<String>()
    @Volatile
    private var pendingConfirm: ((Boolean) -> Unit)? = null

    init {
        wallet = store.loadSecret()?.let { secret ->
            val kind = WalletCore.classifyImport(secret, wordlist)
            when (kind) {
                WalletCore.ImportKind.PRIVATE_KEY ->
                    runCatching { WalletCore.fromPrivateKey(secret) }.getOrNull()
                WalletCore.ImportKind.MNEMONIC ->
                    runCatching { WalletCore.fromMnemonic(secret, wordlist) }.getOrNull()
                else -> null
            }
        }
        banner()
    }

    private fun chain(): ChainPreset = Chains.byName(chainName.value) ?: Chains.MAINNET
    private fun rpcUrl(): String = customRpc.value ?: chain().rpc
    private fun rpc(): RpcClient = RpcClient(rpcUrl())

    fun setInput(v: String) {
        input.value = v
    }

    private fun add(text: String, type: LineType = LineType.OUT): Long {
        val id = nextId++
        lines.update { it + TermLine(id, text, type) }
        return id
    }

    private fun replace(id: Long, text: String, type: LineType = LineType.OUT) {
        lines.update { current ->
            current.map { if (it.id == id) TermLine(id, text, type) else it }
        }
    }

    private fun io(block: suspend () -> Unit) {
        viewModelScope.launch(Dispatchers.IO) { block() }
    }

    private fun banner() {
        add("SYNTAX v1.0.0 — EIP-7702 TERMINAL", LineType.HEAD)
        add("chain   : " + chain().name + " (" + chain().id + ")", LineType.DIM)
        val w = wallet
        if (w != null) {
            add("address : " + w.address, LineType.DIM)
            add("type 'help' to list commands.", LineType.OUT)
        } else {
            add("error   : wallet not found — wipe and re-import.", LineType.ERR)
        }
        add("", LineType.OUT)
    }

    fun submit(raw: String) {
        val cmd = raw.trim()
        if (cmd.isEmpty()) return

        val confirm = pendingConfirm
        if (confirm != null) {
            pendingConfirm = null
            add("$ $cmd", LineType.CMD)
            val yes = cmd.equals("y", true) || cmd.equals("yes", true)
            if (!yes && !cmd.equals("n", true) && !cmd.equals("no", true)) {
                add("jawaban tidak dikenal (y/n) — dianggap 'no'.", LineType.DIM)
            }
            confirm(yes)
            return
        }

        add("$ $cmd", LineType.CMD)
        if (name != "sign") {
            // pesan yang ditandatangani bisa sensitif — tidak masuk history
            history.add(cmd)
            if (history.size > 100) history.removeAt(0)
        }

        val parts = cmd.split(Regex("\\s+"))
        val name = parts.first().lowercase()
        val args = parts.drop(1)

        when (name) {
            "help" -> help()
            "version", "--version" -> add("syntax 1.0.0 (eip-7702, pectra-ready)", LineType.OUT)
            "address" -> addressCmd()
            "balance" -> balanceCmd()
            "nonce" -> nonceCmd()
            "status" -> statusCmd()
            "delegate" -> delegateCmd(args)
            "undelegate" -> delegateCmd(listOf(Eip7702.CLEAR_DELEGATION_ADDRESS))
            "send" -> sendCmd(args)
            "sign" -> {
                // pertahankan spasi internal pesan persis seperti diketik
                val message = cmd.substring("sign".length).trim()
                signCmd(message)
            }
            "set" -> setCmd(args)
            "history" -> historyCmd()
            "clear" -> lines.value = emptyList()
            "wipe" -> wipeCmd()
            "exit" -> add("there is no exit. only syntax.", LineType.DIM)
            else -> add("command not found: $name (try 'help')", LineType.ERR)
        }
    }

    private fun requireWallet(): WalletCore? {
        val w = wallet ?: run {
            add("error: wallet not loaded.", LineType.ERR)
            null
        }
        return w
    }

    private fun help() {
        add("commands:", LineType.HEAD)
        add("  help                     show this help", LineType.OUT)
        add("  version                  show version", LineType.OUT)
        add("  address                  show wallet address", LineType.OUT)
        add("  balance                  query eth balance via rpc", LineType.OUT)
        add("  nonce                    query transaction count", LineType.OUT)
        add("  status                   show eip-7702 delegation status", LineType.OUT)
        add("  delegate <0xaddress>     sign 7702 authorization for a contract", LineType.OUT)
        add("  undelegate               sign 7702 authorization to clear delegation", LineType.OUT)
        add("  send <to> <amount_eth>   sign + broadcast eth transfer", LineType.OUT)
        add("  sign <message>           personal_sign a message", LineType.OUT)
        add("  set chain <name>         switch chain: mainnet | sepolia", LineType.OUT)
        add("  set rpc <url>            set custom rpc url ('set rpc reset' to clear)", LineType.OUT)
        add("  history                  show command history", LineType.OUT)
        add("  clear                    clear screen", LineType.OUT)
        add("  wipe                     destroy wallet on this device", LineType.OUT)
    }

    private fun addressCmd() {
        val w = requireWallet() ?: return
        add("address : " + w.address, LineType.OK)
        add("short   : " + w.shortAddress(), LineType.DIM)
    }

    private fun balanceCmd() {
        val w = requireWallet() ?: return
        val id = add("querying balance via rpc ...", LineType.DIM)
        io {
            try {
                val wei = rpc().balance(w.address)
                replace(id, "balance : " + Amount.formatWei(wei) + " ETH", LineType.OK)
            } catch (e: RpcException) {
                replace(id, "rpc error: " + e.message, LineType.ERR)
            }
        }
    }

    private fun nonceCmd() {
        val w = requireWallet() ?: return
        val id = add("querying nonce via rpc ...", LineType.DIM)
        io {
            try {
                val n = rpc().transactionCount(w.address)
                replace(id, "nonce   : " + n, LineType.OK)
            } catch (e: RpcException) {
                replace(id, "rpc error: " + e.message, LineType.ERR)
            }
        }
    }

    private fun statusCmd() {
        val w = requireWallet() ?: return
        val id = add("querying account code via rpc ...", LineType.DIM)
        io {
            try {
                val code = rpc().code(w.address)
                val delegated = Eip7702.parseDelegationCode(code)
                if (delegated != null) {
                    replace(id, "status  : DELEGATED (eip-7702)", LineType.OK)
                    add("delegate: " + delegated, LineType.OK)
                    add("raw code: " + code.take(74) + "…", LineType.DIM)
                } else {
                    replace(id, "status  : plain EOA — not delegated", LineType.OUT)
                }
            } catch (e: RpcException) {
                replace(id, "rpc error: " + e.message, LineType.ERR)
            }
        }
    }

    /** Validasi alamat argumen: 40-hex DAN (semua-lower/upper ATAU checksum EIP-55 valid). */
    private fun isValidAddressArg(s: String): Boolean {
        if (!Hex.isValidAddress(s)) return false
        val body = s.trim().removePrefix("0x").removePrefix("0X")
        val lower = body.lowercase()
        val upper = body.uppercase()
        if (body == lower || body == upper) return true
        return Eip55.isValidChecksummed(s.trim())
    }

    private fun printAuthorization(auth: Eip7702.Authorization, note: String) {
        add("", LineType.OUT)
        add("authorization signed (eip-7702):", LineType.HEAD)
        add("  chain    : " + auth.chainId, LineType.OUT)
        add("  delegate : " + Hex.addressBytesToHex(auth.address), LineType.OUT)
        add("  nonce    : " + auth.nonce, LineType.OUT)
        add("  y_parity : " + auth.yParity, LineType.OUT)
        add("  r        : 0x" + Hex.bytesToHex(Hex.toPadded(auth.r, 32)), LineType.OUT)
        add("  s        : 0x" + Hex.bytesToHex(Hex.toPadded(auth.s, 32)), LineType.OUT)
        add("  raw      : " + auth.rawHex().take(98) + "…", LineType.DIM)
        add("  note     : " + note, LineType.DIM)
    }

    private fun delegateCmd(args: List<String>) {
        val w = requireWallet() ?: return
        if (args.isEmpty() || !Hex.isValidAddress(args[0])) {
            add("usage: delegate <0xaddress> — target contract to delegate to", LineType.ERR)
            return
        }
        if (!isValidAddressArg(args[0])) {
            add("address mixed-case tapi checksum EIP-55 tidak valid — perbaiki kapitalisasi atau pakai lowercase semua.", LineType.ERR)
            return
        }
        val target = if (args[0].trim().removePrefix("0x").removePrefix("0X") == args[0].trim().removePrefix("0x").removePrefix("0X").lowercase()) {
            args[0].lowercase()
        } else Eip55.checksum(args[0])
        val id = add("querying nonce via rpc ...", LineType.DIM)
        io {
            val client = rpc()
            var nonce: BigInteger? = null
            try {
                nonce = client.transactionCount(w.address)
            } catch (e: RpcException) {
                replace(id, "rpc unreachable — offline signing (nonce 0)", LineType.WARN)
            }
            if (nonce == null) {
                // offline: tanda tangan lokal dengan nonce 0 (untuk pihak ketiga yang menyponsori)
                val auth = w.signAuthorization(chain().id, Hex.hexToBytes(target), BigInteger.ZERO)
                printAuthorization(
                    auth,
                    "offline: nonce unknown (=0). valid untuk third-party sponsor dengan nonce yang sama."
                )
                add("broadcast skipped (rpc unreachable).", LineType.DIM)
                return@io
            }
            replace(id, "nonce " + nonce, LineType.DIM)
            // SELF-SPONSORED: nonce akun dinaikkan SEBELUM authorization list diproses
            // (spesifikasi final EIP-7702) → auth nonce = tx nonce + 1.
            val authNonce = nonce.add(BigInteger.ONE)
            val auth = w.signAuthorization(chain().id, Hex.hexToBytes(target), authNonce)
            printAuthorization(auth, "self-sponsored: auth nonce = tx nonce + 1 (spec 7702)")
            add("", LineType.OUT)
            add("broadcast 7702 activation tx to self? (needs gas) [y/N]", LineType.WARN)
            val txNonce = nonce
            pendingConfirm = { yes ->
                if (yes) broadcast7702(w, auth, txNonce)
                else add("authorization saved off-chain. not broadcast.", LineType.DIM)
            }
        }
    }

    private fun broadcast7702(w: WalletCore, auth: Eip7702.Authorization, txNonce: BigInteger) {
        val id = add("querying gas price ...", LineType.DIM)
        io {
            try {
                val client = rpc()
                val gasPrice = client.gasPrice()
                replace(id, "gas price $gasPrice wei", LineType.DIM)
                val tx = Eip7702.Tx(
                    chainId = chain().id,
                    nonce = txNonce,
                    maxPriorityFeePerGas = gasPrice,
                    maxFeePerGas = gasPrice,
                    gasLimit = BigInteger.valueOf(100_000),
                    to = Hex.hexToBytes(w.address),
                    value = BigInteger.ZERO,
                    data = ByteArray(0),
                    authorizations = listOf(auth)
                )
                val signed = Eip7702.sign(tx, w.privateKey)
                add("broadcasting type-4 tx ...", LineType.DIM)
                val hash = client.sendRawTransaction(signed.rawHex)
                add("tx      : " + hash, LineType.OK)
                add("explorer: " + chain().explorer + "/tx/" + hash.removePrefix("0x"), LineType.DIM)
                add("hint    : cek hasil dengan 'status' setelah tx masuk blok.", LineType.DIM)
            } catch (e: RpcException) {
                add("broadcast failed: " + e.message, LineType.ERR)
            }
        }
    }

    private fun sendCmd(args: List<String>) {
        val w = requireWallet() ?: return
        if (args.size < 2 || !Hex.isValidAddress(args[0])) {
            add("usage: send <0xaddress> <amount_eth>", LineType.ERR)
            return
        }
        if (!isValidAddressArg(args[0])) {
            add("address mixed-case tapi checksum EIP-55 tidak valid — transfer bisa salah alamat permanen.", LineType.ERR)
            return
        }
        val to = if (args[0].trim().removePrefix("0x").removePrefix("0X") == args[0].trim().removePrefix("0x").removePrefix("0X").lowercase()) {
            args[0].lowercase()
        } else Eip55.checksum(args[0])
        val amount = args[1]
        val wei = Amount.parseEther(amount)
        if (wei == null || wei.signum() <= 0) {
            add("invalid amount: $amount", LineType.ERR)
            return
        }
        val id = add("querying nonce + gas price + estimate ...", LineType.DIM)
        io {
            try {
                val client = rpc()
                val nonce = client.transactionCount(w.address)
                val gasPrice = client.gasPrice()
                // estimasi gas: menangani penerima kontrak/berkode (akun delegated)
                var gasLimit = BigInteger.valueOf(21_000)
                try {
                    val est = client.estimateGas(w.address, to, wei, gasPrice)
                    if (est > gasLimit) gasLimit = est
                    if (est > BigInteger.valueOf(21_000)) {
                        add("note    : recipient punya kode — gas estimasi dipakai ($est)", LineType.WARN)
                    }
                } catch (e: RpcException) {
                    add("note    : estimate gagal (" + e.message + ") — pakai 21000, revert mungkin", LineType.WARN)
                }
                replace(id, "nonce " + nonce + " · gas " + gasLimit + " · price " + gasPrice + " wei", LineType.DIM)
                add("", LineType.OUT)
                add("transfer summary:", LineType.HEAD)
                add("  from  : " + w.address, LineType.OUT)
                add("  to    : " + to, LineType.OUT)
                add("  value : " + amount + " ETH", LineType.OUT)
                add("  fee   : ~" + Amount.formatFee(gasLimit, gasPrice) + " ETH", LineType.OUT)
                add("", LineType.OUT)
                add("broadcast? [y/N]", LineType.WARN)
                pendingConfirm = { yes ->
                    if (!yes) {
                        add("cancelled.", LineType.DIM)
                    } else {
                        io {
                            try {
                                val tx = Eip155.Tx(
                                    nonce = nonce,
                                    gasPrice = gasPrice,
                                    gasLimit = gasLimit,
                                    to = Hex.hexToBytes(to),
                                    value = wei,
                                    data = ByteArray(0),
                                    chainId = chain().id
                                )
                                val signed = Eip155.sign(tx, w.privateKey)
                                add("broadcasting ...", LineType.DIM)
                                val hash = rpc().sendRawTransaction(signed.rawHex)
                                add("tx      : " + hash, LineType.OK)
                                add("explorer: " + chain().explorer + "/tx/" + hash.removePrefix("0x"), LineType.DIM)
                                add("hint    : hash sukses = diterima node, bukan eksekusi berhasil.", LineType.DIM)
                            } catch (e: RpcException) {
                                add("broadcast failed: " + e.message, LineType.ERR)
                            }
                        }
                    }
                }
            } catch (e: RpcException) {
                replace(id, "rpc error: " + e.message, LineType.ERR)
            }
        }
    }

    private fun signCmd(message: String) {
        val w = requireWallet() ?: return
        if (message.isEmpty()) {
            add("usage: sign <message>", LineType.ERR)
            return
        }
        add("message : " + message, LineType.DIM)
        add("length  : " + message.toByteArray(Charsets.UTF_8).size + " bytes (utf-8)", LineType.DIM)
        try {
            val sig = w.signPersonalMessage(message)
            add("signature: " + sig, LineType.OK)
            add("scheme   : eip-191 personal_sign (r,s,v)", LineType.DIM)
        } catch (e: Exception) {
            add("sign failed: " + e.message, LineType.ERR)
        }
    }

    private fun setCmd(args: List<String>) {
        if (args.size < 2) {
            add("usage: set chain <mainnet|sepolia> | set rpc <url> | set rpc reset", LineType.ERR)
            return
        }
        when (args[0].lowercase()) {
            "chain" -> {
                val preset = Chains.byName(args[1])
                if (preset == null) {
                    add("unknown chain: ${args[1]} (available: ${Chains.ALL.joinToString(", ") { it.name }})", LineType.ERR)
                    return
                }
                chainName.value = preset.name
                store.setChainName(preset.name)
                add("chain set: " + preset.name + " (" + preset.id + ")", LineType.OK)
                add("rpc     : " + rpcUrl(), LineType.DIM)
            }
            "rpc" -> {
                if (args[1].equals("reset", true)) {
                    customRpc.value = null
                    store.setCustomRpc(null)
                    add("rpc reset to default: " + rpcUrl(), LineType.OK)
                } else {
                    val url = args[1]
                    if (!url.startsWith("http")) {
                        add("rpc url must start with http(s)", LineType.ERR)
                        return
                    }
                    if (url.startsWith("http://")) {
                        add("warning: http cleartext diblokir android 9+ — pakai https atau node lokal via adb reverse.", LineType.WARN)
                    }
                    customRpc.value = url
                    store.setCustomRpc(url)
                    add("rpc set: " + url, LineType.OK)
                    // verifikasi endpoint: tanya chain id
                    val id2 = add("verifying rpc (eth_chainId) ...", LineType.DIM)
                    io {
                        try {
                            val cid = RpcClient(url).chainId()
                            replace(id2, "rpc ok  : chain id " + cid, LineType.OK)
                            if (cid.toLong() != chain().id) {
                                add("warning: chain id rpc ($cid) != preset '" + chain().name + "' (" + chain().id + ") — sesuaikan dengan 'set chain'.", LineType.WARN)
                            }
                        } catch (e: RpcException) {
                            replace(id2, "rpc gagal: " + e.message, LineType.ERR)
                        }
                    }
                }
            }
            else -> add("unknown setting: ${args[0]}", LineType.ERR)
        }
    }

    private fun historyCmd() {
        if (history.isEmpty()) {
            add("history empty.", LineType.DIM)
            return
        }
        add("history:", LineType.HEAD)
        history.takeLast(20).forEach { add("  $it", LineType.OUT) }
    }

    private fun wipeCmd() {
        add("destroy wallet on this device? this cannot be undone. [y/N]", LineType.WARN)
        pendingConfirm = { yes ->
            if (yes) {
                store.wipe()
                wallet = null
                add("wallet wiped (vault + keystore key).", LineType.OK)
                wiped.value = true
            } else {
                add("cancelled.", LineType.DIM)
            }
        }
    }
}
