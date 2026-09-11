package com.syntax.wallet.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.syntax.wallet.ui.theme.Bg
import com.syntax.wallet.ui.theme.Err
import com.syntax.wallet.ui.theme.Logo
import com.syntax.wallet.ui.theme.Ok
import com.syntax.wallet.ui.theme.TerminalStyle
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextPrimary
import com.syntax.wallet.ui.theme.TextSecondary
import com.syntax.wallet.ui.theme.Warn

/** Overlay scanline CRT tipis — identitas layar terminal. */
fun Modifier.scanlines(): Modifier = drawWithContent {
    drawContent()
    val shade = Color.Black.copy(alpha = 0.10f)
    var y = 0f
    while (y < size.height) {
        drawLine(shade, Offset(0f, y), Offset(size.width, y), strokeWidth = 1f)
        y += 3f
    }
}

@Composable
private fun colorFor(type: LineType): Color = when (type) {
    LineType.CMD -> TextPrimary
    LineType.OUT -> TextPrimary
    LineType.OK -> Ok
    LineType.ERR -> Err
    LineType.WARN -> Warn
    LineType.DIM -> TextDim
    LineType.HEAD -> Logo
}

@Composable
private fun weightFor(type: LineType): FontWeight? = when (type) {
    LineType.CMD, LineType.HEAD -> FontWeight.Bold
    else -> null
}

/** Area output terminal: auto-scroll ke bawah, styling per tipe baris. */
@Composable
fun TerminalView(
    lines: List<TermLine>,
    modifier: Modifier = Modifier
) {
    val listState = rememberLazyListState()
    LaunchedEffect(lines.size) {
        if (lines.isNotEmpty()) listState.animateScrollToItem(lines.size - 1)
    }
    LazyColumn(
        state = listState,
        modifier = modifier
            .fillMaxSize()
            .scanlines(),
        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 10.dp),
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        items(lines, key = { it.id }) { line ->
            Text(
                text = line.text,
                color = colorFor(line.type),
                fontWeight = weightFor(line.type),
                fontSize = 13.sp,
                lineHeight = 19.sp,
                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

/** Header kecil gaya terminal (di atas output). */
@Composable
fun TerminalHeader(text: String) {
    Column {
        Text(
            text = text,
            style = TerminalStyle.copy(color = TextSecondary),
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/** Latar utama terminal. */
@Composable
fun TerminalBackground(content: @Composable () -> Unit) {
    androidx.compose.foundation.layout.Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
    ) {
        content()
    }
}
