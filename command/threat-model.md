---
description: Peta ancaman surface baru: aset, aktor, jalur, dampak, mitigasi — sebelum koding, sejalan dengan red-team
agent: dev
---
TUGAS: /threat-model <fitur>

1. Tentukan surface: auth, pembayaran, data user, endpoint publik, upload, integrasi luar.
2. Tulis model (maks 20 baris): ASET / AKTOR / JALUR / DAMPAK (P0–P3) / MITIGASI / SISA (risiko diterima + persetujuan user).
3. Jalur P0/P1 tanpa mitigasi konkret → masuk SISA, minta keputusan user (opsi bernomor + angka, HUKUM 7).
4. Masukkan mitigasi ke spesifikasi/plan SEBELUM coder mulai.
5. Setelah bangun: red-team WAJIB — uji jalur yang dipetakan satu per satu.

## Usage

```
/threat-model [fitur/endpoint]
```

- `fitur/endpoint` — apa yang akan dipetakan ancamannya

## Triggers

- **skill threat-model** — pemetaan ancaman
- **skill red-team** — uji jalur ancaman setelah build
- **skill plan** — masukkan mitigasi ke plan

## Example

```
/threat-model login endpoint
/threat-model payment integration
/threat-model file upload API
```

## Expected Output

```
THREAT MODEL — login endpoint
ASET        : credential user, session token, password hash
AKTOR       : attacker external, insider, automated bot
JALUR       : brute force, credential stuffing, session hijack
DAMPAK      : P0 (akun compromise), P1 (data leak)
MITIGASI    : rate limit + MFA + session rotation
SISA        : phishing (risiko diterima, user setuju)
RED-TEAM    : belum dilakukan (SEBELUM build)
```

## Error Cases

- **Fitur tidak jelas** → minta spesifikasi
- **Tidak ada surface** → lapor "tidak ada surface ancaman"
- **Mitigasi tidak konkret** → minta user putuskan (HUKUM 7)

## Related Commands

- `/audit** — audit mencakup aspek keamanan
- `/critique** — serangan adversarial ke kode
- `/review** — review kode sebelum merge
