#!/usr/bin/env bash
# 구버전 호환 심 / legacy shim — install-portable.sh --cursor-only 로 위임.
# 사용 / usage: export-portable.sh [target-dir]
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/install-portable.sh" "${1:-$PWD}" --cursor-only
