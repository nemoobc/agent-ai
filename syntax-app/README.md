# Syntax — EIP-7702 Terminal Wallet

Aplikasi Android dompet Ethereum dengan tema terminal, dukungan penuh **EIP-7702**
(delegasi EOA ke kode kontrak — Pectra).

## Fitur

| Fitur | Command / UI | Keterangan |
|---|---|---|
| Splash animasi | otomatis | Logo `>_` digambar bertahap + boot log + loading bar `[████░░]` |
| Buat dompet | tombol CREATE | 12 kata seed BIP-39 + konfirmasi tebak kata + output terminal |
| Import dompet | tombol IMPORT | mnemonic 12/24 kata ATAU private key `0x…` (validasi live) |
| Saldo | `balance` | `eth_getBalance` via RPC publik |
| Nonce | `nonce` | `eth_getTransactionCount` |
| Status delegasi | `status` | `eth_getCode` → parse `0xef0100…` |
| Delegasi 7702 | `delegate <0xaddr>` | sign otorisasi + broadcast tx type-4 (konfirmasi y/N) |
| Hapus delegasi | `undelegate` | otorisasi ke `0x…dEaD` sesuai spesifikasi final EIP-7702 |
| Kirim ETH | `send <to> <amount>` | transaksi legacy EIP-155 + konfirmasi + explorer link |
| Tanda tangan | `sign <msg>` | EIP-191 personal_sign |
| Chain | `set chain mainnet\|sepolia` | preset RPC publik gratis |
| RPC custom | `set rpc <url>` / `set rpc reset` | endpoint JSON-RPC apa pun |
| Lainnya | `help` `version` `address` `history` `clear` `wipe` `exit` | |

## Keamanan

- Mnemonic/private key dienkripsi **AES-256-GCM** dengan kunci **AndroidKeyStore**
  (kunci tidak pernah keluar dari hardware keystore).
- Semua kripto murni Kotlin — **tanpa dependensi pihak ketiga**:
  Keccak-256, secp256k1 (RFC 6979), RLP, BIP-39, BIP-32, EIP-55/155/191/7702.
- Terverifikasi terhadap **test vector resmi** (lihat `app/src/test/`):
  - Keccak: `""` → `c5d2…470`, `"abc"` → `4e03…c45`
  - EIP-155: vektor resmi (r/s/v) dari spec
  - BIP-39: vektor trezor (`abandon…about` → seed `5eb0…e4`)
  - BIP-32: test vector #1 (master + `m/0'`)
  - End-to-end: mnemonic `abandon…about` → `0x9858EfFD232B4033E47d90003D41EC34EcaEda94`
  - EIP-55: 6 alamat kanonik dari spec

## Build

1. Buka folder `syntax-app/` di **Android Studio** (Hedgehog+).
2. Gradle sync otomatis (AGP 8.5.2, Kotlin 2.0.20, Compose BOM 2024.09).
3. Run `:app` → install ke device/emulator (minSdk 26).
4. Unit test: `./gradlew :app:testDebugUnitTest` (vektor resmi di atas).

## Struktur

```
syntax-app/
├── app/src/main/java/com/syntax/wallet/
│   ├── crypto/          # Keccak256, Secp256k1, Rlp, Bip39, Bip32, Eip55/155/191/7702, WalletCore
│   ├── data/            # WalletStore (Keystore AES-GCM), RpcClient (JSON-RPC), Json, Chains
│   ├── util/            # Amount (ETH<->wei)
│   ├── nav/             # SyntaxNav (splash → select → create/import → terminal)
│   └── ui/
│       ├── theme/       # palet hitam-tidak-pekat + abu-abu, monospace
│       ├── components/  # TerminalLogo (Canvas), LoadingBar, TermButton, TerminalView (scanline)
│       └── screens/     # Splash, WalletSelect, CreateWallet, ImportWallet, Terminal(+VM)
├── app/src/main/res/drawable/  # 14 icon vector custom (tanpa emoji)
└── app/src/test/        # 8 file test JUnit, vektor resmi
```

## Catatan

- RPC default: `publicnode.com` (mainnet/sepolia, gratis, tanpa API key).
- `delegate` menandatangani otorisasi secara lokal; broadcast butuh gas (y/N).
- Icon semua dibuat sendiri sebagai vector drawable — tidak ada emoji.
