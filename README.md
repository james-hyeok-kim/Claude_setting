# Claude dotfiles

Claude Code 전역 설정 백업 저장소.

## 구조

```
claude/
  CLAUDE.md                    # 전역 규칙 (Global Rules)
  settings.json                # 사용자 설정 (model, permissions 등)
  agents/                      # 전역 agent 정의
  skills/                      # 전역 skill 정의
  plugins/known_marketplaces.json
```

> `settings.local.json` — 머신별 설정, .gitignore로 제외

## 사용법

### 새 머신 세팅 (dotfiles → ~/.claude)

```bash
bash install.sh
```

### 설정 변경 후 백업 (live → dotfiles)

```bash
bash save.sh
git diff        # 변경사항 확인
git add -p && git commit
```
