---
description: "표준을 AGENTS.md + 멀티-IDE 규칙으로 내보내 Cursor·Windsurf·Copilot·Gemini·Cline·Roo·Antigravity 준용 / Export the standard to AGENTS.md + per-IDE rule files"
argument-hint: "[profile-id] [--domain <id>] [--no-cursor] [--no-windsurf] [--no-copilot] [--no-gemini] [--no-cline] [--no-roo] [--no-antigravity]"
allowed-tools: Read, Glob, Write, Bash
---

# /wise-dev-std:standardize

목표: Claude 플러그인의 표준을 **IDE 중립 포맷**으로 내보내 모든 주요 AI 코딩 도구에서 동일 표준 준수.

배경: 각 IDE/도구는 아래 파일을 컨텍스트로 읽는다.
| 파일 | 도구 |
|---|---|
| `AGENTS.md` | Claude Code, Codex (OpenAI), Cursor, Antigravity |
| `.cursor/rules/wise-dev-std.mdc` | Cursor (`alwaysApply: true`) |
| `.windsurf/rules/wise-dev-std.md` | Windsurf |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `GEMINI.md` | Gemini CLI |
| `.clinerules` | Cline |
| `.roo/rules/wise-dev-std.md` | Roo Code |
| `.antigravity/rules.md` | Antigravity |

인자: `$ARGUMENTS` (선택) — 특정 프로파일만 강조하려면 id 전달.

인자 추가: `--domain <domain-id>` (선택) — 업종 오버레이를 AGENTS.md 에 반영.

실행:
1. `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md` 템플릿을 읽는다.
2. profile-id 가 있으면 `profiles/<id>.yaml` 요약을 "현재 프로젝트 기본 스택" 섹션에 삽입.
   `--domain` 또는 프로젝트의 `COMPLIANCE.md` 가 있으면 도메인 규제·데이터등급 요약을
   "업종/업태(도메인) 표준" 섹션에 삽입(domains/<id>.yaml 의 korea_regulations·data_classes 핵심).
3. 대상 프로젝트 루트에 생성 (기본: 전체, `--no-X` 플래그로 개별 건너뜀):
   - `AGENTS.md` — Claude Code / Codex / Cursor / Antigravity 공통
   - `.cursor/rules/wise-dev-std.mdc` — Cursor (`alwaysApply: true`)
   - `.windsurf/rules/wise-dev-std.md` — Windsurf
   - `.github/copilot-instructions.md` — GitHub Copilot
   - `GEMINI.md` — Gemini CLI
   - `.clinerules` — Cline
   - `.roo/rules/wise-dev-std.md` — Roo Code
   - `.antigravity/rules.md` — Antigravity (AGENTS.md 미러)
4. **전용 설치 스크립트 안내** — 셸에서 직접 설치/패키징하려면:
   - `${CLAUDE_PLUGIN_ROOT}/scripts/install-portable.sh <target-dir>` — 전체 IDE 규칙 일괄 설치
     (멱등; 기존 파일은 `.generated` 보존, `--force` 로 덮어쓰기).
     - `--cursor-only` / `--windsurf-only` / `--copilot-only` / `--antigravity-only` 로 단일 IDE만.
     - `--no-cursor` / `--no-windsurf` / `--no-copilot` / `--no-gemini` / `--no-cline` / `--no-roo` / `--no-antigravity` 로 개별 제외.
     - `--zip` 으로 배포용 `wise-dev-std-portable.zip` 패키징.
   - (구버전 호환) `${CLAUDE_PLUGIN_ROOT}/scripts/export-portable.sh <target-dir>` — AGENTS.md + Cursor 규칙만.
5. 결과 안내: "각 IDE는 재시작/리로드 시 해당 규칙 파일을 자동 인식합니다."

규칙: 기존 `AGENTS.md` 가 있으면 덮어쓰지 말고 표준 섹션만 병합 제안(스크립트도 동일하게 `.generated` 로 보존).
