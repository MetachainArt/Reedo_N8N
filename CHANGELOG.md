# CHANGELOG

n8n 워크플로우 변경 이력을 기록합니다.

## 2026-03-04
- workflow: 업무칸반-텔레그램→Trello-v1
- change: 워크플로우 export 및 민감값 제거(토큰/키 마스킹)
- impact: 중간
- rollback: Git 이전 커밋 기준으로 workflows/ 복원 후 재배포

- workflow: 업무칸반-텔레그램→Notion-v1 외 5개
- change: 초기 export 및 저장소 버전관리 시작
- impact: 낮음
- rollback: 초기 커밋 대비 파일 단위 복원
