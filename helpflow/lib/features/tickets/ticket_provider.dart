import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/ticket_model.dart';
import '../../shared/services/ticket_service.dart';

/// 티켓 목록 상태를 관리하는 AsyncNotifier
///
/// AsyncNotifierProvider 패턴을 사용하여 Firestore에서 티켓 목록을 로드하고
/// 생성·수정·삭제 작업 후 상태를 갱신합니다.
class TicketNotifier extends AsyncNotifier<List<TicketModel>> {
  /// 티켓 CRUD 서비스 인스턴스
  late final TicketService _service;

  /// 초기 데이터 로드 — Firestore Stream의 첫 번째 값을 반환합니다.
  ///
  /// 이 메서드는 Provider가 처음 읽힐 때 자동으로 호출됩니다.
  @override
  Future<List<TicketModel>> build() async {
    _service = TicketService();
    // Stream에서 첫 번째 값(초기 목록)을 가져와서 반환
    return _service.getTickets().first;
  }

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  /// 새 티켓을 Firestore에 저장하고 상태를 갱신합니다.
  ///
  /// [ticket] 저장할 티켓 모델
  Future<void> createTicket(TicketModel ticket) async {
    // 작업 중 로딩 상태로 전환
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.createTicket(ticket);
      // 최신 목록을 다시 가져와서 상태 갱신
      return _service.getTickets().first;
    });
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  /// 기존 티켓을 수정하고 상태를 갱신합니다.
  ///
  /// [ticket] 수정된 티켓 모델 (ticket.id 기준으로 Firestore 문서를 찾아 덮어씁니다)
  Future<void> updateTicket(TicketModel ticket) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.updateTicket(ticket);
      return _service.getTickets().first;
    });
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  /// 티켓을 삭제하고 상태를 갱신합니다.
  ///
  /// [id] 삭제할 티켓의 Firestore 문서 ID
  Future<void> deleteTicket(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.deleteTicket(id);
      return _service.getTickets().first;
    });
  }
}

/// 앱 전역 티켓 목록 Provider
///
/// 사용 예:
/// ```dart
/// final tickets = ref.watch(ticketProvider);
/// tickets.when(
///   data: (list) => ...,
///   loading: () => const CircularProgressIndicator(),
///   error: (e, _) => Text(e.toString()),
/// );
/// ```
final ticketProvider =
    AsyncNotifierProvider<TicketNotifier, List<TicketModel>>(
  TicketNotifier.new,
);

// ============================================================
// [파일 요약]
// 파일명: lib/features/tickets/ticket_provider.dart
// 역할: Riverpod AsyncNotifierProvider 기반 티켓 목록 상태 관리
// 주요 클래스: TicketNotifier
// 주요 메서드:
//   - build()         : 초기 티켓 목록 로드 (Stream 첫 값)
//   - createTicket()  : 티켓 생성 후 목록 갱신
//   - updateTicket()  : 티켓 수정 후 목록 갱신
//   - deleteTicket()  : 티켓 삭제 후 목록 갱신
// 노출 Provider: ticketProvider
// 연관 파일: ticket_service.dart, ticket_model.dart
// ============================================================
