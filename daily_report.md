# 1주차 Day 1 — HelpFlow 프로젝트 초기 세팅

**날짜**: 2026-03-15
**브랜치**: `week-01`
**상태**: 완료 ✅

---

## 작업 요약

### 작업 1 — 폴더 구조 및 pubspec 설정
- `lib/` 하위 전체 폴더/파일 구조 생성 완료
- `flutter_riverpod ^2.5.1`, `hive_flutter ^1.1.0`, `go_router ^14.2.7`, `material_symbols_icons ^4.2719.1` 추가
- **이슈**: `riverpod_generator ^2.4.3`과 `hive_generator ^2.0.1`의 analyzer 버전 충돌 → `riverpod_generator`를 주석 처리(수동 NotifierProvider 방식으로 대체)

### 작업 2 — Material3 테마 및 반응형 상수
- `app_colors.dart`: 시드컬러 `0xFF0057FF` 기반 브랜드/상태 색상 정의
- `app_sizes.dart`: 데스크탑(1024), 태블릿(600) 브레이크포인트, 사이드바 너비(240/64) 정의
- `app_theme.dart`: `ColorScheme.fromSeed`로 라이트/다크 테마 구현, `useMaterial3: true`
- `app_text_styles.dart`: 페이지 제목, 섹션 제목, 본문, 레이블 텍스트 스타일

### 작업 3 — 핵심 파일 구현

#### 상태 관리
- `theme_provider.dart`: `NotifierProvider<ThemeNotifier, bool>` — `toggle()`, `setDark()` 메서드

#### 라우팅
- `app_router.dart`: `ShellRoute`로 사이드바 공유, 경로: `/dashboard`, `/tickets`, `/tickets/new`, `/tickets/:id`, `/settings`
- `/tickets/new`를 `:id`보다 먼저 선언하여 파라미터 충돌 방지

#### 레이아웃
- `main_layout.dart`: `LayoutBuilder` 3단계 분기 (데스크탑/태블릿/모바일)
- `sidebar_widget.dart`: `AnimatedContainer` 전환, 활성 경로 강조
- `top_bar_widget.dart`: 경로 기반 제목 자동 표시, 새 티켓 버튼, 다크모드 토글

#### 데이터 모델
- `ticket_model.dart`: Hive `@HiveType`, `TicketStatus`/`TicketPriority` 열거형 포함
- `ticket_model.g.dart`: build_runner 없이 동작하도록 어댑터 수동 stub 작성

#### 화면
- `dashboard_screen.dart`: 통계 카드 4개(Wrap 반응형), 차트 플레이스홀더, 임시 티켓 목록
- 나머지 화면(ticket_list, detail, form, settings): `Scaffold + Center(Text(...))` 뼈대

#### 공유 위젯
- `custom_button.dart`: Filled / Outlined / Text 세 가지 변형
- `loading_indicator.dart`: 전체화면 + 인라인 소형
- `empty_state_widget.dart`: 아이콘 + 제목 + 부제목 + 액션 버튼

#### 진입점
- `app.dart`: `MaterialApp.router` + `themeProvider` 구독
- `main.dart`: `Hive.initFlutter()`, 어댑터 3개 등록, `ProviderScope` 래핑

---

## 커밋 내역 (6개)

| # | 커밋 메시지 | 주요 파일 |
|---|---|---|
| 1 | `chore: 프로젝트 폴더 구조 및 pubspec 초기 설정` | pubspec.yaml |
| 2 | `feat: Material3 테마 및 반응형 상수 정의` | core/constants/*, core/theme/*, core/utils/* |
| 3 | `feat: go_router ShellRoute 기반 라우팅 설계` | core/router/app_router.dart |
| 4 | `feat: 반응형 사이드바 레이아웃 뼈대 구현` | views/layout/* |
| 5 | `feat: Riverpod 다크모드 상태 관리 구현` | providers/theme_provider.dart |
| 6 | `feat: 대시보드 뼈대 화면 및 통계 카드 UI 작성` | views/*, shared/*, models/*, app.dart, main.dart |

---

## 이슈 및 결정사항

| 항목 | 내용 |
|---|---|
| `riverpod_generator` 충돌 | `hive_generator ^2.0.1`과 analyzer 버전 충돌. 수동 `NotifierProvider` 방식으로 대체. 2주차 이후 필요 시 `hive_generator` 제거 후 활성화 검토. |
| `ticket_model.g.dart` | `build_runner` 미실행 상태에서도 컴파일 가능하도록 어댑터 stub 수동 작성. 추후 `build_runner build` 실행 시 재생성됨. |
| `fl_chart` | `pubspec.yaml`에 주석으로 포함. 7~8주차 활성화 예정. |

---

## 다음 작업 예고 (1주차 Day 2~)

- [ ] TicketModel CRUD (Hive Box 연동)
- [ ] 티켓 목록 화면 실구현 (필터/정렬)
- [ ] 티켓 작성 폼 (유효성 검증 연동)
- [ ] 티켓 상태 변경 기능
