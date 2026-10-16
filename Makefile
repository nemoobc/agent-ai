# DEV-BRAIN DOCTRINE — Makefile satu tombol
# Semua gerbang kit dipanggil dari sini. `make verify` = gerbang penuh HUKUM 9.

SHELL := bash
.PHONY: lint test eval e2e demo update mutation bench web-sync verify audit doctor install-check zip help

help: ## Daftar semua target
	@grep -E '^[a-zA-Z_-]+:.*##' Makefile | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

lint: ## Validasi struktur kit
	bash tests/lint-kit.sh

test: ## Self-test utama
	bash tests/self-test.sh

eval: ## Eval regresi perilaku kit (klaim palsu, injeksi, guard)
	bash tests/eval.sh

e2e: ## Simulasi pipeline agent penuh
	bash tests/e2e-flow.sh

demo: ## Demo flow cepat
	bash tests/run-demo.sh

update: ## Uji update flow (upgrade + anti-downgrade, tanpa jaringan)
	bash tests/test-update.sh

mutation: ## Bukti detektor: 15 perusakan harus ditangkap gate
	bash tests/mutation.sh

bench: ## Ukur durasi tiap gate, deteksi drift
	bash tests/bench.sh

web-sync: ## Cek data.json sinkron dengan kit (generate + verifikasi)
	bash tests/web-sync.sh

audit: ## Audit penuh
	bash skills/audit-full/run.sh

doctor: ## Periksa kesehatan kit
	bash skills/doctor/run.sh

install-check: ## Uji installer offline (deterministik)
	T=$$(mktemp -d); HOME="$$T" bash install.sh --offline >/dev/null 2>&1 && echo "install --offline OK"

verify: lint test eval e2e demo update mutation bench web-sync audit doctor ## Gerbang penuh HUKUM 9

zip: ## Buat arsip kit (tanpa .git) — tmp portabel (Termux tanpa /tmp)
	@command -v zip >/dev/null || { echo "ZIP: 'zip' tidak terpasang — pkg install zip / apt-get install zip"; exit 1; }; \
	V=$$(cat VERSION); TMPD=$$(mktemp -d); \
	cp -r . "$$TMPD/agent-ai-v$$V" --parents $$(git ls-files 2>/dev/null || find . -type f -not -path './.git/*') >/dev/null 2>&1 || cp -r . "$$TMPD/agent-ai-v$$V"; \
	cd "$$TMPD/agent-ai-v$$V" && rm -rf .git && cd "$$TMPD" && zip -rq "agent-ai-v$$V.zip" "agent-ai-v$$V" && echo "ZIP: $$TMPD/agent-ai-v$$V.zip"