package com.syntax.wallet.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.syntax.wallet.R
import com.syntax.wallet.crypto.Bip39
import com.syntax.wallet.crypto.WalletCore
import com.syntax.wallet.data.WalletStore
import com.syntax.wallet.ui.components.TermButton
import com.syntax.wallet.ui.components.TerminalView
import com.syntax.wallet.ui.components.TermLine
import com.syntax.wallet.ui.components.LineType
import com.syntax.wallet.ui.components.scanlines
import com.syntax.wallet.ui.theme.Bg
import com.syntax.wallet.ui.theme.Border
import com.syntax.wallet.ui.theme.Err
import com.syntax.wallet.ui.theme.Logo
import com.syntax.wallet.ui.theme.Ok
import com.syntax.wallet.ui.theme.Surface
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TerminalStyle
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextPrimary
import com.syntax.wallet.ui.theme.TextSecondary

private enum class ImportPhase { INPUT, DONE }

/**
 * Import dompet: mnemonic 12/24 kata atau private key 0x…64-hex.
 * Validasi live bergaya terminal.
 */
@Composable
fun ImportWalletScreen(onDone: () -> Unit) {
    val context = androidx.compose.ui.platform.LocalContext.current
    val wordlist = remember {
        context.assets.open("bip39-english.txt")
            .bufferedReader().readLines().filter { it.isNotBlank() }
    }

    var text by remember { mutableStateOf("") }
    var phase by remember { mutableStateOf(ImportPhase.INPUT) }
    var wallet by remember { mutableStateOf<WalletCore?>(null) }

    val kind = remember(text) {
        if (text.isBlank()) null else WalletCore.classifyImport(text, wordlist)
    }
    val statusText = when (kind) {
        null -> "awaiting input…"
        WalletCore.ImportKind.MNEMONIC -> "valid mnemonic (" + text.trim().split(Regex("\\s+")).size + " words)"
        WalletCore.ImportKind.PRIVATE_KEY -> "valid private key"
        WalletCore.ImportKind.INVALID -> "invalid mnemonic or private key"
    }
    val statusColor = when (kind) {
        null -> TextDim
        WalletCore.ImportKind.INVALID -> Err
        else -> Ok
    }

    fun doImport() {
        val k = WalletCore.classifyImport(text, wordlist)
        if (k == WalletCore.ImportKind.INVALID) return
        val w = if (k == WalletCore.ImportKind.PRIVATE_KEY) {
            WalletCore.fromPrivateKey(text.trim())
        } else {
            WalletCore.fromMnemonic(text.trim(), wordlist)
        }
        val secret = if (k == WalletCore.ImportKind.PRIVATE_KEY) text.trim() else Bip39.normalize(text.trim())
        WalletStore(context).saveSecret(secret, w.address)
        wallet = w
        phase = ImportPhase.DONE
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .scanlines()
            .systemBarsPadding()
            .imePadding()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))
            Text("SYNTAX // IMPORT WALLET", style = TerminalStyle.copy(color = TextSecondary))
            Spacer(modifier = Modifier.height(24.dp))

            when (phase) {
                ImportPhase.INPUT -> {
                    Text(
                        "paste seed phrase (12/24 words) or private key (0x…)",
                        style = TerminalSmall,
                        color = TextSecondary
                    )
                    Spacer(modifier = Modifier.height(12.dp))

                    androidx.compose.foundation.text.BasicTextField(
                        value = text,
                        onValueChange = { text = it },
                        textStyle = TextStyle(
                            fontFamily = FontFamily.Monospace,
                            fontSize = 14.sp,
                            lineHeight = 21.sp,
                            color = TextPrimary
                        ),
                        cursorBrush = SolidColor(Logo),
                        keyboardOptions = KeyboardOptions(
                            autoCorrect = false,
                            capitalization = KeyboardCapitalization.None
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(160.dp)
                            .border(1.dp, Border, RoundedCornerShape(2.dp))
                            .background(Surface)
                            .padding(12.dp)
                    )

                    Spacer(modifier = Modifier.height(10.dp))
                    Text("> " + statusText, style = TerminalSmall, color = statusColor)

                    Spacer(modifier = Modifier.height(20.dp))

                    TermButton(
                        label = "import wallet",
                        iconRes = R.drawable.ic_import,
                        enabled = kind != null && kind != WalletCore.ImportKind.INVALID,
                        onClick = { doImport() }
                    )
                }

                ImportPhase.DONE -> {
                    val w = wallet
                    TerminalView(
                        lines = listOf(
                            TermLine(0, "> validating input .............. ok", LineType.DIM),
                            TermLine(1, "> deriving keys ................. ok", LineType.DIM),
                            TermLine(2, "> encrypting vault (aes-256-gcm)  ok", LineType.DIM),
                            TermLine(3, "", LineType.OUT),
                            TermLine(4, "address: ${w?.address ?: "…"}", LineType.OK),
                            TermLine(5, "", LineType.OUT),
                            TermLine(6, "wallet imported. welcome back.", LineType.OUT)
                        )
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                    TermButton(
                        label = "launch terminal",
                        iconRes = R.drawable.ic_logo,
                        onClick = onDone
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }
    }
}
