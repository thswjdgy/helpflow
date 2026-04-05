// HelpFlow 티켓 목업 데이터
// Firestore 연동 전까지 목록·상세 화면에서 공통으로 사용하는 임시 데이터입니다.
// Firebase 연동 주차에 이 파일을 제거하고 ticketProvider로 교체합니다.

/// 목업 티켓 데이터 모델
/// shared/models/ticket_model.dart (Firestore 연동용)과 동일한 필드 구조를 유지합니다.
class MockTicket {
  /// 티켓 고유 ID (예: HF-001)
  final String id;

  /// 티켓 제목
  final String title;

  /// 티켓 상세 설명
  final String description;

  /// 처리 상태: 'new' | 'in_progress' | 'resolved' | 'closed'
  final String status;

  /// 우선순위: 'critical' | 'high' | 'medium' | 'low'
  final String priority;

  /// 카테고리: 'hardware' | 'software' | 'network' | 'etc'
  final String category;

  /// 접수자 이메일
  final String reporterEmail;

  /// 티켓 접수 일시
  final DateTime createdAt;

  /// 배정된 에이전트 ID (미배정 시 null)
  final String? agentId;

  /// 배정된 에이전트 이름 (미배정 시 null)
  final String? agentName;

  const MockTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.reporterEmail,
    required this.createdAt,
    this.agentId,
    this.agentName,
  });
}

/// 목업 티켓 목록 (12건)
/// createdAt은 앱 실행 시점 기준으로 상대 시간 계산에 사용됩니다.
final List<MockTicket> kMockTickets = [
  MockTicket(
    id: 'HF-001',
    title: '로그인 화면 접속 불가',
    description: '사내 네트워크에서 로그인 화면이 로딩되지 않습니다.\n오류 코드: ERR_CONNECTION_REFUSED',
    status: 'new',
    priority: 'critical',
    category: 'network',
    reporterEmail: 'kim@company.com',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  MockTicket(
    id: 'HF-002',
    title: '비밀번호 재설정 이메일 미수신',
    description: '비밀번호 재설정 요청 후 이메일이 도착하지 않습니다.\n스팸함도 확인했습니다.',
    status: 'in_progress',
    priority: 'high',
    category: 'software',
    reporterEmail: 'lee@company.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    agentId: 'agent-001',
    agentName: '이지훈',
  ),
  MockTicket(
    id: 'HF-003',
    title: '업무용 노트북 화면 깜빡임',
    description: '노트북 화면이 간헐적으로 깜빡입니다.\n외부 모니터 연결 시에는 정상 동작합니다.',
    status: 'in_progress',
    priority: 'medium',
    category: 'hardware',
    reporterEmail: 'park@company.com',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    agentId: 'agent-002',
    agentName: '박수진',
  ),
  MockTicket(
    id: 'HF-004',
    title: '사내 메신저 파일 전송 오류',
    description: '10MB 이상 파일 전송 시 "업로드 실패" 오류가 발생합니다.',
    status: 'resolved',
    priority: 'medium',
    category: 'software',
    reporterEmail: 'choi@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    agentId: 'agent-001',
    agentName: '이지훈',
  ),
  MockTicket(
    id: 'HF-005',
    title: '프린터 드라이버 설치 요청',
    description: '신규 입사자용 프린터 드라이버 설치 요청드립니다.\n기종: HP LaserJet Pro MFP M428fdn',
    status: 'new',
    priority: 'low',
    category: 'hardware',
    reporterEmail: 'jung@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  MockTicket(
    id: 'HF-006',
    title: '재무 시스템 접근 권한 요청',
    description: '재무팀 이동 후 재무 시스템 접근이 차단됩니다.\n권한 부여를 요청드립니다.',
    status: 'in_progress',
    priority: 'high',
    category: 'software',
    reporterEmail: 'yoon@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    agentId: 'agent-003',
    agentName: '최민준',
  ),
  MockTicket(
    id: 'HF-007',
    title: 'VPN 연결 속도 저하',
    description: '재택근무 시 VPN 연결 속도가 매우 느립니다.\n핑 250ms 이상 측정됩니다.',
    status: 'closed',
    priority: 'medium',
    category: 'network',
    reporterEmail: 'han@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  MockTicket(
    id: 'HF-008',
    title: '우클릭 컨텍스트 메뉴 표시 안 됨',
    description: '윈도우 탐색기에서 우클릭 컨텍스트 메뉴가 표시되지 않습니다.',
    status: 'resolved',
    priority: 'low',
    category: 'software',
    reporterEmail: 'oh@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    agentId: 'agent-004',
    agentName: '정다은',
  ),
  MockTicket(
    id: 'HF-009',
    title: '외장 하드 인식 불가',
    description: 'USB 3.0 외장 하드가 이 PC에서 인식되지 않습니다.\n다른 PC에서는 정상 인식됩니다.',
    status: 'new',
    priority: 'high',
    category: 'hardware',
    reporterEmail: 'shin@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  MockTicket(
    id: 'HF-010',
    title: '이메일 대용량 첨부 오류',
    description: '20MB 초과 파일 첨부 시 "첨부 파일 크기 초과" 오류가 발생합니다.\n기존에는 30MB까지 가능했습니다.',
    status: 'in_progress',
    priority: 'medium',
    category: 'etc',
    reporterEmail: 'back@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    agentId: 'agent-005',
    agentName: '한승우',
  ),
  MockTicket(
    id: 'HF-011',
    title: '결제 모듈 500 오류 긴급',
    description: '온라인 결제 모듈에서 500 오류 발생.\n현재 모든 결제가 차단된 상태입니다.',
    status: 'resolved',
    priority: 'critical',
    category: 'software',
    reporterEmail: 'kwon@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    agentId: 'agent-001',
    agentName: '이지훈',
  ),
  MockTicket(
    id: 'HF-012',
    title: '사무실 3층 와이파이 신호 약함',
    description: '3층 회의실 와이파이 신호가 약해서 화상회의 중 연결이 자주 끊깁니다.',
    status: 'new',
    priority: 'medium',
    category: 'network',
    reporterEmail: 'song@company.com',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
];

// [파일 요약]
// HelpFlow 티켓 목업 데이터 파일입니다.
// MockTicket: Firestore TicketModel과 동일한 필드 구조의 순수 Dart 데이터 모델
// kMockTickets: 12건의 목업 티켓 목록 (다양한 상태·우선순위·카테고리 조합)
// Firestore 연동 시 이 파일을 제거하고 ticketProvider(features/tickets/ticket_provider.dart)로 교체합니다.
