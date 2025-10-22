## 개요
이 문서는 스테이킹 시스템의 주요 자산과 행위자, 잠재적 위협을 표로 정리하고 각 위협에 대한 초기 완화책을 제시합니다.

## 핵심 자산
- Staked token (유저 예치 자산)
- Reward pool (프로토콜 보상 자금)
- Admin 권한(업그레이드/파라미터 변경 권한)

## 행위자 (Actors)
- User: 정상 사용자 (예치/인출/클레임)
- Admin: 운영자(업그레이드·매개변수 변경 권한)
- Keeper: 보상 분배 호출자(keeper 역할)
- Attacker: 악의적 행위자 (flashloan operator, MEV miner 등)

## 위협 목록 (Threats) 및 완화책 (Mitigations)

| 위협(Threat) | 영향(Impact) | 완화책(Mitigation) |
|--------------|--------------|---------------------|
| Reentrancy (withdraw/claim) | 자금 탈취 / 중복 송금 | `nonReentrant`, CEI 패턴, pull-over-push |
| Admin key 탈취 | 권한 남용, 파라미터 조작 | Timelock + Multisig, 최소 권한 원칙 |
| Reward 계산 오버플로우 / 정밀도 문제 | 잘못된 보상 분배(과다/과소) | Solidity ^0.8 안전 산술, 단위테스트, 범위검증 |
| Front-running / MEV | 유저 손실, 조작된 클레임 | commit/claim 패턴, 슬리피지 한도, TWAP 사용 |
| Timestamp / Oracle 조작 | 잘못된 reward 계산 / 청산 | block.number 기반 설계, oracle redundancy, TWAP |
| Replay / Duplicate tx | 재실행 공격 | Nonce 관리, 영수증(반복 방지) 로직 |
| Dependency 취약점 (외부 컨트랙트) | 상호작용 실패 또는 악용 | 의존성 감사, 버전 고정(pin), 최소 권한 인터랙션 |

## 우선순위(초기)
1. Reentrancy 방지 (우선 구현·테스트)  
2. Admin 권한 모델 (Timelock + Multisig 설계)  
3. Reward 계산 정확성(정밀도/경계값 테스트)

## 테스트/검증 체크리스트
- [ ] withdraw/claim 관련 재진입 PoC 재현 및 방어 확인  
- [ ] 관리 작업(업그레이드/파라미터 변경)은 타임록을 통해만 가능하도록 구현  
- [ ] reward 계산 경계값(very large / small / fractional) 단위 테스트 작성  
- [ ] Slither/Foundry fuzz로 자동화 검사 구성

## 비고
- 이 문서는 프로젝트 초기 위협 모델입니다. 구현이 진행될수록 구체적인 공격 시나리오와 PoC를 추가합니다.