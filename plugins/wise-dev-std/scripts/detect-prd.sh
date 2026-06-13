#!/usr/bin/env bash
# SessionStart hook / SessionStart 훅:
#   PRD.md 가 있고 아직 스캐폴딩 흔적이 없으면 플러그인 사용을 1줄 제안.
#   If PRD.md exists and no scaffold trace yet, suggest the plugin (one line).
#   출력은 stdout → Claude 컨텍스트에 추가됨. 조용하게 동작 / output goes to context; stay quiet.
set -euo pipefail

dir="${CLAUDE_PROJECT_DIR:-$PWD}"

prd=""
for c in "PRD.md" "prd.md" "docs/PRD.md" "docs/prd.md"; do
  if [[ -f "${dir}/${c}" ]]; then prd="${c}"; break; fi
done

# 이미 스캐폴딩된 흔적이 있으면 침묵 (PRD 유무 무관)
if [[ -f "${dir}/Makefile" || -f "${dir}/docker-compose.yml" || -f "${dir}/AGENTS.md" ]]; then
  exit 0
fi

# PRD 없음 → 작성 도우미 1줄 제안 / no PRD → suggest the PRD helper
if [[ -z "${prd}" ]]; then
  echo "[wise-dev-std] PRD.md 없음 / not found. 작성 어려우면 설문으로 초안 생성: /wise-dev-std:prd (이후 recommend → scaffold → env-init → implement)."
  exit 0
fi

echo "[wise-dev-std] '${prd}' 감지됨 / detected. 스택 추천 recommend → 구조 생성 scaffold → 환경 env-init → 구현·시험 implement. (/wise-dev-std:<command>)"
exit 0
