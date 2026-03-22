import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_model.dart';

/// Firestore 기반 티켓 CRUD 서비스
///
/// Firestore 컬렉션 'tickets'에 대한 생성·조회·수정·삭제를 담당합니다.
/// 에러 발생 시 한글 메시지로 변환하여 예외를 다시 던집니다.
class TicketService {
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore 컬렉션 이름
  static const String _collection = 'tickets';

  /// tickets 컬렉션 참조 반환 헬퍼
  CollectionReference<Map<String, dynamic>> get _ticketsRef =>
      _firestore.collection(_collection);

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  /// Firestore에 새 티켓을 저장합니다.
  ///
  /// [ticket] 저장할 티켓 모델. ticket.id를 문서 ID로 사용합니다.
  Future<void> createTicket(TicketModel ticket) async {
    try {
      await _ticketsRef.doc(ticket.id).set(ticket.toMap());
    } on FirebaseException catch (e) {
      throw _toKoreanError('티켓 생성', e);
    } catch (e) {
      throw Exception('티켓 생성 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // ─────────────────────────────────────────────
  // READ (Stream)
  // ─────────────────────────────────────────────

  /// 전체 티켓 목록을 실시간 Stream으로 반환합니다.
  ///
  /// createdAt 기준 내림차순(최신 먼저) 정렬
  Stream<List<TicketModel>> getTickets() {
    return _ticketsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TicketModel.fromFirestore)
              .toList(),
        );
  }

  // ─────────────────────────────────────────────
  // READ (단건)
  // ─────────────────────────────────────────────

  /// 문서 ID로 단일 티켓을 조회합니다.
  ///
  /// [id] Firestore 문서 ID
  /// 존재하지 않으면 null을 반환합니다.
  Future<TicketModel?> getTicketById(String id) async {
    try {
      final doc = await _ticketsRef.doc(id).get();
      if (!doc.exists) return null;
      return TicketModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _toKoreanError('티켓 조회', e);
    } catch (e) {
      throw Exception('티켓 조회 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  /// 기존 티켓 정보를 수정합니다.
  ///
  /// [ticket] 수정할 티켓 모델 (ticket.id로 문서를 찾아 덮어씁니다)
  Future<void> updateTicket(TicketModel ticket) async {
    try {
      await _ticketsRef.doc(ticket.id).update(ticket.toMap());
    } on FirebaseException catch (e) {
      throw _toKoreanError('티켓 수정', e);
    } catch (e) {
      throw Exception('티켓 수정 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  /// 티켓을 Firestore에서 삭제합니다.
  ///
  /// [id] 삭제할 티켓의 Firestore 문서 ID
  Future<void> deleteTicket(String id) async {
    try {
      await _ticketsRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw _toKoreanError('티켓 삭제', e);
    } catch (e) {
      throw Exception('티켓 삭제 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // ─────────────────────────────────────────────
  // 에러 변환 헬퍼
  // ─────────────────────────────────────────────

  /// FirebaseException을 한글 메시지 Exception으로 변환합니다.
  ///
  /// [action] 어떤 동작 중 에러가 발생했는지 (예: '티켓 생성')
  /// [e]      원본 FirebaseException
  Exception _toKoreanError(String action, FirebaseException e) {
    final message = switch (e.code) {
      'permission-denied' => '권한이 없습니다. 로그인 상태를 확인해 주세요.',
      'not-found' => '요청한 티켓을 찾을 수 없습니다.',
      'unavailable' => '서버에 연결할 수 없습니다. 네트워크를 확인해 주세요.',
      'deadline-exceeded' => '요청 시간이 초과되었습니다. 다시 시도해 주세요.',
      _ => 'Firestore 오류 (${e.code}): ${e.message}',
    };
    return Exception('[$action 실패] $message');
  }
}

// ============================================================
// [파일 요약]
// 파일명: lib/shared/services/ticket_service.dart
// 역할: Firestore 'tickets' 컬렉션에 대한 CRUD 서비스
// 주요 클래스: TicketService
// 주요 메서드:
//   - createTicket()  : 티켓 생성 (set)
//   - getTickets()    : 전체 목록 Stream 반환 (snapshots)
//   - getTicketById() : 단일 티켓 조회 (get)
//   - updateTicket()  : 티켓 수정 (update)
//   - deleteTicket()  : 티켓 삭제 (delete)
//   - _toKoreanError(): FirebaseException → 한글 메시지 변환
// 연관 파일: ticket_model.dart, ticket_provider.dart
// ============================================================
