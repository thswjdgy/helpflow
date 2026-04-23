import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/notifications_provider.dart';
import '../../views/notifications/notifications_screen.dart';

// ── 처리 메모 데이터 모델 ─────────────────────────────────────
/// 티켓 처리 메모 데이터 모델
/// ticketId를 키로 메모 목록을 관리합니다.
class MockNote {
  /// 메모 고유 ID
  final String id;

  /// 연결된 티켓 ID
  final String ticketId;

  /// 메모 내용
  final String content;

  /// 작성자 이메일
  final String authorEmail;

  /// 작성 일시
  final DateTime createdAt;

  const MockNote({
    required this.id,
    required this.ticketId,
    required this.content,
    required this.authorEmail,
    required this.createdAt,
  });
}

// ── NotesNotifier ─────────────────────────────────────────────
/// 티켓별 처리 메모 목록을 관리하는 Notifier
/// 상태: Map(ticketId → List of MockNote) — 티켓 ID별 메모 리스트 보관
class NotesNotifier extends Notifier<Map<String, List<MockNote>>> {
  /// 초기 상태: 빈 맵 (메모 없음)
  @override
  Map<String, List<MockNote>> build() => {};

  /// 특정 티켓에 메모 추가
  /// 기존 메모 목록 앞에 삽입하여 최신 메모가 위에 오도록 합니다.
  void addNote({
    required String ticketId,
    required String content,
    required String authorEmail,
  }) {
    final newNote = MockNote(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      content: content,
      authorEmail: authorEmail,
      createdAt: DateTime.now(),
    );

    // 불변 업데이트: 기존 맵 복사 후 해당 ticketId 목록만 교체
    final existing = state[ticketId] ?? [];
    state = {
      ...state,
      ticketId: [newNote, ...existing],
    };

    // 처리 메모 추가 알림 자동 생성
    ref.read(notificationsProvider.notifier).addNotification(
          MockNotification(
            id: 'noti-${DateTime.now().millisecondsSinceEpoch}',
            type: NotificationType.noteAdded,
            ticketId: ticketId,
            ticketTitle: ticketId,
            message: '$authorEmail님이 처리 내용을 등록했습니다',
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 특정 티켓의 메모 목록 반환 (없으면 빈 리스트)
  List<MockNote> notesFor(String ticketId) => state[ticketId] ?? [];
}

/// 앱 전역 처리 메모 Provider
final notesProvider =
    NotifierProvider<NotesNotifier, Map<String, List<MockNote>>>(
        NotesNotifier.new);

/// 특정 티켓의 메모 목록만 구독하는 파생 Provider (family)
/// `ref.watch(notesForTicketProvider('HF-001'))` 형태로 사용합니다.
final notesForTicketProvider =
    Provider.family<List<MockNote>, String>((ref, ticketId) {
  return ref.watch(notesProvider)[ticketId] ?? [];
});

// [파일 요약]
// 티켓 처리 메모 전역 상태 Provider입니다.
// MockNote: id·ticketId·content·authorEmail·createdAt 필드를 가진 순수 Dart 모델
// NotesNotifier: Map<ticketId, List<MockNote>> 상태 관리
//   addNote(): 메모 저장 후 notificationsProvider에 noteAdded 알림 자동 추가
// notesProvider: 앱 전역 처리 메모 NotifierProvider
// notesForTicketProvider: 특정 티켓 메모 목록을 구독하는 family Provider
// Firestore 연동 시 firestore_notes_provider.dart로 교체합니다.
