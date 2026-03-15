/// 앱 전체에서 사용하는 문자열 상수 정의
/// 다국어 지원 시 이 파일을 기준으로 확장 가능
class AppStrings {
  AppStrings._(); // 인스턴스 생성 방지

  // ── 앱 기본 정보 ──────────────────────────────────────────────
  static const String appName = 'HelpFlow';
  static const String appTagline = '헬프데스크 티켓 관리 시스템';

  // ── 네비게이션 레이블 ──────────────────────────────────────────
  static const String navDashboard = '대시보드';
  static const String navTickets = '티켓 관리';
  static const String navSettings = '설정';

  // ── 대시보드 ──────────────────────────────────────────────────
  static const String dashboardTitle = '대시보드';
  static const String statsTotal = '총 티켓';
  static const String statsInProgress = '처리중';
  static const String statsDone = '완료';
  static const String statsPending = '미처리';
  static const String chartPlaceholder = '7~8주차 fl_chart 연동 예정';
  static const String recentTickets = '최근 티켓';

  // ── 티켓 ──────────────────────────────────────────────────────
  static const String ticketListTitle = '티켓 관리';
  static const String ticketDetailTitle = '티켓 상세';
  static const String ticketFormTitleNew = '새 티켓 작성';
  static const String ticketFormTitleEdit = '티켓 수정';
  static const String newTicket = '새 티켓';

  // ── 설정 ──────────────────────────────────────────────────────
  static const String settingsTitle = '설정';
  static const String darkMode = '다크 모드';

  // ── 공통 UI ──────────────────────────────────────────────────
  static const String save = '저장';
  static const String cancel = '취소';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String confirm = '확인';
  static const String loading = '로딩 중...';
  static const String emptyState = '데이터가 없습니다';
  static const String retry = '다시 시도';
}

// [파일 요약]
// 앱 전체에서 사용하는 모든 UI 문자열 상수를 중앙 관리합니다.
// 향후 다국어(l10n) 지원으로 확장 시 이 파일을 기준으로 키를 추출합니다.
