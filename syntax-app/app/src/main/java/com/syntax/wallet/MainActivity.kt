package com.syntax.wallet

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.syntax.wallet.nav.SyntaxNav
import com.syntax.wallet.ui.theme.SyntaxTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Cegah screenshot/recents-preview: seed phrase & private key tidak boleh bocor.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        setContent {
            SyntaxTheme {
                SyntaxNav()
            }
        }
    }
}
