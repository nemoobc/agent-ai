# DEV-BRAIN DOCTRINE — Makefile satu tombol
# Semua gerbang kit dipanggil dari sini. `make verify` = gerbang penuh HUKUM 9.

SHELL := bash
.PHONY: lint test e2e demo update mutation bench verify audit doctor install-check zip help

help: ## Daftar semua target
	@grep -E '^[a-zA-Z_-]+:.*##' Makefile | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

lint: ## Validasi struktur kit (135+ cek)
	bash tests/lint-kit.sh

test: ## Self-test utama (107+ cek)
	bash tests/self-test.sh

e2e: ## Simulasi pipeline agent penuh
	bash tests/e2e-flow.sh

demo: ## Demo flow cepat
	bash tests/run-demo.sh

update: ## Uji update flow (upgrade + anti-downgrade, tanpa jaringan)
	bash tests/test-update.sh

mutation: ## Bukti detektor: 6 perusakan harus ditangkap gate
	bash tests/mutation.sh

bench: ## Ukur durasi tiap gate, deteksi drift
	bash tests/bench.sh

audit: ## Audit penuh
	bash skills/audit-full/run.sh 2>/dev/null || true

doctor: ## Periksa kesehatan kit
	bash skills/doctor/run.sh

install-check: ## Uji installer offline (deterministik)
	T=$$(mktemp -d); HOME="$$T" bash install.sh --offline >/dev/null 2>&1 && echo "install --offline OK"

verify: lint test e2e demo update mutation bench ## Gerbang penuh HUKUM 9

zip: ## Buat arsip kit (tanpa .git)
	@V=$$(cat VERSION); \
	cd /tmp && rm -rf "agent-ai-v$$V" "agent-ai-v$$V.zip"; \
	cd - >/dev/null && cp -r . "/tmp/agent-ai-v$$V" --parents $$(git ls-files 2>/dev/null || find . -type f -not -path './.git/*') >/dev/null 2>&1 || cp -r . "/tmp/agent-ai-v$$V"; \
	cd "/tmp/agent-ai-v$$V" && rm -rf .git && cd /tmp && zip -rq "agent-ai-v$$V.zip" "agent-ai-v$$V" && echo "ZIP: /tmp/agent-ai-v$$V.zip"