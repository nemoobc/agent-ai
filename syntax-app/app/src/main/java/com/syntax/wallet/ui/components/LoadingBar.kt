package com.syntax.wallet.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TerminalStyle
import com.syntax.wallet.ui.theme.TextSecondary
import kotlin.math.roundToInt

/**
 * Loading bar gaya terminal: [████░░░░░░] 42% — block unicode (bukan emoji).
 */
@Composable
fun LoadingBar(progress: Float, modifier: Modifier = Modifier, blocks: Int = 22) {
    val p = progress.coerceIn(0f, 1f)
    val filled = (p * blocks).roundToInt()
    val bar = "█".repeat(filled) + "░".repeat(blocks - filled)
    Column(modifier = modifier) {
        Text(
            text = "[$bar] ${(p * 100).roundToInt()}%",
            style = TerminalSmall.copy(color = TextSecondary),
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}
