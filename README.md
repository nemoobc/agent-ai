<!--
  AGENT AI — Kit orkestrasi agent AI untuk opencode
  v12.1.0 • 11 agent • 63 skill • 41 command
  by nemoobc
-->
<div align="center">

<svg width="50" height="50" viewBox="0 0 50 50" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="50" height="50" rx="10" fill="#1a1a2e"/>
  <text x="25" y="28" dominant-baseline="middle" text-anchor="middle" font-family="monospace" font-size="18" font-weight="bold" fill="#22D3EE">&gt;_</text>
</svg>

```
┌──────────────────────────┐
│      A G E N T  A I      │
└──────────────────────────┘
```

</div>

![version](https://img.shields.io/badge/VERSION-12.1.0-blue?style=for-the-badge&logo=github)
![agents](https://img.shields.io/badge/AGENTS-11-22c55e?style=for-the-badge&logo=robotframework)
![skills](https://img.shields.io/badge/SKILLS-63-f97316?style=for-the-badge&logo=apachemaven)
![commands](https://img.shields.io/badge/COMMANDS-41-a855f7?style=for-the-badge&logo=terminal)
![license](https://img.shields.io/badge/LICENSE-MIT-eab308?style=for-the-badge)
![author](https://img.shields.io/badge/BY-nemoobc-ff69b4?style=for-the-badge&logo=github)

</div>

---

## 💡 Kenapa Ini Ada

AI tanpa struktur = hasil acak. **AGENT AI** memberi AI **pipeline kerja tetap + 13 hukum** supaya output konsisten, teruji, dan bisa dipertanggungjawabkan. Cukup kasih satu kalimat — AI yang mikir, bangun, test, audit, dan lapor.

```text
> bikin fitur login

[DEV] MIKIR → RENCANA → BANGUN → TEST hijau → AUDIT CLEAN → SELESAI ✅
```

**Dibuat oleh [nemoobc](https://github.com/nemoobc)** — supaya AI bisa kerja lebih maksimal.

---

## 🚀 Instal

<table align="center">
<tr>
<td align="center" width="33%">

### 🌐 curl
```bash
curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh | bash
```

</td>
<td align="center" width="33%">

### 📦 bash
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh)
```

</td>
<td align="center" width="33%">

### 🔧 clone
```bash
git clone https://github.com/nemoobc/agent-ai.git
cd agent-ai && bash install.sh
```

</td>
</tr>
</table>

---

## 📁 Struktur

```text
agent-ai/
├── agents/     11 agent (DEV + 10 sub-agent)
├── skills/     63 skill (otomatis dipanggil)
├── command/    41 command (siap pakai)
├── tests/      8 test suite
├── memory/     persistent memory
├── docs/       dokumentasi lengkap
└── Makefile    make verify (satu tombol)
```

---

## ⚙️ Cara Pakai

```bash
# instal
bash install.sh

# verifikasi
make verify

# pakai di opencode
/bikin fitur X
```

---

## 📚 Dokumentasi

| Doc | Isi |
|-----|-----|
| [USAGE](docs/USAGE.md) | Cara pakai harian |
| [PLAYBOOKS](docs/PLAYBOOKS.md) | Resep situasi |
| [ARCHITECTURE](docs/ARCHITECTURE.md) | Arsitektur kit |
| [ROADMAP](docs/ROADMAP.md) | Rencana pengembangan |

---

## 📜 Lisensi

**[MIT License](LICENSE)** — bebas pakai, ubah, dan bagi.

<div align="center">

⭐ **Star & Fork — gratis, bikin semangat!** ⭐

**v12.1.0** • by [nemoobc](https://github.com/nemoobc)

</div>
