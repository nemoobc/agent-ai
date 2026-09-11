package com.syntax.wallet.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathMeasure
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.syntax.wallet.ui.theme.Logo

/**
 * Logo Syntax ">_" — digambar Canvas (bukan emoji, bukan font):
 * chevron ">" digambar bertahap (progress 0..1), underscore "_" muncul + bisa berkedip.
 */
@Composable
fun TerminalLogo(
    size: Dp = 96.dp,
    progress: Float = 1f,
    underscoreVisible: Boolean = true,
    underscoreBlink: Boolean = false,
    strokeWidth: Dp = 9.dp,
    color: Color = Logo
) {
    Canvas(modifier = Modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height
        val strokePx = strokeWidth.toPx()

        // chevron ">"
        val chevron = Path().apply {
            moveTo(0.30f * w, 0.25f * h)
            lineTo(0.64f * w, 0.50f * h)
            lineTo(0.30f * w, 0.75f * h)
        }
        val measure = PathMeasure()
        measure.setPath(chevron, false)
        val drawLen = measure.length * progress.coerceIn(0f, 1f)
        if (drawLen > 0f) {
            val partial = Path()
            measure.getSegment(0f, drawLen, partial, true)
            drawPath(
                partial,
                color = color,
                style = Stroke(width = strokePx, cap = StrokeCap.Round, join = StrokeJoin.Round)
            )
        }

        // underscore "_"
        if (underscoreVisible) {
            drawLine(
                color = color,
                start = Offset(0.68f * w, 0.75f * h),
                end = Offset(0.88f * w, 0.75f * h),
                strokeWidth = strokePx,
                cap = StrokeCap.Round
            )
        }
    }
}

/** Underslogo berkedip (dipakai di splash & wallet select). */
@Composable
fun BlinkingTerminalLogo(size: Dp = 96.dp) {
    val transition = rememberInfiniteTransition(label = "logo-blink")
    val blink by transition.animateFloat(
        initialValue = 1f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "logo-blink-alpha"
    )
    TerminalLogo(
        size = size,
        progress = 1f,
        underscoreVisible = blink > 0.35f,
        underscoreBlink = false
    )
}
