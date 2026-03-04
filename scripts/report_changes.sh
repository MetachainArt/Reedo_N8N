#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BASE_REF="${1:-}"
TARGET_REF="${2:-}"

if [[ -n "$BASE_REF" && -z "$TARGET_REF" ]]; then
  TARGET_REF="HEAD"
fi

if [[ -z "$BASE_REF" ]]; then
  # default: working tree changes 우선, 없으면 마지막 커밋 비교
  if ! git diff --quiet -- workflows || ! git diff --cached --quiet -- workflows; then
    echo "[n8n workflow 변경 리포트]"
    echo "기준: WORKTREE + INDEX (아직 커밋 전 변경 포함)"
    echo

    echo "1) 변경 파일 목록"
    git status --short -- workflows || true
    echo

    echo "2) 라인 변경 통계"
    git diff --numstat -- workflows || true
    git diff --cached --numstat -- workflows || true
    echo

    echo "3) 상세 diff"
    git diff -- workflows || true
    git diff --cached -- workflows || true
    exit 0
  fi

  BASE_REF="HEAD~1"
  TARGET_REF="HEAD"
fi

echo "[n8n workflow 변경 리포트]"
echo "기준: ${BASE_REF} .. ${TARGET_REF}"
echo

echo "1) 변경 파일 목록"
git diff --name-status "${BASE_REF}" "${TARGET_REF}" -- workflows || true
echo

echo "2) 라인 변경 통계"
git diff --numstat "${BASE_REF}" "${TARGET_REF}" -- workflows || true
echo

echo "3) 상세 diff"
git diff "${BASE_REF}" "${TARGET_REF}" -- workflows || true
