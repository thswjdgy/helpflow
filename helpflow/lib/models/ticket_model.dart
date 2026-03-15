import 'package:hive_flutter/hive_flutter.dart';

part 'ticket_model.g.dart';

/// 티켓 상태 열거형
/// Hive에서 int로 직렬화 (HiveField 인덱스와 대응)
@HiveType(typeId: 1)
enum TicketStatus {
  @HiveField(0)
  newTicket, // 새 티켓

  @HiveField(1)
  inProgress, // 처리중

  @HiveField(2)
  done, // 완료

  @HiveField(3)
  onHold, // 보류
}

/// 티켓 우선순위 열거형
@HiveType(typeId: 2)
enum TicketPriority {
  @HiveField(0)
  low, // 낮음

  @HiveField(1)
  medium, // 중간

  @HiveField(2)
  high, // 높음

  @HiveField(3)
  urgent, // 긴급
}

/// 헬프데스크 티켓 데이터 모델
/// Hive를 통해 로컬 저장소에 영속화
@HiveType(typeId: 0)
class TicketModel extends HiveObject {
  /// 고유 식별자 (UUID 형식 권장)
  @HiveField(0)
  late String id;

  /// 티켓 제목
  @HiveField(1)
  late String title;

  /// 티켓 상세 설명
  @HiveField(2)
  late String description;

  /// 현재 처리 상태
  @HiveField(3)
  late TicketStatus status;

  /// 우선순위
  @HiveField(4)
  late TicketPriority priority;

  /// 티켓 생성일시
  @HiveField(5)
  late DateTime createdAt;

  /// 마지막 수정일시
  @HiveField(6)
  late DateTime updatedAt;

  /// 담당자 이름 (선택)
  @HiveField(7)
  String? assignee;

  /// TicketModel 생성자
  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = TicketStatus.newTicket,
    this.priority = TicketPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.assignee,
  });

  /// 상태 레이블 문자열 반환
  String get statusLabel {
    switch (status) {
      case TicketStatus.newTicket:
        return '새 티켓';
      case TicketStatus.inProgress:
        return '처리중';
      case TicketStatus.done:
        return '완료';
      case TicketStatus.onHold:
        return '보류';
    }
  }

  /// 우선순위 레이블 문자열 반환
  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return '낮음';
      case TicketPriority.medium:
        return '중간';
      case TicketPriority.high:
        return '높음';
      case TicketPriority.urgent:
        return '긴급';
    }
  }
}

// [파일 요약]
// 헬프데스크 티켓의 데이터 모델을 정의합니다.
// Hive TypeAdapter를 통해 로컬 DB에 영속화하며,
// TicketStatus(새/처리중/완료/보류), TicketPriority(낮음~긴급) 열거형을 포함합니다.
// ticket_model.g.dart는 `flutter pub run build_runner build` 실행 시 자동 생성됩니다.
