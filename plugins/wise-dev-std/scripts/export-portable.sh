#!/usr/bin/env bash
# 표준을 IDE 중립 포맷으로 내보낸다 / Export the standard to an IDE-neutral format:
#   AGENTS.md (Claude/Cursor/Antigravity 공통 / shared) +
#   .cursor/rules/wise-dev-std.mdc (Cursor 전용 / Cursor-only).
# 사용 / usage: export-portable.sh [target-dir]
set -euo pipefail

target="${1:-$PWD}"
plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tpl="${plugin_root}/templates/AGENTS.md"

if [[ ! -f "${tpl}" ]]; then
  echo "ERROR: 템플릿 없음: ${tpl}" >&2
  exit 1
fi

mkdir -p "${target}/.cursor/rules"

# AGENTS.md — 기존 파일 보존
if [[ -f "${target}/AGENTS.md" ]]; then
  echo "SKIP: ${target}/AGENTS.md 이미 존재 — 수동 병합 권장."
else
  cp "${tpl}" "${target}/AGENTS.md"
  echo "WROTE: ${target}/AGENTS.md"
fi

# .cursor/rules/*.mdc — frontmatter 추가 후 본문 결합
mdc="${target}/.cursor/rules/wise-dev-std.mdc"
{
  echo "---"
  echo "description: Wise 개발환경 표준 (FE/BE/DB/Ops/App, 언어·패키지매니저·환경 표준)"
  echo "alwaysApply: true"
  echo "---"
  echo
  cat "${tpl}"
} > "${mdc}"
echo "WROTE: ${mdc}"

echo "DONE. Cursor·Antigravity 재시작/리로드 시 자동 인식."
