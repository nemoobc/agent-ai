package com.syntax.wallet.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import android.view.HapticFeedbackConstants
import com.syntax.wallet.ui.theme.Border
import com.syntax.wallet.ui.theme.Logo
import com.syntax.wallet.ui.theme.Surface
import com.syntax.wallet.ui.theme.TerminalLabel
import com.syntax.wallet.ui.theme.TextPrimary

/**
 * Tombol terminal: kotak border abu-abu + icon vector custom + label monospace uppercase.
 */
@Composable
fun TermButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    iconRes: Int? = null,
    enabled: Boolean = true
) {
    val view = LocalView.current
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val scale = if (pressed) 0.97f else 1f

    Surface(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            },
        shape = androidx.compose.foundation.shape.RoundedCornerShape(2.dp),
        color = Surface,
        border = BorderStroke(1.dp, if (enabled) Border else Border.copy(alpha = 0.5f)),
        interactionSource = interaction
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 15.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (iconRes != null) {
                Icon(
                    painter = painterResource(iconRes),
                    contentDescription = null,
                    tint = if (enabled) Logo else Logo.copy(alpha = 0.4f),
                    modifier = Modifier.size(20.dp)
                )
            }
            Text(
                text = label.uppercase(),
                style = TerminalLabel,
                color = if (enabled) TextPrimary else TextPrimary.copy(alpha = 0.4f)
            )
        }
    }
}
