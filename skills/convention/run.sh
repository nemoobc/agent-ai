#!/usr/bin/env bash
# convention — scan repo untuk konvensi: stack, naming, folder, style
# Menulis hasil ke .opencode/memory/conventions.md
# Usage: bash skills/convention/run.sh [root_dir]
set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { bad "Direktori tidak ditemukan: $ROOT"; exit 1; }

DATE=$(date '+%Y-%m-%d %H:%M:%S')
OUTPUT_DIR=".opencode/memory"
OUTPUT_FILE="$OUTPUT_DIR/conventions.md"

echo ""
p "═══════════════════════════════════════════" 33
p "         📐 CONVENTION — REPO SCANNER       " 33
p "═══════════════════════════════════════════" 33
echo ""

# ── BLOK 1: Deteksi stack ─────────────────────────────────────
echo ""
p "▸ BLOK 1: DETEKSI STACK" 45

STACK="unknown"
FRAMEWORK="unknown"
PKG_MANAGER="unknown"
RUNTIME="unknown"

if [ -f "package.json" ]; then
  STACK="node/javascript"
  PKG_MANAGER="npm"
  [ -f "yarn.lock" ] && PKG_MANAGER="yarn"
  [ -f "pnpm-lock.yaml" ] && PKG_MANAGER="pnpm"
  [ -f "bun.lockb" ] && PKG_MANAGER="bun"
  grep -q '"typescript"' package.json 2>/dev/null && STACK="node/typescript"
  grep -q '"react"' package.json 2>/dev/null && FRAMEWORK="react"
  grep -q '"next"' package.json 2>/dev/null && FRAMEWORK="nextjs"
  grep -q '"vue"' package.json 2>/dev/null && FRAMEWORK="vue"
  grep -q '"nuxt"' package.json 2>/dev/null && FRAMEWORK="nuxt"
  grep -q '"svelte"' package.json 2>/dev/null && FRAMEWORK="svelte"
  grep -q '"express"' package.json 2>/dev/null && FRAMEWORK="express"
  grep -q '"fastify"' package.json 2>/dev/null && FRAMEWORK="fastify"
  grep -q '"nestjs\|@nestjs"' package.json 2>/dev/null && FRAMEWORK="nestjs"
fi

if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
  STACK="python"
  PKG_MANAGER="pip"
  [ -f "pyproject.toml" ] && grep -q 'poetry' pyproject.toml 2>/dev/null && PKG_MANAGER="poetry"
  [ -f "pyproject.toml" ] && grep -q 'uv' pyproject.toml 2>/dev/null && PKG_MANAGER="uv"
  [ -f "manage.py" ] && FRAMEWORK="django"
  grep -qE 'fastapi|flask|starlette' requirements.txt 2>/dev/null && FRAMEWORK="fastapi/flask"
fi

if [ -f "go.mod" ]; then
  STACK="go"
  PKG_MANAGER="go modules"
  RUNTIME=$(grep '^go ' go.mod 2>/dev/null | awk '{print "go"$2}' || echo "go")
fi

if [ -f "Cargo.toml" ]; then
  STACK="rust"
  PKG_MANAGER="cargo"
fi

if [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
  STACK="java"
  [ -f "pom.xml" ] && PKG_MANAGER="maven"
  [ -f "build.gradle" ] && PKG_MANAGER="gradle"
fi

ok "Stack       : $STACK"
ok "Framework   : $FRAMEWORK"
ok "Pkg Manager : $PKG_MANAGER"

# ── BLOK 2: Konvensi naming ───────────────────────────────────
echo ""
p "▸ BLOK 2: KONVENSI NAMING" 45

NAMING_FILES=""
NAMING_FUNCS=""
NAMING_VARS=""

# Deteksi dari sample file
SAMPLE_FILE=""
if [ -d "src" ]; then
  SAMPLE_FILE=$(find src -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) 2>/dev/null | head -1)
fi
[ -z "$SAMPLE_FILE" ] && SAMPLE_FILE=$(find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) -not -path './node_modules/*' 2>/dev/null | head -1)

case "$STACK" in
  node/typescript|node/javascript)
    NAMING_FILES="kebab-case (e.g. user-service.ts)"
    NAMING_FUNCS="camelCase (e.g. getUserById)"
    NAMING_VARS="camelCase; const/let (no var)"
    # Cek dari sample
    if [ -n "$SAMPLE_FILE" ]; then
      grep -qE '^export (default )?class [A-Z]' "$SAMPLE_FILE" 2>/dev/null && NAMING_FUNCS="PascalCase for classes, camelCase for functions"
    fi
    ;;
  python)
    NAMING_FILES="snake_case (e.g. user_service.py)"
    NAMING_FUNCS="snake_case (e.g. get_user_by_id)"
    NAMING_VARS="snake_case; UPPER_SNAKE for constants"
    ;;
  go)
    NAMING_FILES="snake_case (e.g. user_service.go)"
    NAMING_FUNCS="camelCase exported=PascalCase (e.g. GetUser)"
    NAMING_VARS="camelCase"
    ;;
  rust)
    NAMING_FILES="snake_case (e.g. user_service.rs)"
    NAMING_FUNCS="snake_case (e.g. get_user)"
    NAMING_VARS="snake_case; SCREAMING_SNAKE for constants"
    ;;
  *)
    NAMING_FILES="(tidak terdeteksi — cek manual)"
    NAMING_FUNCS="(tidak terdeteksi)"
    NAMING_VARS="(tidak terdeteksi)"
    ;;
