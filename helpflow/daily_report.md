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
