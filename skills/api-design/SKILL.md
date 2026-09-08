---
description: API-DESIGN — kontrak API sebelum implementasi: endpoint/route, skema request/response, error code, versi, contoh curl. Konsisten & terdokumentasi.
---

# API-DESIGN

API = kontrak. Sekali keluar, sulit ditarik. Desain dulu, koding belakangan.

## KAPAN
Fase BAYANG (task architect) setiap kali menambah/mengubah endpoint, route, event, atau publik interface apa pun.

## CARA
1. **KONVENSI** — baca API lama dulu: gaya path, penamaan, format error. Konsisten > ideal. 
2. **KONTRAK** — per endpoint:
   - METHOD + path (kata benda jamak, kata kerja via HTTP method)
   - request: params/body/skema + validasi
   - response sukses: skema + contoh JSON
   - error: kode + pesan + kapan terjadi
3. **VERSI** — perubahan breaking? versi baru (`/v2/…`) atau catat deprecation, jangan diam-diam ubah.
4. **CONTOH** — 1 curl per endpoint penting, masuk plan.
5. **DOK** — endpoint publik baru = perubahan user-visible → skill doc-full.
6. **TEST** — kontrak jadi test: sukses + error → skill test-design.

## GERBANG
- Endpoint tanpa skema error = temuan P2 (audit).
- Breaking change tanpa versi/deprecation = temuan P1.
- Implementasi mendahului kontrak = mundur: tulis kontrak dulu, baru koding ulang bagian yang menyimpang.
