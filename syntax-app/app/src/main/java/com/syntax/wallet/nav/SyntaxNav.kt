package com.syntax.wallet.nav

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.syntax.wallet.data.WalletStore
import com.syntax.wallet.ui.screens.CreateWalletScreen
import com.syntax.wallet.ui.screens.ImportWalletScreen
import com.syntax.wallet.ui.screens.SplashScreen
import com.syntax.wallet.ui.screens.TerminalScreen
import com.syntax.wallet.ui.screens.WalletSelectScreen

@Composable
fun SyntaxNav() {
    val nav = rememberNavController()
    val context = LocalContext.current
    val store = remember { WalletStore(context) }

    NavHost(navController = nav, startDestination = "splash") {
        composable("splash") {
            SplashScreen(
                onDone = {
                    val target = if (store.exists()) "terminal" else "select"
                    nav.navigate(target) {
                        popUpTo("splash") { inclusive = true }
                    }
                }
            )
        }
        composable("select") {
            WalletSelectScreen(
                onCreate = { nav.navigate("create") },
                onImport = { nav.navigate("import") }
            )
        }
        composable("create") {
            CreateWalletScreen(
                onDone = {
                    nav.navigate("terminal") {
                        popUpTo("select") { inclusive = true }
                    }
                }
            )
        }
        composable("import") {
            ImportWalletScreen(
                onDone = {
                    nav.navigate("terminal") {
                        popUpTo("select") { inclusive = true }
                    }
                }
            )
        }
        composable("terminal") {
            TerminalScreen(
                onWiped = {
                    nav.navigate("select") {
                        popUpTo("terminal") { inclusive = true }
                    }
                }
            )
        }
    }
}