esac

info "File naming : $NAMING_FILES"
info "Functions   : $NAMING_FUNCS"
info "Variables   : $NAMING_VARS"

# ── BLOK 3: Struktur folder ───────────────────────────────────
echo ""
p "▸ BLOK 3: STRUKTUR FOLDER" 45

FOLDER_STRUCT=$(find . -maxdepth 2 -type d \
  -not -path './.git' -not -path './.git/*' \
  -not -path './node_modules' -not -path './node_modules/*' \
  -not -path './.next/*' \
  -not -path './dist' -not -path './dist/*' \
  -not -path './build' -not -path './build/*' \
  -not -path './__pycache__' -not -path './__pycache__/*' \
  -not -path './target' -not -path './target/*' \
  2>/dev/null | sed 's|^\./||' | grep -v '^\.$' | sort)

echo "$FOLDER_STRUCT" | while IFS= read -r dir; do
  info "  $dir/"
done

# ── BLOK 4: Konvensi style ────────────────────────────────────
echo ""
p "▸ BLOK 4: STYLE KONVENSI" 45

LINTER="none"
FORMATTER="none"
TEST_RUNNER="none"

if [ -f "package.json" ]; then
  grep -q '"eslint"' package.json 2>/dev/null && LINTER="eslint"
  grep -q '"prettier"' package.json 2>/dev/null && FORMATTER="prettier"
  grep -q '"biome"' package.json 2>/dev/null && { LINTER="biome"; FORMATTER="biome"; }
  grep -qE '"(jest|vitest|mocha|playwright|cypress)"' package.json 2>/dev/null && \
    TEST_RUNNER=$(grep -oE '"(jest|vitest|mocha|playwright|cypress)"' package.json | head -1 | tr -d '"')
fi
[ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] && LINTER="eslint"
[ -f ".prettierrc" ] || [ -f "prettier.config.js" ] && FORMATTER="prettier"
[ -f "biome.json" ] && { LINTER="biome"; FORMATTER="biome"; }
[ -f "pytest.ini" ] || grep -q 'pytest' pyproject.toml 2>/dev/null && TEST_RUNNER="pytest"
[ -f "go.mod" ] && TEST_RUNNER="go test"
[ -f "Cargo.toml" ] && TEST_RUNNER="cargo test"

info "Linter      : $LINTER"
info "Formatter   : $FORMATTER"
info "Test runner : $TEST_RUNNER"

# ── BLOK 5: Tulis ke conventions.md ──────────────────────────
echo ""
p "▸ BLOK 5: MENYIMPAN CONVENTIONS.MD" 45

if ! mkdir -p "$OUTPUT_DIR" 2>/dev/null; then
  bad "Gagal membuat direktori: $OUTPUT_DIR"
  exit 1
fi

{
  echo "# Konvensi Proyek"
  echo ""
  echo "> Auto-generated oleh skills/convention/run.sh pada $DATE"
  echo ""
  echo "## Stack"
  echo ""
  echo "| Komponen    | Nilai              |"
  echo "|-------------|---------------------|"
  echo "| Stack       | $STACK             |"
  echo "| Framework   | $FRAMEWORK         |"
  echo "| Pkg Manager | $PKG_MANAGER       |"
  echo ""
  echo "## Naming Conventions"
  echo ""
  echo "| Tipe       | Konvensi            |"
  echo "|------------|---------------------|"
  echo "| File       | $NAMING_FILES       |"
  echo "| Functions  | $NAMING_FUNCS       |"
  echo "| Variables  | $NAMING_VARS        |"
  echo ""
  echo "## Struktur Folder"
  echo ""
  echo '```'
  echo "$FOLDER_STRUCT"
  echo '```'
  echo ""
  echo "## Tooling"
  echo ""
  echo "| Tool       | Nilai               |"
  echo "|------------|---------------------|"
  echo "| Linter     | $LINTER             |"
  echo "| Formatter  | $FORMATTER          |"
  echo "| Test       | $TEST_RUNNER        |"
  echo ""
  echo "## Notes"
  echo ""
  echo "- Update file ini setelah perubahan struktur signifikan"
  echo "- Jalankan: \`bash skills/convention/run.sh\` untuk refresh"
  echo ""
} > "$OUTPUT_FILE"

ok "conventions.md ditulis ke: $OUTPUT_FILE"

echo ""
p "═══════════════════════════════════════════" 33
p "         CONVENTION SELESAI               " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
