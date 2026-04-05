---
## 📅 2026-04-05

### ✅ 완료한 작업

**[5주차 — 티켓 접수 폼·회원가입·역할 기반 UI]**

**[작업 1] 티켓 접수 폼 (`ticket_form_screen.dart` 전면 재작성)**
- `ConsumerStatefulWidget` → authProvider에서 접수자 이메일 읽기
- 4개 입력 필드: 제목(required), 내용(required + minLength 10), 카테고리·우선순위 드롭다운
- `_FormBody`(StatelessWidget) 분리로 100줄 초과 방지, `_DropdownField` 공용 위젯
- 제출 성공 시 SnackBar + `context.go('/tickets')`

**[작업 2] 회원가입 화면 (`register_screen.dart` 신규)**
- 이메일·비밀번호·비밀번호 확인·역할 선택(SegmentedButton: 사용자/에이전트/관리자)
- `_validateConfirm()`: 비밀번호 일치 검증
- 성공 시 자동 로그인(authProvider.register() 연동)

**[작업 3] AuthUser에 역할 추가 (`auth_provider.dart` 수정)**
- `AuthUser.role` 필드 추가 (기본값 'user')
- `register()` 메서드 신규: 이메일·비밀번호·역할 Hive 영속화
- `build()` / `signIn()`에서 role 복원 로직 추가

**[작업 4] 로그인 화면에 회원가입 링크 (`login_screen.dart`)**
- TextButton "계정이 없으신가요? 회원가입" → `context.go('/register')`

**[작업 5] 라우터·스트링·사이드바·탑바 정비**
- `app_router.dart`: `/register` 공개 경로 추가, redirect에 `isPublicPath` 개념 도입
- `app_strings.dart`: `navReports`, `reportsTitle`, `navNotifications`, `navAssets` 추가
- `sidebar_widget.dart`: 리포트 항목 추가
- `top_bar_widget.dart`: /reports 타이틀 처리

**[작업 6] 설정 화면 (`settings_screen.dart` 완전 구현)**
- `_AppearanceSection`: 다크모드 SwitchListTile (themeProvider 연동)
- `_AccountSection`: 이메일·역할 표시 + 로그아웃 OutlinedButton (AppColors.error)

**[작업 7] 리포트 화면 (`reports_screen.dart` 완전 구현)**
- kMockTickets 집계: 요약 카드 4개 (Wrap 반응형), 상태·카테고리·우선순위 LinearProgressIndicator 분포 바
- fl_chart 연동(7~8주차) 시 DistRow 교체 예정

**[작업 8] 대시보드 실데이터 연동 (`dashboard_screen.dart`)**
- 하드코딩 수치 → kMockTickets 실집계값 (total/inProgress/done/pending)
- `_RecentTicketsSection`: kMockTickets 최신 4건, 상대시간 표시, "전체 보기" → /tickets

**[작업 9] 티켓 목록 검색 기능 (`ticket_list_screen.dart`)**
- `ConsumerStatefulWidget` 전환, `_searchQuery` 상태 추가
- `_SearchBar` 위젯: 제목·이메일 포함 여부 AND 검색
- USER 역할: 본인 이메일 티켓만 표시 (AGENT·ADMIN: 전체)

**[작업 10] 역할 기반 UI 분기 (`ticket_detail_screen.dart`)**
- `ConsumerStatefulWidget` 전환
- USER: 상태 변경 버튼 비활성 + 안내 문구, 처리 메모 섹션 숨김
- AGENT·ADMIN: 전체 기능 활성

---

**[6주차 — 담당자 배정·알림·자산 관리]**

**[작업 11] 에이전트 목업 데이터 (`user_mock_data.dart` 신규)**
- `MockUser` 클래스: id·name·email·role
- `kMockAgents`: 5명 에이전트 목업 (이지훈·박수진·최민준·정다은·한승우)

**[작업 12] 담당자 필드 추가 (`ticket_mock_data.dart` 수정)**
- `MockTicket`에 `agentId`·`agentName` nullable 필드 추가
- kMockTickets 7건(HF-002~011 중 처리중·완료 티켓)에 에이전트 배정 데이터 적용

**[작업 13] 담당자 배정 UI (`ticket_detail_screen.dart` 추가)**
- `_TicketInfoSection`: 담당자 표시 행 추가 (미배정 시 '미배정')
- `_AgentAssignSection` (ADMIN 전용): kMockAgents 드롭다운 + 배정 SnackBar

