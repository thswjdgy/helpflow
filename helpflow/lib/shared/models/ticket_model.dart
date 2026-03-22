import 'package:cloud_firestore/cloud_firestore.dart';

/// 헬프데스크 티켓 데이터 모델 (Firestore 연동용)
///
/// status 허용값: 'new' | 'in_progress' | 'resolved' | 'closed'
/// priority 허용값: 'low' | 'medium' | 'high' | 'critical'
/// category 허용값: 'hardware' | 'software' | 'network' | 'etc'
class TicketModel {
  /// Firestore 문서 ID
  final String id;

  /// 티켓 제목
  final String title;

  /// 티켓 상세 내용
  final String description;

  /// 처리 상태: 'new' / 'in_progress' / 'resolved' / 'closed'
  final String status;

  /// 우선순위: 'low' / 'medium' / 'high' / 'critical'
  final String priority;

  /// 카테고리: 'hardware' / 'software' / 'network' / 'etc'
  final String category;

  /// 티켓을 접수한 사용자 uid
  final String reporterId;

  /// 담당 에이전트 uid (배정 전 null)
  final String? agentId;

  /// 첨부 이미지 URL 목록
  final List<String> imageUrls;

  /// 티켓 생성 일시
  final DateTime createdAt;

  /// 마지막 수정 일시
  final DateTime updatedAt;

  /// TicketModel 생성자
  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.reporterId,
    this.agentId,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore DocumentSnapshot으로부터 TicketModel 생성
  ///
  /// [doc] Firestore에서 읽어온 문서 스냅샷
  factory TicketModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TicketModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'new',
      priority: data['priority'] as String? ?? 'medium',
      category: data['category'] as String? ?? 'etc',
      reporterId: data['reporterId'] as String? ?? '',
      agentId: data['agentId'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore에 저장할 Map 형태로 변환
  ///
  /// id는 Firestore 문서 ID로 관리하므로 Map에 포함하지 않음
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category': category,
      'reporterId': reporterId,
      'agentId': agentId,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 일부 필드만 변경한 새 TicketModel 반환 (불변 객체 패턴)
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? category,
    String? reporterId,
    String? agentId,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      reporterId: reporterId ?? this.reporterId,
      agentId: agentId ?? this.agentId,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ============================================================
// [파일 요약]
// 파일명: lib/shared/models/ticket_model.dart
// 역할: Firestore 연동 헬프데스크 티켓 데이터 모델
// 주요 클래스: TicketModel
// 주요 메서드:
//   - fromFirestore(): Firestore DocumentSnapshot → TicketModel 변환
//   - toMap(): TicketModel → Firestore 저장용 Map 변환
//   - copyWith(): 불변 객체 부분 복사
// 연관 파일: ticket_service.dart, ticket_provider.dart
// ============================================================
