---
name: git-cp
description: Interactive git commit & push. Shows staged/unstaged diff, asks what to include, writes commit message, confirms before push. Follows CLAUDE.md git rules (no auto-commit/push without explicit user confirmation).
---

You are running the `/git-cp` skill. Follow these steps exactly.

## Step 1 — 현황 파악 (병렬 실행)

다음 세 명령을 동시에 실행:
- `git status` — 변경된/untracked 파일 목록
- `git diff HEAD` — 전체 변경 diff 요약
- `git log --oneline -5` — 최근 커밋 스타일 파악

## Step 2 — 사용자에게 보고

다음 형식으로 간결하게 보고:

```
[staged]
  M path/to/file

[unstaged / untracked]
  M path/to/file
  ? path/to/new-file

커밋에 포함할 파일을 알려주세요. (전체 포함이면 "전체", 특정 파일만이면 경로 나열)
```

사용자 응답을 기다린다. 응답 없이 진행하지 않는다.

## Step 3 — 스테이징

사용자가 지정한 파일만 `git add <file>` (개별 지정). "전체"이면 변경된 파일을 파일명 나열해서 추가 (`git add -A` 사용 금지 — .env 등 민감 파일 실수 방지).

## Step 4 — 커밋 메시지 초안

- `git diff --cached` 로 staged 내용 확인
- 최근 커밋 스타일 참고해 한 줄 메시지 초안 작성
- 사용자에게 메시지 제안하고 수정 여부 확인

사용자 승인 후에만 커밋 실행:
```bash
git commit -m "$(cat <<'EOF'
<confirmed message>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## Step 5 — Push 확인

커밋 성공 후:
```
origin/<branch>에 push하겠습니다. 진행할까요?
```

사용자 승인 후 `git push` 실행. 결과(branch URL 등) 보고.

## 규칙

- 각 단계마다 사용자 확인 필수. 자동 진행 금지.
- `git add -A` / `git add .` 사용 금지.
- `--no-verify`, `--force` 옵션 사용 금지 (사용자 명시 요청 시 예외).
- pre-commit hook 실패 시 → 원인 진단 후 새 커밋으로 재시도 (amend 금지).
- 민감 파일(.env, credentials 등) 포함 시 경고 후 제외.
