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
