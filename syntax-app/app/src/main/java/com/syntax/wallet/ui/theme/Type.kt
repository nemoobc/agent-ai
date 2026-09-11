package com.syntax.wallet.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/** Semua teks monospace — identitas terminal. */
val TerminalStyle = TextStyle(
    fontFamily = FontFamily.Monospace,
    fontSize = 13.sp,
    lineHeight = 19.sp,
    color = TextPrimary
)

val TerminalBold = TextStyle(
    fontFamily = FontFamily.Monospace,
    fontSize = 13.sp,
    lineHeight = 19.sp,
    fontWeight = FontWeight.Bold,
    color = TextPrimary
)

val TerminalTitle = TextStyle(
    fontFamily = FontFamily.Monospace,
    fontSize = 20.sp,
    fontWeight = FontWeight.Bold,
    letterSpacing = 4.sp,
    color = TextPrimary
)

val TerminalLabel = TextStyle(
    fontFamily = FontFamily.Monospace,
    fontSize = 14.sp,
    fontWeight = FontWeight.Medium,
    letterSpacing = 2.sp,
    color = TextPrimary
)

val TerminalSmall = TextStyle(
    fontFamily = FontFamily.Monospace,
    fontSize = 11.sp,
    lineHeight = 16.sp,
    color = TextSecondary
)

val Typography = Typography(
    bodyLarge = TerminalStyle,
    bodyMedium = TerminalStyle,
    bodySmall = TerminalSmall,
    titleLarge = TerminalTitle,
    labelLarge = TerminalLabel
)
