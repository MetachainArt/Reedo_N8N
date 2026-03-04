# Reedo_N8N

n8n 워크플로우를 리눅스 서버에서 운영하면서 Git으로 버전관리하는 저장소입니다.

- 서버 경로: `/opt/n8n-ops`
- 원격 저장소: `git@github.com:MetachainArt/Reedo_N8N.git`
- 목적: 워크플로우 JSON 이력 관리 + 변경사항 추적 + 안전한 배포

---

## 1) 저장소 구조

```bash
/opt/n8n-ops
├── workflows/                 # Git에 올리는 워크플로우 JSON(민감정보 제거본)
├── scripts/
│   └── export_all.sh          # n8n API로 워크플로우 export
├── .env                       # 서버 로컬 전용 (절대 커밋 금지)
├── .env.example               # 환경변수 템플릿
├── .gitignore
├── docker-compose.yml
├── CHANGELOG.md               # 변경 이력
└── README.md
```

---

## 2) 환경변수

`.env` (서버 로컬 전용)

```env
N8N_BASE_URL=https://n8n.dmssolution.co.kr
N8N_API_KEY=YOUR_NEW_API_KEY
```

권장:
- `chmod 600 .env`
- 키/토큰은 채팅, 커밋, 스크린샷에 노출 금지

---

## 3) 워크플로우 Export (버전관리용)

```bash
cd /opt/n8n-ops
./scripts/export_all.sh
```

성공 시 `workflows/*.json` 갱신됩니다.

---

## 4) 버전관리 표준 절차

### A. 변경 반영

```bash
cd /opt/n8n-ops
./scripts/export_all.sh

git add workflows scripts/export_all.sh README.md CHANGELOG.md
git commit -m "chore(workflows): <변경요약>"
git push
```

### B. 커밋 메시지 규칙(권장)

- `feat(workflows): 새 자동화 추가`
- `fix(workflows): Trello 카드 생성 조건 수정`
- `chore(workflows): export 동기화`
- `docs: README/운영문서 업데이트`

---

## 5) CHANGELOG 운영 규칙

- 워크플로우 구조/로직 바뀌면 `CHANGELOG.md`에 기록
- 항목 형식:
  - 날짜
  - 변경 워크플로우명
  - 변경 내용
  - 영향도(낮음/중간/높음)
  - 롤백 방법

예시:

```md
## 2026-03-04
- workflow: 업무칸반-텔레그램→Trello-v1
- change: 카드 생성 파라미터 정리, 민감값 제거
- impact: 중간
- rollback: 이전 커밋 checkout 후 import
```

---

## 6) 보안 규칙 (중요)

1. `workflows/`에는 민감값(토큰/API키/비밀번호) 저장 금지
2. 민감값은 n8n Credential 또는 `.env`로만 관리
3. GitHub Push Protection 경고 발생 시 우회하지 말고 제거 후 재커밋
4. 노출된 키는 즉시 폐기/재발급

---

## 7) 롤백 방법

```bash
# 1) 이전 정상 커밋 확인
git log --oneline

# 2) 특정 커밋의 workflow 파일 복원
git checkout <commit_hash> -- workflows/

# 3) 커밋/푸시 후 n8n에 재반영
git add workflows
git commit -m "revert(workflows): rollback to <commit_hash>"
git push
```

---

## 8) 운영 체크리스트

- [ ] API 키 만료/노출 점검
- [ ] export 후 JSON diff 확인
- [ ] CHANGELOG 업데이트
- [ ] push 성공 확인
- [ ] 필요시 n8n import/테스트

