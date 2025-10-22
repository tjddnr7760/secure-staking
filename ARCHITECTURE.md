## 개요
이 저장소는 **보안 우선(Security-first)** 원칙으로 설계된 스테이킹 & 보상 시스템을 구현합니다. 주요 목적은 다음과 같습니다:
- 안전한 자금 보관 및 보상 분배 보장
- 방어 가능한 관리자 모델(타임록 + 멀티시그)
- 재현 가능한 PoC → 패치 → 감사 워크플로우(영향 증명: Proof of Impact)

## 계약(Contracts)
- `StakingPool.sol`
  - 핵심 스테이킹 로직: `stake()`, `withdraw()`, `claimRewards()`
  - 보상 적립 모델: `rewardPerToken` / 정밀도(precision) 고려한 수학 처리
  - 보안 패턴: Checks-Effects-Interactions(검사-상태변경-상호작용) 패턴, `nonReentrant` 가드

- `RewardDistributor.sol`
  - 주기적인 보상 투입 및 분배 헬퍼 함수
  - 관심사의 분리(회계(accounting) vs 전송(transfer))

- `AdminTimelock.sol` (OpenZeppelin의 `TimelockController` 권장)
  - 모든 민감한 관리자 작업은 타임록 및 멀티시그 승인으로 제한

## 주요 데이터 흐름
1. 사용자가 토큰을 승인(approve) → `stake(amount)` 호출  
2. 컨트랙트가 회계(storage)를 갱신하고 풀로 토큰을 전송  
3. `RewardDistributor`가 주기적으로 보상 적립을 업데이트(keeper가 호출 가능)  
4. 사용자가 `claimRewards()` 호출 → CEI(Checks-Effects-Interactions) 적용 → 안전하게 보상 전송  
5. `withdraw(amount)`은 `nonReentrant` + 회계 검사 적용

## 위협 모델(상위 수준)
- **자산(Assets):** 스테이킹된 토큰, 보상 풀 유동성  
- **행위자(Actors):** 사용자(User), 관리자(Admin), 키퍼(Keeper), 악의적 공격자(예: flashloan / miner)  
- **주요 위협 및 완화책(Top Threats & Mitigations):**
  - 인출/클레임 시 재진입(Reentrancy) → `nonReentrant`, CEI 적용  
  - 관리자 키 탈취(Admin key compromise) → 타임록 + 멀티시그 사용  
  - 보상 오버플로우/정밀도 문제 → Solidity ^0.8의 안전한 산술 + 엣지 케이스 유닛 테스트  
  - 클레임/인출 시 프론트러닝/MEV → commit/claim 패턴 또는 슬리피지 제어 고려  
  - (시간 기반 보상 사용 시) 오라클/시간 조작 → 블록번호 사용 또는 이동평균값(TWAP) 등 안정화 입력 권장

## 보안 통제 및 도구
- 정적분석(Static analysis): Slither, Mythril (CI에 통합)  
- 퍼징(Fuzzing): Foundry / Echidna를 이용한 불변성(invariant) 테스트  
- 메인넷 포크 재현성: Foundry / Anvil 스크립트를 사용해 PoC 시나리오 재현  
- 감사 산출물: 간단한 형식의 감사 리포트(`audit/report.pdf`)

## 개발 및 테스트 워크플로우
- `forge test` → 단위 테스트 및 fuzz 테스트 실행  
- `forge script` / `anvil` → mainnet-fork 또는 로컬 시뮬레이션에서 PoC 재현  
- CI: push/PR 시 Slither + forge test 실행

## 영향 증명(Proof of Impact)
- PoC: `poc/reentrancy.sol` — 예시 tx 해시: ``  
- 패치 PR: ``  
- 감사 요약: `audit/report.pdf`

## 참고 사항(Notes)
- 토큰 및 접근 제어 프리미티브는 OpenZeppelin 계약을 사용합니다.  
- 관리자 권한 표면(Admin surface)은 최소화합니다. 모든 관리자 업그레이드나 파라미터 변경은 반드시 타임록을 통과해야 합니다.