**[작업 14] 알림 화면 (`notifications_screen.dart` 신규)**
- `MockNotification`: id·type·ticketId·message·isRead 모델
- `NotificationType`: newTicket·ticketAssigned·statusChanged·noteAdded
- `kMockNotifications`: 8건 목업 (읽음 4건·안읽음 4건)
- 개별 탭 시 읽음 처리 + 해당 티켓 상세 이동, "모두 읽음" 버튼

**[작업 15] 자산 관리 화면 (`assets_screen.dart` 신규)**
- `MockAsset`: id·name·type·location·serialNumber 모델, `AssetType` enum 6종
- `kMockAssets`: 10건 (노트북·데스크탑·프린터·네트워크·모니터·주변기기)
- 타입별 FilterChip 필터, ADMIN FloatingActionButton (자산 등록 플레이스홀더)
- QR 코드 아이콘 플레이스홀더 (9~10주차 mobile_scanner 연동 예정)

**[작업 16] 라우터·사이드바·레이아웃 업데이트**
- `app_router.dart`: `/notifications`·`/assets` ShellRoute에 추가
- `sidebar_widget.dart`: `_navItemsFor(role)` 동적 메서드 — ADMIN에 자산 관리 항목 추가
- `main_layout.dart`: 모바일 NavigationBar 알림 탭 추가 (4→5개)
- `top_bar_widget.dart`: 알림 벨 아이콘 버튼 (/notifications 이동) + 타이틀 처리

### 🐛 발생한 오류 & 해결 방법
- `DropdownButtonFormField.value` deprecated → `initialValue`로 교체 (ticket_form, ticket_detail)
- `_navItems` static const → 역할별 동적 목록 필요 → `_navItemsFor(role)` 메서드로 교체
- `sidebar.dart` lint: navItems 선언 후 미사용 → build()에서 `navItems.map(...)` 참조로 해결

### 📦 커밋 내역
- `feat: 티켓 접수 폼·회원가입·역할 기반 UI 분기 구현 (5주차)` (0023252)
- `feat: 설정·리포트 완전 구현, 대시보드 실데이터 연동, 역할 기반 UI (5주차)` (90ed35e)
- `feat: 담당자 배정·알림·자산 관리 화면 구현 (6주차)` (c85e47d)

### 🔗 연관 파일 목록 (신규/수정)
**5주차**
- `lib/views/tickets/ticket_form_screen.dart` (전면 재작성)
- `lib/features/auth/register_screen.dart` (신규)
- `lib/features/auth/auth_provider.dart` (role 필드·register() 추가)
- `lib/features/auth/login_screen.dart` (회원가입 링크)
- `lib/views/settings/settings_screen.dart` (전면 재작성)
- `lib/views/reports/reports_screen.dart` (전면 재작성)
- `lib/views/dashboard/dashboard_screen.dart` (실데이터 연동)
- `lib/views/tickets/ticket_list_screen.dart` (검색·역할 필터)
- `lib/views/tickets/ticket_detail_screen.dart` (역할 기반 UI)
- `lib/core/router/app_router.dart` (/register·/notifications·/assets)
- `lib/core/constants/app_strings.dart` (navReports 등 추가)

**6주차**
- `lib/views/users/user_mock_data.dart` (신규)
- `lib/views/tickets/ticket_mock_data.dart` (agentId·agentName)
- `lib/views/notifications/notifications_screen.dart` (신규)
- `lib/views/assets/assets_screen.dart` (신규)
- `lib/views/layout/sidebar_widget.dart` (역할별 동적 항목)
- `lib/views/layout/main_layout.dart` (알림 탭 추가)
- `lib/views/layout/top_bar_widget.dart` (알림 아이콘 버튼)

---
## 📅 2026-03-25

### ✅ 완료한 작업

