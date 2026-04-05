// HelpFlow 사용자 목업 데이터
// Firestore users 컬렉션 연동 전까지 에이전트 배정·표시에 사용하는 임시 데이터입니다.

/// 목업 사용자 데이터 모델
class MockUser {
  /// 사용자 고유 ID
  final String id;

  /// 이름
  final String name;

  /// 이메일
  final String email;

  /// 역할: 'user' | 'agent' | 'admin'
  final String role;

  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

/// 에이전트 역할 목업 사용자 목록 (5명)
/// 담당자 배정 드롭다운에서 사용합니다.
final List<MockUser> kMockAgents = [
  const MockUser(
    id: 'agent-001',
    name: '이지훈',
    email: 'ji.lee@helpflow.io',
    role: 'agent',
  ),
  const MockUser(
    id: 'agent-002',
    name: '박수진',
    email: 'su.park@helpflow.io',
    role: 'agent',
  ),
  const MockUser(
    id: 'agent-003',
    name: '최민준',
    email: 'mj.choi@helpflow.io',
    role: 'agent',
  ),
  const MockUser(
    id: 'agent-004',
    name: '정다은',
    email: 'da.jung@helpflow.io',
    role: 'agent',
  ),
  const MockUser(
    id: 'agent-005',
    name: '한승우',
    email: 'sw.han@helpflow.io',
    role: 'agent',
  ),
];

// [파일 요약]
// HelpFlow 사용자 목업 데이터 파일입니다.
// MockUser: Firestore users/{uid} 문서와 동일한 필드 구조의 순수 Dart 모델
// kMockAgents: 에이전트 역할(agent) 목업 사용자 5명 — 담당자 배정 UI에서 사용
// Firestore 연동 시 usersProvider로 교체합니다.
