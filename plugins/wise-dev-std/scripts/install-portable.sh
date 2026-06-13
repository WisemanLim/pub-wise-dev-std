#!/usr/bin/env bash
# Cursor·Antigravity 전용 설치/패키징 스크립트 / Dedicated Cursor & Antigravity installer.
# 표준(AGENTS.md)을 대상 프로젝트에 설치하고 IDE별 규칙 파일을 함께 배치한다.
#   - AGENTS.md                              : Claude Code / Cursor / Antigravity 공통(둘 다 읽음)
#   - .cursor/rules/wise-dev-std.mdc    : Cursor 전용(alwaysApply)
#   - .antigravity/rules.md                  : Antigravity 전용 규칙(AGENTS.md 미러)
#
# 사용 / usage:
#   install-portable.sh [target-dir] [--force] [--zip] [--cursor-only|--antigravity-only]
#     target-dir        설치 위치(기본: 현재 디렉터리 / default CWD)
#     --force           기존 파일 덮어쓰기(기본: 보존 후 .generated)
#     --zip             대상에 설치하지 않고 배포용 wise-dev-std-portable.zip 패키징
#     --cursor-only     Cursor 규칙만 / --antigravity-only  Antigravity 규칙만 (기본: 둘 다 + AGENTS.md)
set -euo pipefail

target="${1:-$PWD}"; [[ "${target}" == --* ]] && target="$PWD"
force=false; zip=false; mode=both
for a in "$@"; do
  case "$a" in
    --force) force=true ;;
    --zip) zip=true ;;
    --cursor-only) mode=cursor ;;
    --antigravity-only) mode=antigravity ;;
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

emit_agents()    { cat "${tpl}"; }
emit_cursor()    { cursor_frontmatter; cat "${tpl}"; }
emit_antigravity() { echo "# Wise 개발환경 표준 / Antigravity rules"; echo "> AGENTS.md 미러. Antigravity 는 AGENTS.md 와 본 파일을 컨텍스트로 읽습니다."; echo; cat "${tpl}"; }

install_into() {  # $1 = destination dir
  local dst="$1"
  write_file "${dst}/AGENTS.md" emit_agents
  if [[ "${mode}" == both || "${mode}" == cursor ]]; then
    write_file "${dst}/.cursor/rules/wise-dev-std.mdc" emit_cursor
  fi
  if [[ "${mode}" == both || "${mode}" == antigravity ]]; then
    write_file "${dst}/.antigravity/rules.md" emit_antigravity
  fi
}

if [[ "${zip}" == true ]]; then
  staging="$(mktemp -d)"
  mode=both
  install_into "${staging}" >/dev/null
  zip_path="${target}/wise-dev-std-portable.zip"
  ( cd "${staging}" && zip -qr "${zip_path}" . )
  rm -rf "${staging}"
  echo "PACKAGED: ${zip_path}  (압축 해제 후 프로젝트 루트에 복사 / unzip into project root)"
  exit 0
fi

install_into "${target}"
echo "DONE. Cursor·Antigravity 재시작/리로드 시 자동 인식 / reload Cursor·Antigravity to pick up."
