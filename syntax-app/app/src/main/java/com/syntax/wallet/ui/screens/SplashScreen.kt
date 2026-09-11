package com.syntax.wallet.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.syntax.wallet.ui.components.LoadingBar
import com.syntax.wallet.ui.components.TerminalLogo
import com.syntax.wallet.ui.components.scanlines
import com.syntax.wallet.ui.theme.Bg
import com.syntax.wallet.ui.theme.TerminalSmall
import com.syntax.wallet.ui.theme.TerminalTitle
import com.syntax.wallet.ui.theme.TextDim
import com.syntax.wallet.ui.theme.TextSecondary
import kotlinx.coroutines.delay
import kotlin.math.roundToInt

private val BOOT_LINES = listOf(
    "boot: syntax v1.0.0",
    "init: keystore ................ ok",
    "load: bip39 wordlist .......... ok",
    "load: eip-7702 module ......... ok",
    "net:  rpc endpoints ........... ok"
)

/**
 * Splash: animasi logo ">_" (chevron digambar, underscore berkedip),
 * judul typewriter, boot log, loading bar — lalu navigasi otomatis.
 * Tap untuk skip.
 */
@Composable
fun SplashScreen(onDone: () -> Unit) {
    var finished by remember { mutableStateOf(false) }

    fun finish() {
        if (!finished) {
            finished = true
            onDone()
        }
    }

    val timeline = remember { Animatable(0f) }
    LaunchedEffect(Unit) {
        timeline.animateTo(1f, animationSpec = tween(3400, easing = LinearEasing))
        delay(120)
        finish()
    }

    val p = timeline.value
    val blinkTransition = rememberInfiniteTransition(label = "cursor")
    val blink by blinkTransition.animateFloat(
        initialValue = 1f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(480, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "cursor-alpha"
    )

    // fase turunan
    val chevronProgress = (p / 0.22f).coerceIn(0f, 1f)
    val underscoreVisible = p > 0.24f
    val titleChars = (((p - 0.30f) / 0.12f) * 6).roundToInt().coerceIn(0, 6)
    val bootVisibleCount = (((p - 0.44f) / 0.36f) * BOOT_LINES.size)
        .roundToInt().coerceIn(0, BOOT_LINES.size)
    val barProgress = ((p - 0.80f) / 0.20f).coerceIn(0f, 1f)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .scanlines()
            .clickable { finish() },
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(horizontal = 32.dp)
        ) {
            TerminalLogo(
                size = 120.dp,
                progress = chevronProgress,
                underscoreVisible = underscoreVisible && (blink > 0.3f)
            )

            Spacer(modifier = Modifier.height(28.dp))

            Text(
                text = "SYNTAX".take(titleChars) + if (titleChars in 0..5 && p > 0.32f) "▌" else "",
                style = TerminalTitle,
                color = TextSecondary
            )

            Spacer(modifier = Modifier.height(36.dp))

            Column(
                verticalArrangement = Arrangement.spacedBy(4.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                BOOT_LINES.take(bootVisibleCount).forEach { line ->
                    Text(
                        text = line,
                        style = TerminalSmall,
                        color = TextDim
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))

            if (p > 0.80f) {
                LoadingBar(progress = barProgress)
            }
        }
    }
}
