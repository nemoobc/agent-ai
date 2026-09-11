package com.syntax.wallet.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val SyntaxScheme = darkColorScheme(
    primary = Logo,
    onPrimary = Bg,
    secondary = TextSecondary,
    onSecondary = Bg,
    background = Bg,
    onBackground = TextPrimary,
    surface = Surface,
    onSurface = TextPrimary,
    surfaceVariant = SurfaceHi,
    onSurfaceVariant = TextSecondary,
    outline = Border,
    error = Err,
    onError = Bg
)

@Composable
fun SyntaxTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = SyntaxScheme,
        typography = Typography,
        content = content
    )
}
