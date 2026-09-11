package com.syntax.wallet.data

/** Preset chain + RPC publik gratis. */
data class ChainPreset(
    val id: Long,
    val name: String,
    val rpc: String,
    val explorer: String
)

object Chains {
    val MAINNET = ChainPreset(
        id = 1,
        name = "mainnet",
        rpc = "https://ethereum-rpc.publicnode.com",
        explorer = "https://etherscan.io"
    )
    val SEPOLIA = ChainPreset(
        id = 11155111,
        name = "sepolia",
        rpc = "https://ethereum-sepolia-rpc.publicnode.com",
        explorer = "https://sepolia.etherscan.io"
    )

    val ALL = listOf(MAINNET, SEPOLIA)

    fun byName(name: String): ChainPreset? = ALL.firstOrNull { it.name == name.lowercase() }
}
