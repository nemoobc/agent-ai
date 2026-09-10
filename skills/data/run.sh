#!/usr/bin/env bash
# data/run.sh — cek tooling data science yang tersedia
set -u
echo "  ▸ data science tools:"
command -v python3 >/dev/null 2>&1 && echo "  ✔ python3: $(python3 --version 2>&1)" || echo "  · python3 tidak ada"
python3 -c "import pandas; print('  ✔ pandas', pandas.__version__)" 2>/dev/null || echo "  · pandas: pip install pandas"
python3 -c "import numpy; print('  ✔ numpy', numpy.__version__)" 2>/dev/null || echo "  · numpy: pip install numpy"
python3 -c "import matplotlib; print('  ✔ matplotlib')" 2>/dev/null || echo "  · matplotlib: pip install matplotlib"
python3 -c "import seaborn; print('  ✔ seaborn')" 2>/dev/null || echo "  · seaborn: pip install seaborn"
python3 -c "import openpyxl; print('  ✔ openpyxl')" 2>/dev/null || echo "  · openpyxl: pip install openpyxl"
command -v sqlite3 >/dev/null 2>&1 && echo "  ✔ sqlite3" || echo "  · sqlite3: apt install sqlite3"
command -v csvkit >/dev/null 2>&1 && echo "  ✔ csvkit" || echo "  · csvkit: pip install csvkit"
command -v jq >/dev/null 2>&1 && echo "  ✔ jq" || echo "  · jq: apt install jq"
echo "  → install lengkap: pip install pandas numpy matplotlib seaborn openpyxl csvkit"