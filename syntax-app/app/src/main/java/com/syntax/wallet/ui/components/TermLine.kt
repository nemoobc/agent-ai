package com.syntax.wallet.ui.components

/** Satu baris output terminal. */
enum class LineType { CMD, OUT, OK, ERR, WARN, DIM, HEAD }

data class TermLine(
    val id: Long,
    val text: String,
    val type: LineType = LineType.OUT
)
