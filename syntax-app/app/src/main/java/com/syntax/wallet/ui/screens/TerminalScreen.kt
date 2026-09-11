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
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.syntax.wallet.R
import com.syntax.wallet.ui.components.TerminalView
import com.syntax.wallet.ui.components.scanlines
import com.syntax.wallet.ui.theme.Bg
import com.syntax.wallet.ui.theme.Border
import com.syntax.wallet.ui.theme.Logo
import com.syntax.wallet.ui.theme.Surface
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextPrimary
import com.syntax.wallet.ui.theme.TextSecondary

/**
 * Layar utama: status bar (logo + chain + address) + quick actions +
 * output terminal + baris input "$" dengan keyboard.
 */
@Composable
fun TerminalScreen(onWiped: () -> Unit) {
    val vm: TerminalViewModel = viewModel()
    val lines by vm.lines.collectAsState()
    val input by vm.input.collectAsState()
    val chainName by vm.chainName.collectAsState()
    val wiped by vm.wiped.collectAsState()

    val context = LocalContext.current
    val clipboard = LocalClipboardManager.current
    val focusRequester = remember { FocusRequester() }

    val walletAddress = remember {
        com.syntax.wallet.data.WalletStore(context).address()
    }

    LaunchedEffect(wiped) {
        if (wiped) onWiped()
    }

    fun submit() {
        vm.submit(input)
        vm.setInput("")
    }

    fun prefill(cmd: String) {
        vm.setInput(cmd)
        focusRequester.requestFocus()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .systemBarsPadding()
            .imePadding()
            .navigationBarsPadding()
    ) {
        // ── status bar ─────────────────────────────────────────
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier
                .fillMaxWidth()
                .background(Surface)
                .padding(horizontal = 12.dp, vertical = 10.dp)
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_logo),
                contentDescription = null,
                tint = Logo,
                modifier = Modifier.size(18.dp)
            )
            Text(
                text = "SYNTAX",
                style = TerminalSmall.copy(fontWeight = FontWeight.Bold),
                color = TextSecondary
            )
            Text(
                text = "[" + chainName + "]",
                style = TerminalSmall,
                color = TextDim
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = walletAddress?.let { it.take(8) + "…" + it.takeLast(6) } ?: "no wallet",
                style = TerminalSmall,
                color = TextSecondary,
                modifier = Modifier.clickable {
                    walletAddress?.let {
                        clipboard.setText(androidx.compose.ui.text.AnnotatedString(it))
                        Toast.makeText(context, "address copied", Toast.LENGTH_SHORT).show()
                    }
                }
            )
            Spacer(modifier = Modifier.width(4.dp))
            Icon(
                painter = painterResource(R.drawable.ic_trash),
                contentDescription = "wipe wallet",
                tint = TextDim,
                modifier = Modifier
                    .size(18.dp)
                    .clickable { vm.submit("wipe") }
            )
        }

        // ── quick actions ──────────────────────────────────────
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier
                .fillMaxWidth()
                .background(Bg)
                .padding(horizontal = 12.dp, vertical = 8.dp)
        ) {
            QuickAction(icon = R.drawable.ic_help, label = "help", weight = 1f) {
                vm.submit("help")
            }
            QuickAction(icon = R.drawable.ic_balance, label = "balance", weight = 1f) {
                vm.submit("balance")
            }
            QuickAction(icon = R.drawable.ic_shield, label = "status", weight = 1f) {
                vm.submit("status")
            }
            QuickAction(icon = R.drawable.ic_send, label = "send", weight = 1f) {
                prefill("send ")
            }
            QuickAction(icon = R.drawable.ic_key, label = "sign", weight = 1f) {
                prefill("sign ")
            }
        }

        // ── output terminal ────────────────────────────────────
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            TerminalView(lines = lines)
        }

        // ── baris input ────────────────────────────────────────
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .background(Surface)
                .border(1.dp, Border)
                .padding(horizontal = 12.dp, vertical = 2.dp)
        ) {
            Text(
                text = "$ ",
                style = TextStyle(
                    fontFamily = FontFamily.Monospace,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                ),
                color = Logo
            )
            BasicTextField(
                value = input,
                onValueChange = { vm.setInput(it) },
                textStyle = TextStyle(
                    fontFamily = FontFamily.Monospace,
                    fontSize = 14.sp,
                    color = TextPrimary
                ),
                cursorBrush = SolidColor(Logo),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send, autoCorrect = false),
                keyboardActions = KeyboardActions(onSend = { submit() }),
                modifier = Modifier
                    .weight(1f)
                    .padding(vertical = 12.dp)
                    .focusRequester(focusRequester)
            )
            Icon(
                painter = painterResource(R.drawable.ic_send),
                contentDescription = "execute",
                tint = if (input.isNotBlank()) Logo else TextDim,
                modifier = Modifier
                    .size(20.dp)
                    .clickable(enabled = input.isNotBlank()) { submit() }
            )
        }
    }
}

@Composable
private fun QuickAction(
    icon: Int,
    label: String,
    weight: Float,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .weight(weight)
            .border(1.dp, Border, RoundedCornerShape(2.dp))
            .background(Surface)
            .clickable { onClick() }
            .padding(vertical = 8.dp)
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = label,
            tint = TextSecondary,
            modifier = Modifier.size(18.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            style = TerminalSmall,
            color = TextSecondary
        )
    }
}
