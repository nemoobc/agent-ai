package com.syntax.wallet.ui.screens

import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.syntax.wallet.R
import com.syntax.wallet.ui.components.BlinkingTerminalLogo
import com.syntax.wallet.ui.components.TermButton
import com.syntax.wallet.ui.components.scanlines
import com.syntax.wallet.ui.theme.Bg
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TerminalTitle
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextSecondary

/**
 * Layar pilihan dompet: logo ">_" di atas, dua tombol besar:
 * CREATE WALLET / IMPORT WALLET.
 */
@Composable
fun WalletSelectScreen(
    onCreate: () -> Unit,
    onImport: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .scanlines()
            .systemBarsPadding()
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(88.dp))

            // logo di atas dua tombol
            BlinkingTerminalLogo(size = 104.dp)

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "SYNTAX",
                style = TerminalTitle,
                color = TextSecondary
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "EIP-7702 TERMINAL WALLET",
                style = TerminalSmall,
                color = TextDim
            )

            Spacer(modifier = Modifier.height(56.dp))

            TermButton(
                label = "create wallet",
                iconRes = R.drawable.ic_create,
                onClick = onCreate
            )

            Spacer(modifier = Modifier.height(14.dp))

            TermButton(
                label = "import wallet",
                iconRes = R.drawable.ic_import,
                onClick = onImport
            )
        }

        Text(
            text = "v1.0.0 · keys never leave this device",
            style = TerminalSmall,
            color = TextDim,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 24.dp)
        )
    }
}
