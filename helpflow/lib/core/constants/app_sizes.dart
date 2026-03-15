/// 앱 전체에서 사용하는 크기·여백·반응형 브레이크포인트 상수 정의
class AppSizes {
  AppSizes._(); // 인스턴스 생성 방지

  // ── 반응형 브레이크포인트 ───────────────────────────────────────
  /// 데스크탑 레이아웃 최소 너비 (px)
  static const double desktopBreakpoint = 1024.0;

  /// 태블릿 레이아웃 최소 너비 (px)
  static const double tabletBreakpoint = 600.0;

  // ── 사이드바 너비 ───────────────────────────────────────────────
  /// 데스크탑 풀 사이드바 너비 (아이콘 + 레이블)
  static const double sidebarWidth = 240.0;

  /// 태블릿 미니 레일 너비 (아이콘만 표시)
  static const double railWidth = 64.0;

  // ── 탑바 ───────────────────────────────────────────────────────
  /// 탑바(AppBar) 높이
  static const double topBarHeight = 64.0;

  // ── 여백·패딩 ──────────────────────────────────────────────────
  /// 초소형 여백
  static const double spacingXs = 4.0;

  /// 소형 여백
  static const double spacingSm = 8.0;

  /// 중형 여백 (기본)
  static const double spacingMd = 16.0;

  /// 대형 여백
  static const double spacingLg = 24.0;

  /// 초대형 여백
  static const double spacingXl = 32.0;

  // ── 카드·컨테이너 ──────────────────────────────────────────────
  /// 카드 기본 모서리 반경
  static const double radiusMd = 12.0;

  /// 버튼 기본 모서리 반경
  static const double radiusSm = 8.0;

  /// 통계 카드 최소 너비
  static const double statCardMinWidth = 180.0;

  /// 통계 카드 높이
  static const double statCardHeight = 100.0;

  // ── 아이콘 ──────────────────────────────────────────────────────
  /// 네비게이션 아이콘 크기
  static const double iconNavSize = 24.0;
}

// [파일 요약]
// 반응형 레이아웃을 위한 브레이크포인트(desktop 1024, tablet 600),
// 사이드바 너비(240/64), 여백, 카드 크기 등 UI 수치 상수를 중앙 관리합니다.
