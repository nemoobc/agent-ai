---
description: API-DESIGN — kontrak API sebelum implementasi: endpoint/route, skema request/response, error code, versi, contoh curl. Konsisten & terdokumentasi. Sekali keluar, sulit ditarik.
---

# API-DESIGN

API = kontrak. Sekali keluar, sulit ditarik. Desain dulu, koding belakangan.

## APA YANG DILAKUKAN
Merancang kontrak interface sebelum implementasi: endpoint, skema data, error handling, versioning. API design = arsitektur komunikasi antar sistem.

## KAPAN WAJIB JALAN
Fase BAYANG (task architect) setiap kali:
1. Menambah endpoint/route baru
2. Mengubah endpoint yang sudah ada
3. Menambah event/message contract
4. Mengubah publik interface
5. Integrasi dengan system eksternal

## URUTAN KERJA

### 1. BACA KONVENSI
Baca API lama dulu: gaya path, penamaan, format error. Konsisten > ideal.
```
# Contoh konvensi yang perlu dibaca:
GET /users          → list
GET /users/:id      → detail
POST /users         → create
PATCH /users/:id    → update
DELETE /users/:id   → delete
```

### 2. TULIS KONTRAK (per endpoint)
```
METHOD /path

REQUEST:
  Params: { name: type, required: boolean }
  Body: { field: type }
  Headers: { Authorization: "Bearer <token>" }

RESPONSE (200):
  { field: type }

ERRORS:
  400: { error: "message", code: "INVALID_INPUT" }
  401: { error: "message", code: "UNAUTHORIZED" }
  404: { error: "message", code: "NOT_FOUND" }
  500: { error: "message", code: "INTERNAL_ERROR" }

CURL EXAMPLE:
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John"}'
```

### 3. VERSI
- Perubahan breaking → versi baru (`/v2/...`)
- Perubahan minor → endpoint yang sama
- Deprecation → catat timeline, jangan diam-diam ubah

### 4. DOK
- Endpoint publik baru = perubahan user-visible → skill doc-full

### 5. TEST
- Kontrak jadi test: sukses + error → skill test-design

## FORMAT LAPORAN
```
API-DESIGN:
ENDPOINT: METHOD /path
SKEMA    : request → response
ERRORS   : 400, 401, 404, 500
VERSI    : v1 (baru) / v2 (breaking change)
CURL     : 1 contoh per endpoint
```

## GERBANG
- Endpoint tanpa skema error = temuan P2 (audit)
- Breaking change tanpa versi/deprecation = temuan P1
- Implementasi mendahului kontrak = mundur: tulis kontrak dulu, baru koding ulang bagian yang menyimpang
- Tidak ada contoh curl = kontrak tidak lengkap

## INTEGRASI PIPELINE
```
THINK → API-DESIGN ← posisi skill ini → ARCHITECT → CODER → TEST-DESIGN
```
- Sebelum: think (keputusan), spec (spesifikasi perilaku)
- Sesudah: architect (desain teknis), coder (implementasi), test-design (kasus test)
- Berkaitan: `skill spec` (spesifikasi input/output), `skill doc-full` (dokumentasi endpoint)

## EDGE CASE
- GraphQL / gRPC / WebSocket → format kontrak berbeda, prinsip sama
- API internal vs publik → publik butuh versi, internal boleh breaking
- Backward compatibility → additive changes aman, removing/renaming = breaking
- API design-first (OpenAPI/Swagger) → tulis OpenAPI spec dulu

## ERROR HANDLING
- Konvensi lama tidak jelas → buat konvensi baru + dokumentasi
- Tim punya pendapat berbeda → protokol: konsistensi > preferensi pribadi
- Terlalu banyak endpoint → prioritas: core functionality dulu

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Implementasi mendahului kontrak → kode jadi kontrak, sulit diubah
- ❌ Skip error handling design → semua error = 500 = debugging mimpi buruk
- ❌ Tidak ada versi → breaking change tanpa jalan mundur
- ❌ Terlalu banyak endpoint sekaligus → MVP dulu, iterate
- ❌ Mengabaikan konvensi yang sudah ada → konsistensi > ideal
