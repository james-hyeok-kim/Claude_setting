# Global Rules

## Time zone

**모든 시각 표기는 KST(Asia/Seoul, UTC+9)로 한다.**

- 로그 timestamp, scheduling 시각, 실험 결과의 시간, 사용자에게 보고하는 모든 시각은 KST 기준
- 표기 형식 예: `2026-05-18 14:30 KST` — timezone suffix를 명시
- 외부 시스템이 UTC로 기록하더라도, 사용자에게 보여줄 때는 KST로 변환 후 표기
- `/schedule`, cron, wakeup 등 시간 입력은 별도 명시 없으면 KST로 해석

## Git operations

**git push, git commit, branch deletion, force-push, reset --hard 등 git의 모든 mutating operation은 반드시 사용자의 명시적 확인을 받은 후에만 수행한다.**

- 사용자가 "commit해줘", "push해줘", "백업해줘" 등 명확히 요청한 경우만 수행
- 작업이 끝났다고 자동으로 commit/push 하지 않음
- 일괄 작업 흐름 안에서도, 큰 작업 단위마다 사용자에게 확인 후 진행
- `git add`, `git status`, `git diff`, `git log` 같은 read-only 또는 staging-only 작업은 자유롭게 가능
- 충돌 해결, branch 삭제, 강제 옵션은 항상 사용자 승인 필수

## Behavior on uncertain mutations

Git 외에도 되돌리기 어려운 변경(파일 삭제, 외부 시스템 호출, 메시지 전송 등)은 동일 원칙: **명시적 사용자 요청이 있을 때만 수행**, 자동 판단으로 수행 금지.

## File deletion

**파일은 지우기 전에 꼭 사용자에게 문의한다.**

- `rm`, `rm -rf`, `Write`로 기존 파일 덮어쓰기, 디렉토리 삭제 등 모든 파일 삭제/소실 작업은 사용자 승인 필수
- 임시 파일이나 본인이 방금 만든 파일이라도 삭제 전 한 번 확인
- 작업 흐름상 "정리"가 필요해 보여도 자동 삭제 금지 — 어떤 파일을 왜 지울지 먼저 보고
- 사용자가 명시적으로 "지워줘", "정리해줘"라고 한 경우만 수행

## Push notifications

**사용자 개입(intervention)이 필요한 시점에는 반드시 `PushNotification` 도구로 phone push를 보낸다.** Remote Control이 연결되지 않은 경우 PushNotification은 단순 desktop alert로 fallback되지만, 어쨌든 호출은 한다.

### 보내야 하는 시점 (반드시 push)
- **의사결정 요청**: A/B/C 옵션 선택, framing 선택, 다음 실험 방향 승인 등 사용자 답변 필요
- **블로커 발생**: 크래시, OOM, config 오류, 데이터 누락, 의존성 충돌 등 자동 진행 불가능한 상태
- **명시적 요청**: 사용자가 "끝나면 알려줘", "결과 나오면 push해줘" 등 직접 요청
- **장시간 작업의 완전 종료**: 1시간+ 자동 진행되던 pipeline의 최종 결과 (사용자가 기다리고 있음)

### 보내지 말 것 (chat 알림으로 충분)
- 자동 진행 중인 routine progress
- 단일 task 완료 (다음 단계가 자동 launch되는 경우)
- 정보성 메트릭/결과 (사용자가 보고 있는 동안)
- 직전 사용자 메시지에 대한 응답 (사용자가 현재 보고 있음)

### 메시지 작성
- 200자 이하, 한 줄, markdown 없음
- action 가능한 정보 먼저: "Route A +18pp 확정 — 다음 실험 승인 필요" > "실험 완료"
- 결과면 핵심 숫자 포함, 결정이면 옵션 명시

## Test strategy

**새 기능을 수행하기 전에 반드시 테스트 전략을 먼저 설명한다.**

- 코드 변경 / 실험 / 배포 / 데이터 처리 등 새 작업 시작 전, 다음을 명시:
  - 무엇을 어떻게 검증할 것인가 (success criteria)
  - 어떤 edge case를 확인할 것인가
  - 측정 metric과 임계값
  - 실패 시 fallback / 재시도 전략
- 설명 없이 바로 실행 금지. 사용자가 전략을 확인한 후 진행.
- 단순 read-only 조회, git status, ls 같은 정보 조회는 제외.

## Plan files

**모든 계획(plan)은 `plan_{index}.md` 형식의 markdown 파일로 해당 workspace에 만들고 관리한다.**

- 파일명: `plan_001.md`, `plan_002.md` ... — 새 plan마다 index 증가
- 위치: 현재 작업 중인 workspace의 root 또는 `plans/` 디렉토리
- 내용: 목표 / 가설 / 단계별 작업 / 측정 metric / 예상 시간 / 위험 요소
- 새 plan 시작 시 가장 큰 index + 1로 새 파일 생성
- 진행 중 변경사항은 동일 파일에 update (덮어쓰지 말고 history 유지)
- 단순 한두 줄 응답에는 plan 파일 불필요 — 본격 작업 시작 시 필수

## Experiment files

**모든 실험은 `experiment_{index}.md` + `result_{index}.md` 쌍으로 만들어서 관리한다.**

- `experiment_{index}.md` — 실험 설계: 가설 / 설정 / 데이터셋 / metric / 예상 결과
- `result_{index}.md` — 실행 결과: 실측값 / 그래프 / 비교 / 판정 / 다음 단계
- 위치: `experiments/<slug>/` 안에 만들거나 workspace의 `experiments/` 디렉토리
- index는 plan index와 독립적으로 증가 (실험은 plan 하나에 여러 개 가능)
- 한 실험 == 한 쌍의 파일. 여러 시도는 `experiment_005.md` / `result_005a.md`, `result_005b.md` 식으로 sub-run
- 매 실험 후 result 파일 즉시 갱신. 끝나고 한꺼번에 정리 X (중간 손실 위험)
