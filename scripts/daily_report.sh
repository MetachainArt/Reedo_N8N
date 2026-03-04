#!/usr/bin/env bash
set -euo pipefail
cd /opt/n8n-ops

mkdir -p reports
STAMP="$(TZ=Asia/Seoul date +%F)"
OUT="reports/daily-${STAMP}.txt"

{
  echo "[n8n daily workflow report]"
  echo "time: $(TZ=Asia/Seoul date '+%F %T %Z')"
  echo

  ./scripts/export_all.sh
  echo

  if ! git diff --quiet -- workflows; then
    echo "변경 감지: YES"
    echo
    echo "변경 파일 목록"
    git status --short -- workflows
    echo
    echo "라인 변경 통계"
    git diff --numstat -- workflows
    echo
    echo "상세 diff"
    git diff -- workflows
  else
    echo "변경 감지: NO"
    echo "워크플로우 변경 없음"
  fi
} > "$OUT" 2>&1

# latest 심볼릭 링크
ln -sfn "$OUT" reports/latest.txt
