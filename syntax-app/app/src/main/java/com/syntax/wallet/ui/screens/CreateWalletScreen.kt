package com.syntax.wallet.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.unit.dp
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
import com.syntax.wallet.ui.theme.Surface
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TerminalStyle
import com.syntax.wallet.ui.theme.TextPrimary
import com.syntax.wallet.ui.theme.Warn
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextSecondary
import kotlin.random.Random
import java.util.Locale

private enum class CreatePhase { SHOW, CONFIRM, DONE }

/**
 * Buat dompet: tampilkan 12 kata seed → konfirmasi (tebak kata ke-N) →
 * output terminal (derive, enkripsi, address) → launch terminal.
 */
@Composable
fun CreateWalletScreen(onDone: () -> Unit) {
    val context = LocalContext.current
    val clipboard = LocalClipboardManager.current
    val wordlist = remember {
        context.assets.open("bip39-english.txt")
            .bufferedReader().readLines().filter { it.isNotBlank() }
    }

    var mnemonic by remember { mutableStateOf("") }
    var phase by remember { mutableStateOf(CreatePhase.SHOW) }
    var wallet by remember { mutableStateOf<WalletCore?>(null) }
    var confirmIndex by remember { mutableStateOf(0) }
    var decoys by remember { mutableStateOf(listOf<String>()) }
    var wrongAttempt by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        mnemonic = Bip39.generate(wordlist)
        confirmIndex = Random.nextInt(12)
    }

    val words = remember(mnemonic) { mnemonic.split(" ").filter { it.isNotBlank() } }

    fun newDecoys() {
        val others = words.indices.filter { it != confirmIndex }
            .map { words[it] }
            .distinct()
            .shuffled()
            .take(2)
        decoys = (others + words[confirmIndex]).shuffled()
    }

    LaunchedEffect(phase) {
        if (phase == CreatePhase.CONFIRM && decoys.isEmpty()) newDecoys()
    }

    fun complete() {
        val w = WalletCore.fromMnemonic(mnemonic, wordlist)
        WalletStore(context).saveSecret(mnemonic, w.address)
        wallet = w
        phase = CreatePhase.DONE
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .scanlines()
            .systemBarsPadding()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
        ) {
            Spacer(modifier = Modifier.height(40.dp))
            Text("SYNTAX // NEW WALLET", style = TerminalStyle.copy(color = TextSecondary))
            Spacer(modifier = Modifier.height(24.dp))

            when (phase) {
                CreatePhase.SHOW -> {
                    Text(
                        "seed phrase — 12 words",
                        style = TerminalStyle.copy(color = TextPrimary)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "write it down on paper. never share it. no recovery without it.",
                        style = TerminalSmall,
                        color = Warn
                    )
                    Spacer(modifier = Modifier.height(20.dp))

                    words.chunked(3).forEachIndexed { rowIdx, row ->
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            row.forEachIndexed { colIdx, word ->
                                val n = rowIdx * 3 + colIdx + 1
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .border(1.dp, Border, RoundedCornerShape(2.dp))
                                        .background(Surface)
                                        .padding(horizontal = 10.dp, vertical = 12.dp)
                                ) {
                                    Column {
                                        Text(
                                            text = String.format(Locale.US, "%02d", n),
                                            style = TerminalSmall,
                                            color = TextDim
                                        )
                                        Text(
                                            text = word,
                                            style = TerminalStyle,
                                            color = TextPrimary
                                        )
                                    }
                                }
                            }
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .border(1.dp, Border, RoundedCornerShape(2.dp))
                                .background(Surface)
                                .clickable {
                                    clipboard.setText(AnnotatedString(mnemonic))
                                    Toast.makeText(context, "copied to clipboard", Toast.LENGTH_SHORT).show()
                                }
                                .padding(vertical = 13.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("[ copy ]", style = TerminalStyle, color = TextSecondary)
                        }
                        Box(
                            modifier = Modifier
                                .weight(1.6f)
                                .border(1.dp, Border, RoundedCornerShape(2.dp))
                                .background(Surface)
                                .clickable {
                                    if (words.size == 12) {
                                        confirmIndex = Random.nextInt(12)
                                        newDecoys()
                                        phase = CreatePhase.CONFIRM
                                    }
                                }
                                .padding(vertical = 13.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("[ i saved it ]", style = TerminalStyle, color = TextPrimary)
                        }
                    }
                }

                CreatePhase.CONFIRM -> {
                    Text(
                        "verification: which word is #" + String.format(Locale.US, "%02d", confirmIndex + 1) + "?",
                        style = TerminalStyle.copy(color = TextPrimary)
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    if (wrongAttempt) {
                        Text("wrong word. try again.", style = TerminalStyle, color = Err)
                        Spacer(modifier = Modifier.height(12.dp))
                    }
                    decoys.forEach { option ->
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .border(1.dp, Border, RoundedCornerShape(2.dp))
                                .background(Surface)
                                .clickable {
                                    if (option == words.getOrNull(confirmIndex)) {
                                        wrongAttempt = false
                                        complete()
                                    } else {
                                        wrongAttempt = true
                                        newDecoys()
                                    }
                                }
                                .padding(horizontal = 14.dp, vertical = 13.dp)
                        ) {
                            Text("> $option", style = TerminalStyle, color = TextPrimary)
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                }

                CreatePhase.DONE -> {
                    val w = wallet
                    TerminalView(
                        lines = listOf(
                            TermLine(0, "> generating entropy (128-bit) ... ok", LineType.DIM),
                            TermLine(1, "> validating checksum ............ ok", LineType.DIM),
                            TermLine(2, "> deriving m/44'/60'/0'/0/0 ..... ok", LineType.DIM),
                            TermLine(3, "> encrypting vault (aes-256-gcm)  ok", LineType.DIM),
                            TermLine(4, "", LineType.OUT),
                            TermLine(5, "address: ${w?.address ?: "…"}", LineType.OK),
                            TermLine(6, "", LineType.OUT),
                            TermLine(7, "wallet created. welcome to syntax.", LineType.OUT)
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            if (phase == CreatePhase.DONE) {
                TermButton(
                    label = "launch terminal",
                    iconRes = R.drawable.ic_logo,
                    onClick = onDone
                )
            }

            Spacer(modifier = Modifier.height(40.dp))
        }
    }
}
