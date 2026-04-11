import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/notifications/notifications_screen.dart';
import '../../views/tickets/ticket_mock_data.dart';
import '../notifications/notifications_provider.dart';

/// 목업 기반 티켓 전역 상태 관리 Notifier
/// - kMockTickets를 초기값으로 사용
/// - addTicket / updateStatus / assignAgent CRUD 지원
/// - CRUD 수행 시 notificationsProvider에 자동으로 알림 추가
/// Firestore 연동 시 build()를 Stream으로 교체하고 메서드에서 Firestore 호출로 교체합니다.
class TicketsNotifier extends Notifier<List<MockTicket>> {
  /// 초기 상태: 목업 티켓 목록 복사본
  @override
  List<MockTicket> build() => List.from(kMockTickets);

  // ── 내부 헬퍼 ────────────────────────────────────────────────

  /// 다음 티켓 ID 자동 생성 (현재 최대 번호 + 1)
  /// 형식: HF-001, HF-002, …
  String _nextId() {
    final nums = state
        .map((t) => int.tryParse(t.id.replaceAll('HF-', '')) ?? 0)
        .toList();
    final maxNum = nums.isEmpty ? 0 : nums.reduce((a, b) => a > b ? a : b);
    return 'HF-${(maxNum + 1).toString().padLeft(3, '0')}';
  }

  /// 상태 값(영문) → 한국어 레이블
  static String _statusLabel(String status) {
    const map = {
      'new': '새 티켓',
      'in_progress': '처리중',
      'resolved': '완료',
      'closed': '종료',
    };
    return map[status] ?? status;
  }

  // ── 공개 메서드 ──────────────────────────────────────────────

  /// 새 티켓 접수 — ID 자동생성, 상태 'new', 알림 자동 추가
  void addTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String reporterEmail,
  }) {
    final id = _nextId();
    final newTicket = MockTicket(
      id: id,
      title: title,
      description: description,
      status: 'new',
      priority: priority,
      category: category,
      reporterEmail: reporterEmail,
      createdAt: DateTime.now(),
    );

    // 최신 티켓을 맨 앞에 추가
    state = [newTicket, ...state];

    // 새 티켓 접수 알림 추가
    ref.read(notificationsProvider.notifier).addNotification(
          MockNotification(
            id: 'noti-${DateTime.now().millisecondsSinceEpoch}',
            type: NotificationType.newTicket,
            ticketId: id,
            ticketTitle: title,
            message: '새 티켓이 접수되었습니다',
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 티켓 처리 상태 변경 — state 불변 업데이트 후 알림 추가
  void updateStatus(String ticketId, String newStatus) {
    // 알림용으로 변경 전 티켓 정보 조회
    final ticket = state.where((t) => t.id == ticketId).firstOrNull;
    if (ticket == null) return;

    state = [
      for (final t in state)
        if (t.id == ticketId) t.copyWith(status: newStatus) else t,
    ];

    // 상태 변경 알림 추가
    ref.read(notificationsProvider.notifier).addNotification(
          MockNotification(
            id: 'noti-${DateTime.now().millisecondsSinceEpoch}',
            type: NotificationType.statusChanged,
            ticketId: ticketId,
            ticketTitle: ticket.title,
            message: '상태가 "${_statusLabel(newStatus)}"(으)로 변경되었습니다',
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 담당 에이전트 배정 — state 불변 업데이트 후 알림 추가
  void assignAgent(String ticketId, String agentId, String agentName) {
    // 알림용으로 티켓 정보 조회
    final ticket = state.where((t) => t.id == ticketId).firstOrNull;
    if (ticket == null) return;

    state = [
      for (final t in state)
        if (t.id == ticketId) t.copyWith(agentId: agentId, agentName: agentName) else t,
    ];

    // 담당자 배정 알림 추가
    ref.read(notificationsProvider.notifier).addNotification(
          MockNotification(
            id: 'noti-${DateTime.now().millisecondsSinceEpoch}',
            type: NotificationType.ticketAssigned,
            ticketId: ticketId,
            ticketTitle: ticket.title,
            message: '$agentName님이 담당자로 배정되었습니다',
            createdAt: DateTime.now(),
          ),
        );
  }
}

/// 앱 전역 티켓 목록 Provider (목업 기반)
/// - Firestore 연동 시 AsyncNotifierProvider 버전으로 교체합니다.
final ticketsProvider =
    NotifierProvider<TicketsNotifier, List<MockTicket>>(TicketsNotifier.new);

// [파일 요약]
// 목업 기반 티켓 전역 상태 Provider입니다.
// TicketsNotifier: addTicket / updateStatus / assignAgent CRUD 메서드
//   - 각 CRUD 수행 시 notificationsProvider에 자동으로 알림 추가
//   - ID는 현재 최대 번호 + 1 방식으로 자동 생성 (HF-013, HF-014, …)
// ticketsProvider: 앱 전역 티켓 목록 NotifierProvider
// Firestore 연동 시 features/tickets/ticket_provider.dart (AsyncNotifier 버전)로 교체합니다.
