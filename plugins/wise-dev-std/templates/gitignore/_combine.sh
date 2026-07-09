#!/usr/bin/env bash
# _combine.sh — 선택한 컴포넌트의 gitignore 프래그먼트를 병합합니다.
# 사용법: ./_combine.sh <fragment1> [fragment2 ...] > .gitignore
# 예시:   ./_combine.sh java node > .gitignore
#         ./_combine.sh csharp node > .gitignore
#         ./_combine.sh python node go > .gitignore
#
# 지원 키: node python go rust java kotlin csharp swift android flutter react-native c-cpp
# 항상 _common + _platform 이 맨 앞에 포함됩니다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -eq 0 ]]; then
  echo "사용법: $0 <fragment...>" >&2
  echo "예시:   $0 java node > .gitignore" >&2
  exit 1
fi

declare -A FRAGMENT_MAP=(
  [node]="node.gitignore"
  [python]="python.gitignore"
  [go]="go.gitignore"
  [rust]="rust.gitignore"
  [java]="java.gitignore"
  [kotlin]="android.gitignore"  # 플러그인 내 kotlin = android-compose (문서 매핑과 일치)
  [csharp]="csharp.gitignore"
  [swift]="swift.gitignore"
  [android]="android.gitignore"
  [flutter]="flutter.gitignore"
  [react-native]="react-native.gitignore"
  [c-cpp]="c-cpp.gitignore"
)

emit() {
  local file="$SCRIPT_DIR/$1"
  if [[ -f "$file" ]]; then
    cat "$file"
    echo ""
  else
    echo "# [경고] 프래그먼트 없음: $1" >&2
  fi
}

# 중복 출력 방지
declare -A EMITTED=()

emit_once() {
  local key="$1"
  local file="${2:-$key}"
  if [[ -z "${EMITTED[$key]:-}" ]]; then
    EMITTED[$key]=1
    emit "$file"
  fi
}

# 항상 공통 프래그먼트 먼저
emit_once "_common" "_common.gitignore"
emit_once "_platform" "_platform.gitignore"

# 요청된 프래그먼트
for key in "$@"; do
  key_lower="${key,,}"  # lowercase
  if [[ -n "${FRAGMENT_MAP[$key_lower]:-}" ]]; then
    emit_once "$key_lower" "${FRAGMENT_MAP[$key_lower]}"
  else
    echo "# [경고] 알 수 없는 프래그먼트 키: $key_lower" >&2
  fi
done
