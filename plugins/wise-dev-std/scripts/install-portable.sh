#!/usr/bin/env bash
# 멀티-IDE 설치/패키징 스크립트 / Multi-IDE installer.
# 표준(AGENTS.md)을 대상 프로젝트에 설치하고 IDE별 규칙 파일을 함께 배치한다.
#   - AGENTS.md                                 : Claude Code / Codex / Cursor / Antigravity 공통
#   - .cursor/rules/wise-dev-std.mdc       : Cursor (alwaysApply)
#   - .windsurf/rules/wise-dev-std.md      : Windsurf
#   - .antigravity/rules.md                     : Antigravity
#   - .github/copilot-instructions.md           : GitHub Copilot
#   - GEMINI.md                                 : Gemini CLI
#   - .clinerules                               : Cline
#   - .roo/rules/wise-dev-std.md           : Roo Code
#
# 사용 / usage:
#   install-portable.sh [target-dir] [--force] [--zip]
#                       [--cursor-only|--antigravity-only|--windsurf-only|--copilot-only]
#                       [--no-cursor] [--no-antigravity] [--no-windsurf] [--no-copilot]
#                       [--no-gemini] [--no-cline] [--no-roo]
#     target-dir          설치 위치(기본: 현재 디렉터리 / default CWD)
#     --force             기존 파일 덮어쓰기(기본: 보존 후 .generated)
#     --zip               배포용 wise-dev-std-portable.zip 패키징
#     --cursor-only       Cursor 규칙만 (+ AGENTS.md)
#     --antigravity-only  Antigravity 규칙만 (+ AGENTS.md)
#     --windsurf-only     Windsurf 규칙만 (+ AGENTS.md)
#     --copilot-only      GitHub Copilot 규칙만 (+ AGENTS.md)
#     --no-X              특정 IDE 건너뜀 (기본: 전체 설치)
set -euo pipefail

target="${1:-$PWD}"; [[ "${target}" == --* ]] && target="$PWD"
force=false; zip=false
do_cursor=true; do_antigravity=true; do_windsurf=true
do_copilot=true; do_gemini=true; do_cline=true; do_roo=true

for a in "$@"; do
  case "$a" in
    --force) force=true ;;
    --zip) zip=true ;;
    # legacy single-IDE modes (backwards compat)
    --cursor-only)
      do_antigravity=false; do_windsurf=false; do_copilot=false
      do_gemini=false; do_cline=false; do_roo=false ;;
    --antigravity-only)
      do_cursor=false; do_windsurf=false; do_copilot=false
      do_gemini=false; do_cline=false; do_roo=false ;;
    --windsurf-only)
      do_cursor=false; do_antigravity=false; do_copilot=false
      do_gemini=false; do_cline=false; do_roo=false ;;
    --copilot-only)
      do_cursor=false; do_antigravity=false; do_windsurf=false
      do_gemini=false; do_cline=false; do_roo=false ;;
    # per-IDE skip flags
    --no-cursor)      do_cursor=false ;;
    --no-antigravity) do_antigravity=false ;;
    --no-windsurf)    do_windsurf=false ;;
    --no-copilot)     do_copilot=false ;;
    --no-gemini)      do_gemini=false ;;
    --no-cline)       do_cline=false ;;
    --no-roo)         do_roo=false ;;
  esac
done

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tpl="${plugin_root}/templates/AGENTS.md"
[[ -f "${tpl}" ]] || { echo "ERROR: 템플릿 없음 / template missing: ${tpl}" >&2; exit 1; }

cursor_frontmatter() {
  echo "---"
  echo "description: Wise 개발환경 표준 (FE/BE/DB/Ops/App, 언어·패키지매니저·환경 표준)"
  echo "alwaysApply: true"
  echo "---"
  echo
}

# 멱등 쓰기: 존재 시 --force 면 덮어쓰고, 아니면 .generated 로 / idempotent write
write_file() {  # $1=path  $2=producer-fn-or-cat
  local path="$1" producer="$2" out="$1"
  if [[ -f "${path}" && "${force}" != true ]]; then
    out="${path}.generated"
    echo "KEEP: ${path} 존재 — ${out} 로 작성(수동 병합) / exists, wrote ${out}"
  fi
  mkdir -p "$(dirname "${out}")"
  "${producer}" > "${out}"
  [[ "${out}" == "${path}" ]] && echo "WROTE: ${out}"
}

emit_agents()      { cat "${tpl}"; }
emit_cursor()      { cursor_frontmatter; cat "${tpl}"; }
emit_antigravity() { printf '# Wise 개발환경 표준 / Antigravity rules\n> AGENTS.md 미러.\n\n'; cat "${tpl}"; }
emit_windsurf()    { printf '# Wise 개발환경 표준 / Windsurf rules\n\n'; cat "${tpl}"; }
emit_copilot()     { cat "${tpl}"; }
emit_gemini()      { cat "${tpl}"; }
emit_cline()       { cat "${tpl}"; }
emit_roo()         { printf '# Wise 개발환경 표준 / Roo Code rules\n\n'; cat "${tpl}"; }

install_into() {  # $1 = destination dir
  local dst="$1"
  write_file "${dst}/AGENTS.md" emit_agents
  [[ "${do_cursor}"      == true ]] && write_file "${dst}/.cursor/rules/wise-dev-std.mdc"  emit_cursor
  [[ "${do_antigravity}" == true ]] && write_file "${dst}/.antigravity/rules.md"                emit_antigravity
  [[ "${do_windsurf}"    == true ]] && write_file "${dst}/.windsurf/rules/wise-dev-std.md" emit_windsurf
  [[ "${do_copilot}"     == true ]] && write_file "${dst}/.github/copilot-instructions.md"      emit_copilot
  [[ "${do_gemini}"      == true ]] && write_file "${dst}/GEMINI.md"                            emit_gemini
  [[ "${do_cline}"       == true ]] && write_file "${dst}/.clinerules"                          emit_cline
  [[ "${do_roo}"         == true ]] && write_file "${dst}/.roo/rules/wise-dev-std.md"      emit_roo
}

if [[ "${zip}" == true ]]; then
  staging="$(mktemp -d)"
  install_into "${staging}" >/dev/null
  zip_path="${target}/wise-dev-std-portable.zip"
  ( cd "${staging}" && zip -qr "${zip_path}" . )
  rm -rf "${staging}"
  echo "PACKAGED: ${zip_path}  (압축 해제 후 프로젝트 루트에 복사 / unzip into project root)"
  exit 0
fi

install_into "${target}"
echo "DONE. IDE 재시작/리로드 시 자동 인식 / reload IDE to pick up rules."
