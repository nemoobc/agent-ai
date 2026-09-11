package com.syntax.wallet.data

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Penyimpanan dompet terenkripsi:
 * - mnemonic dienkripsi AES-256-GCM dengan kunci dari AndroidKeyStore (tidak pernah keluar hardware)
 * - ciphertext + IV disimpan di SharedPreferences
 */
class WalletStore(context: Context) {

    private val prefs = context.getSharedPreferences("syntax_vault", Context.MODE_PRIVATE)
    private val keyAlias = "syntax_master"
    private val cipherTransformation = "AES/GCM/NoPadding"

    fun exists(): Boolean = prefs.contains(FIELD_VAULT)

    fun address(): String? = prefs.getString(FIELD_ADDRESS, null)

    fun chainName(): String = prefs.getString(FIELD_CHAIN, Chains.MAINNET.name) ?: Chains.MAINNET.name

    fun setChainName(name: String) {
        prefs.edit().putString(FIELD_CHAIN, name).apply()
    }

    fun customRpc(): String? = prefs.getString(FIELD_RPC, null)

    fun setCustomRpc(url: String?) {
        if (url == null) prefs.edit().remove(FIELD_RPC).apply()
        else prefs.edit().putString(FIELD_RPC, url).apply()
    }

    /** Simpan rahasia dompet (mnemonic atau private key hex, terenkripsi) + address. */
    fun saveSecret(secret: String, address: String) {
        val cipher = Cipher.getInstance(cipherTransformation)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey())
        val iv = cipher.iv
        val ct = cipher.doFinal(secret.toByteArray(Charsets.UTF_8))
        val blob = ByteArray(iv.size + ct.size)
        iv.copyInto(blob, 0)
        ct.copyInto(blob, iv.size)
        val b64 = android.util.Base64.encodeToString(blob, android.util.Base64.NO_WRAP)
        prefs.edit()
            .putString(FIELD_VAULT, b64)
            .putString(FIELD_ADDRESS, address)
            .apply()
    }

    /** Muat rahasia dompet (dekripsi). Null jika belum ada / rusak. */
    fun loadSecret(): String? {
        val b64 = prefs.getString(FIELD_VAULT, null) ?: return null
        return try {
            val blob = android.util.Base64.decode(b64, android.util.Base64.NO_WRAP)
            require(blob.size > 12) { "blob terenkripsi terlalu pendek" }
            val iv = blob.copyOfRange(0, 12)
            val ct = blob.copyOfRange(12, blob.size)
            val cipher = Cipher.getInstance(cipherTransformation)
            cipher.init(Cipher.DECRYPT_MODE, getOrCreateKey(), GCMParameterSpec(128, iv))
            String(cipher.doFinal(ct), Charsets.UTF_8)
        } catch (e: Exception) {
            null
        }
    }

    fun wipe() {
        prefs.edit().clear().apply()
        // hapus juga kunci master dari AndroidKeyStore (wipe total)
        runCatching {
            val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            ks.deleteEntry(keyAlias)
        }
    }

    private fun getOrCreateKey(): SecretKey {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (ks.getKey(keyAlias, null) as? SecretKey)?.let { return it }
        val gen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        gen.init(
            KeyGenParameterSpec(
                keyAlias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
        )
        return gen.generateKey()
    }

    companion object {
        private const val FIELD_VAULT = "vault"
        private const val FIELD_ADDRESS = "address"
        private const val FIELD_CHAIN = "chain"
        private const val FIELD_RPC = "rpc"
    }
}