**[작업 1] HelpFlow 디자인 시스템 정의 (`lib/core/design_system.dart` 신규)**
- `HelpFlowColors`: 토스 스타일 색상 팔레트 (primary #0057FF, background #FFFFFF, surface, gray100/400/700, error #FF4D4F)
- `HelpFlowTextStyles`: 시스템 폰트 기반 텍스트 스타일 7종 (headline1~3, body1~2, caption, button)
- `HelpFlowButtonStyles`: FilledButton / OutlinedButton / TextButton 스타일 (radius 12, padding 24×16)
- `HelpFlowSpacing`: 4 / 8 / 12 / 16 / 20 / 24 / 32px 여백 상수 체계

**[작업 2] app_theme.dart 디자인 시스템 연동**
- seedColor → `HelpFlowColors.primary` 참조로 변경
- `TextTheme` 전체를 `HelpFlowTextStyles` 7종 매핑
- FilledButton / OutlinedButton / TextButton 테마를 `HelpFlowButtonStyles`로 교체 (radius 8 → 12)
- `NavigationBar` 테마 신규 추가 (모바일 하단 바용)
- 라이트 `scaffoldBackgroundColor` → `HelpFlowColors.background` (#FFFFFF)

**[작업 3] 모바일 하단 내비게이션 바 추가 (`main_layout.dart`)**
- 기존 모바일 Drawer → `NavigationBar` (Material 3) 4탭으로 교체
- 항목: 홈(대시보드) / 티켓 / 리포트 / 설정
- 600px 미만에서만 하단 바 표시, 600px 이상은 기존 사이드바 유지
- `/reports` 라우트 및 `ReportsScreen` 플레이스홀더 신규 추가
- 모든 레이아웃 Scaffold에 `backgroundColor: HelpFlowColors.background` 적용

**[작업 4] 전체 화면 배경색 통일**
- ticket_list / ticket_detail / ticket_form / settings 4개 화면 Scaffold에 `backgroundColor: HelpFlowColors.background` 적용

**[작업 5] 사이드바 로그아웃 버튼 UI 추가 (`sidebar_widget.dart`)**
- `StatelessWidget` → `ConsumerWidget` 변경 (`authProvider` 구독)
- 사이드바 하단에 `_LogoutTile` 추가 (접힌 상태: 아이콘+툴팁 / 펼친 상태: 아이콘+텍스트)
- 탭 시 `authProvider.notifier.signOut()` 호출 → 라우터가 `/login`으로 자동 리다이렉트

**[작업 6] 티켓 목록 화면 구현 (`ticket_list_screen.dart`)**
- `ticket_mock_data.dart` 신규: `MockTicket` 클래스 + 12건 목업 데이터 (다양한 상태·우선순위·카테고리)
- 상태 필터 칩 5종 (전체 / 새 티켓 / 처리중 / 완료 / 종료), 가로 스크롤
- 우선순위 필터 칩 5종 (전체 / 긴급 / 높음 / 중간 / 낮음), 가로 스크롤
- 정렬 드롭다운 3종 (최신순 / 오래된순 / 우선순위순)
- `_TicketCard` 탭 시 `/tickets/:id` 이동
- `StatefulWidget` 로컬 상태로 필터·정렬 관리

**[작업 7] 티켓 상세 화면 구현 (`ticket_detail_screen.dart`)**
- `_TicketInfoSection`: 제목·설명·카테고리·접수자·접수일 카드
- `_StatusSection`: 현재 상태 배지 + 다음 상태 변경 버튼 (new → 처리중 → 완료)
- `_NoteSection`: 처리 내용 텍스트 입력(4줄) + 저장 버튼
- 상태 변경 및 메모 저장 시 SnackBar 피드백 제공
- 로컬 상태 관리 (Firestore 연동 전 임시)

### 🐛 발생한 오류 & 해결 방법
- `design_system.dart` — `HelpFlowButtonStyles.filled` 는 `BorderRadius.circular()` 때문에 `const` 불가 → `static ButtonStyle get filled =>` getter 방식으로 해결
- `ticket_mock_data.dart` — 파일 최상단 `///` 주석 → `dangling_library_doc_comments` lint 경고 → `//` 일반 주석으로 변경
- `ticket_list_screen.dart` — `_TicketListScreenState`에 `_statusOptions`, `_priorityOptions` 중복 선언(이미 `_FilterSection`에 있음) → 제거
- `ticket_list_screen.dart` — `separatorBuilder: (_, __)` → Dart 3 스타일 `(_, _)` 로 교체

### ⚠️ 미완료 / 다음에 할 것 (2차 세션)
- 티켓 접수 폼 (`ticket_form_screen.dart`) — 제목·내용·카테고리·우선순위 입력 + 유효성 검증
- 회원가입 화면 (`register_screen.dart`) — 역할(USER/AGENT/ADMIN) 선택 포함
- Firebase Auth 실제 연동: `flutterfire configure` → `firebase_options.dart` → `auth_provider.dart` TODO 교체
- `top_bar_widget.dart` — `/reports` 경로 페이지 제목 처리 (현재 기본값 "대시보드"로 폴백)

### 📦 커밋 내역
- `feat: 사이드바 로그아웃 버튼 UI 추가` (week-02, e27357e)
- `feat: 티켓 목록 화면 구현 (목업 데이터, 필터, 정렬)` (week-02, f817986)
- `feat: 티켓 상세 화면 구현 (목업 데이터, 상태 변경, 처리 메모)` (week-02, 42afa81)
- *(디자인 시스템 관련 커밋 4건은 667d697에 포함)*

### 🔗 연관 파일 목록
- `lib/core/design_system.dart` (신규)
- `lib/core/theme/app_theme.dart` (수정)
- `lib/views/layout/main_layout.dart` (수정 — 모바일 NavigationBar)
- `lib/views/layout/sidebar_widget.dart` (수정 — 로그아웃 버튼)
- `lib/views/reports/reports_screen.dart` (신규)
- `lib/core/router/app_router.dart` (수정 — /reports 추가)
- `lib/views/tickets/ticket_mock_data.dart` (신규)
- `lib/views/tickets/ticket_list_screen.dart` (전면 재작성)
- `lib/views/tickets/ticket_detail_screen.dart` (전면 재작성)
- `lib/views/tickets/ticket_form_screen.dart` (수정 — backgroundColor)
- `lib/views/settings/settings_screen.dart` (수정 — backgroundColor)

---
## 📅 2026-03-22

### ✅ 완료한 작업

**[작업 1] TicketModel Firestore 연동 설계**
- `lib/shared/models/ticket_model.dart` 신규 생성
- 필드: id, title, description, status, priority, category, reporterId, agentId?, imageUrls, createdAt, updatedAt
- `fromFirestore()`: Firestore DocumentSnapshot → TicketModel 변환
- `toMap()`: TicketModel → Firestore 저장용 Map 변환 (Timestamp 직렬화 포함)
- `copyWith()`: 불변 객체 부분 복사 패턴

**[작업 2] TicketService CRUD 구현**
- `lib/shared/services/ticket_service.dart` 신규 생성
- `createTicket()`: Firestore set으로 티켓 저장
- `getTickets()`: snapshots() Stream 실시간 반환 (createdAt 내림차순)
- `getTicketById()`: 단일 문서 조회, 없으면 null 반환
- `updateTicket()`: Firestore update로 수정
- `deleteTicket()`: Firestore delete로 삭제
- `_toKoreanError()`: FirebaseException 코드 → 한글 메시지 변환

**[작업 3] TicketProvider Riverpod 상태 관리**
- `lib/features/tickets/ticket_provider.dart` 신규 생성
- `AsyncNotifier<List<TicketModel>>` 패턴으로 티켓 목록 상태 관리
- `build()`: getTickets() Stream 첫 값으로 초기 목록 로드
- `createTicket() / updateTicket() / deleteTicket()`: CRUD 후 목록 자동 갱신
- `AsyncValue.guard()`로 에러 상태 자동 처리
- `ticketProvider` 전역 노출

**[작업 4] Firestore 보안 규칙 설계**
- 로그인 사용자만 읽기/쓰기 가능
- create 시 reporterId == 본인 uid 검증
- update: admin 또는 본인 접수 티켓만 가능
- delete: admin 전용
- users/{uid}.role == 'admin'으로 관리자 판별

**[작업 5] Firebase 패키지 추가**
- `pubspec.yaml`: firebase_core ^3.6.0, cloud_firestore ^5.4.1 추가
- `flutter pub get` 후 플랫폼별 플러그인 등록 파일 자동 갱신

### 🐛 발생한 오류 & 해결 방법
- `ticket_service.dart` 경고: `doc as DocumentSnapshot<Map<String, dynamic>>` 불필요한 캐스트
  - 해결: `.map(TicketModel.fromFirestore)` 메서드 레퍼런스로 수정

### ⚠️ 미완료 / 다음에 할 것
- Firebase Console에서 Firestore 보안 규칙 직접 게시 필요
- `flutterfire configure` 실행 → `firebase_options.dart` 생성 후 `main.dart`에 `Firebase.initializeApp()` 추가
- `auth_provider.dart` TODO: FirebaseAuth.instance 실제 연동 교체

### 📦 커밋 내역
- `feat: TicketModel Firestore 연동 설계` (week-02, 0642f78)
- `feat: TicketService CRUD 구현` (week-02, 8698da1)
- `feat: Riverpod TicketProvider 상태 관리 구현` (week-02, f380f36)

### 🔗 연관 파일 목록
- `lib/shared/models/ticket_model.dart` (신규)
- `lib/shared/services/ticket_service.dart` (신규)
- `lib/features/tickets/ticket_provider.dart` (신규)
- `pubspec.yaml` (수정 — Firebase 패키지 추가)

---
## 📅 2026-03-19 (2차 작업)

### ✅ 완료한 작업
- `lib/core/router/app_router.dart`: isLoading 시 null 반환 → /login 강제 이동으로 수정 (대시보드 flash 차단, 뒤로가기 우회 차단)
- `lib/core/constants/app_colors.dart`: 기획 스펙 색상 전면 적용 (라이트/다크 배경·사이드바·카드·텍스트 색상 상수 추가/수정)
- `lib/core/design_system.dart`: HelpFlowColors.surface → #FFFFFF (라이트 카드 순백 통일)
- `lib/core/theme/app_theme.dart`: 다크 ColorScheme surface/onSurface/onSurfaceVariant 명시 지정, AppBar/카드/NavigationBar 색상 명시 적용
- `lib/views/layout/main_layout.dart`: Scaffold backgroundColor 하드코딩 제거 → 테마 자동 적용
- `lib/views/layout/top_bar_widget.dart`: AppBar backgroundColor 제거 → AppBarTheme 위임

### 🐛 발생한 오류 & 해결 방법
- `main_layout.dart` import 제거 후 HelpFlowColors 참조 오류 3건: Scaffold backgroundColor 줄 자체를 제거하는 것으로 해결

### ⚠️ 미완료 / 다음에 할 것
- Firebase Auth 실제 연동: `flutterfire configure` 실행 후 `firebase_options.dart` 생성, `auth_provider.dart` 의 TODO 교체 필요
- 로그아웃 버튼 UI: 사이드바 하단 또는 탑바에 로그아웃 버튼 추가 필요
- 사이드바 bottom 영역: 사용자 프로필 / 로그아웃 아이콘 추가 고려

### 📦 커밋 내역
- `fix: 비로그인 대시보드 접근 차단 및 로그인 필수 라우팅 구현` (week-02)
- `fix: 다크모드 색상 불일치 수정 및 전체 UI 색상 통일` (week-02)

### 🔗 연관 파일 목록
- `lib/core/router/app_router.dart` (수정)
- `lib/core/constants/app_colors.dart` (수정)
- `lib/core/design_system.dart` (수정)
- `lib/core/theme/app_theme.dart` (수정)
- `lib/views/layout/main_layout.dart` (수정)
- `lib/views/layout/top_bar_widget.dart` (수정)
---
## 📅 2026-03-19

### ✅ 완료한 작업
- `lib/features/auth/auth_provider.dart`: Riverpod AsyncNotifier 기반 인증 상태 관리 구현 (Hive 영속화, Firebase 연동 준비)
- `lib/features/auth/login_screen.dart`: 이메일/비밀번호 로그인 화면 UI 생성
- `lib/core/router/router_notifier.dart`: 인증 상태 변화를 go_router 에 전달하는 RouterNotifier(ChangeNotifier) 생성
- `lib/core/router/app_router.dart`: routerProvider 도입 + `/login` 경로 추가 + 인증 기반 redirect 로직 구현
- `lib/app.dart`: `AppRouter.router` → `routerProvider` 교체

### 🐛 발생한 오류 & 해결 방법
- `(_, __)` 린트 경고: Dart 3 에서 `__` 대신 `_` 하나로 사용하도록 수정 → `(_, _)` 로 교체
- `--no-sound-null-safety` 플래그 없음: Flutter 3.x 에서 제거된 플래그 → `flutter build web` 으로 빌드 확인으로 대체

### ⚠️ 미완료 / 다음에 할 것
- Firebase Auth 실제 연동: `flutterfire configure` 실행 후 `firebase_options.dart` 생성, `auth_provider.dart` 의 TODO 교체 필요
- 로그아웃 버튼 UI: 현재 사이드바/탑바에 로그아웃 버튼 없음 → 설정 화면 또는 탑바에 추가 필요
- 회원가입 화면: 현재 로그인 전용, 필요 시 `/register` 라우트 추가

### 📦 커밋 내역
- `fix: 로그인 화면 라우팅 연결 및 인증 상태 분기 수정` (branch: week-02)

### 🔗 연관 파일 목록
- `lib/features/auth/auth_provider.dart` (신규 생성)
- `lib/features/auth/login_screen.dart` (신규 생성)
- `lib/core/router/router_notifier.dart` (신규 생성)
- `lib/core/router/app_router.dart` (수정)
- `lib/app.dart` (수정)
---
