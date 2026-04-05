import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';

// ── 목업 알림 데이터 ──────────────────────────────────────────
/// 알림 타입 enum
enum NotificationType {
  /// 새 티켓 접수 (AGENT·ADMIN에게 전송)
  newTicket,

  /// 티켓 담당자 배정 (AGENT에게 전송)
  ticketAssigned,

  /// 티켓 상태 변경 (접수자에게 전송)
  statusChanged,

  /// 처리 내용 저장 (접수자에게 전송)
  noteAdded,
}

/// 목업 알림 데이터 모델
class MockNotification {
  final String id;
  final NotificationType type;
  final String ticketId;
  final String ticketTitle;
  final String message;
  final DateTime createdAt;

  /// 읽음 여부 (로컬 상태로만 관리)
  final bool isRead;

  const MockNotification({
    required this.id,
    required this.type,
    required this.ticketId,
    required this.ticketTitle,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  /// 읽음 상태를 변경한 복사본 반환
  MockNotification copyWith({bool? isRead}) {
    return MockNotification(
      id: id,
      type: type,
      ticketId: ticketId,
      ticketTitle: ticketTitle,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 목업 알림 목록 (8건)
final List<MockNotification> kMockNotifications = [
  MockNotification(
    id: 'noti-001',
    type: NotificationType.newTicket,
    ticketId: 'HF-001',
    ticketTitle: '로그인 화면 접속 불가',
    message: '새 티켓이 접수되었습니다 — 긴급',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  MockNotification(
    id: 'noti-002',
    type: NotificationType.ticketAssigned,
    ticketId: 'HF-002',
    ticketTitle: '비밀번호 재설정 이메일 미수신',
    message: '이지훈님이 담당자로 배정되었습니다',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: true,
  ),
  MockNotification(
    id: 'noti-003',
    type: NotificationType.statusChanged,
    ticketId: 'HF-004',
    ticketTitle: '사내 메신저 파일 전송 오류',
    message: '상태가 "완료"로 변경되었습니다',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: true,
  ),
  MockNotification(
    id: 'noti-004',
    type: NotificationType.newTicket,
    ticketId: 'HF-005',
    ticketTitle: '프린터 드라이버 설치 요청',
    message: '새 티켓이 접수되었습니다 — 낮음',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  MockNotification(
    id: 'noti-005',
    type: NotificationType.ticketAssigned,
    ticketId: 'HF-003',
    ticketTitle: '업무용 노트북 화면 깜빡임',
    message: '박수진님이 담당자로 배정되었습니다',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  MockNotification(
    id: 'noti-006',
    type: NotificationType.noteAdded,
    ticketId: 'HF-002',
    ticketTitle: '비밀번호 재설정 이메일 미수신',
    message: '처리 내용이 추가되었습니다',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
  MockNotification(
    id: 'noti-007',
    type: NotificationType.statusChanged,
    ticketId: 'HF-011',
    ticketTitle: '결제 모듈 500 오류 긴급',
    message: '상태가 "완료"로 변경되었습니다',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
  MockNotification(
    id: 'noti-008',
    type: NotificationType.newTicket,
    ticketId: 'HF-012',
    ticketTitle: '사무실 3층 와이파이 신호 약함',
    message: '새 티켓이 접수되었습니다 — 중간',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
  ),
];

// ── 알림 화면 ─────────────────────────────────────────────────
/// 알림 목록 화면
/// 타입별 아이콘, 읽음/안읽음 구분, 탭 시 해당 티켓 상세로 이동합니다.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// 로컬 알림 목록 (읽음 상태 변경 관리)
  late List<MockNotification> _notifications;

  @override
  void initState() {
    super.initState();
    // 목업 데이터를 로컬 복사본으로 관리
    _notifications = List.from(kMockNotifications);
  }

  /// 모두 읽음 처리
  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  /// 개별 알림 탭 — 읽음 처리 후 해당 티켓 상세로 이동
  void _onTap(MockNotification noti) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == noti.id);
      if (idx != -1) {
        _notifications[idx] = noti.copyWith(isRead: true);
      }
    });
    context.go('/tickets/${noti.ticketId}');
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Column(
        children: [
          // 상단 요약 바 (안읽음 건수 + 모두읽음 버튼)
          _NotificationHeader(
            unreadCount: _unreadCount,
            onMarkAllRead: _unreadCount > 0 ? _markAllRead : null,
          ),
          const Divider(height: 1),

          // 알림 목록
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Text(
                      '알림이 없습니다',
                      style: HelpFlowTextStyles.body2
                          .copyWith(color: HelpFlowColors.gray400),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, i) => _NotificationTile(
                      notification: _notifications[i],
                      onTap: () => _onTap(_notifications[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 헤더 ──────────────────────────────────────────────────────
/// 안읽음 건수 표시 + 모두 읽음 버튼
class _NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const _NotificationHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HelpFlowSpacing.lg, vertical: HelpFlowSpacing.md),
      child: Row(
        children: [
          Text(
            unreadCount > 0 ? '읽지 않은 알림 $unreadCount건' : '모든 알림을 읽었습니다',
            style: const TextStyle(
                fontSize: 13,
                color: HelpFlowColors.gray400,
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              child: const Text('모두 읽음'),
            ),
        ],
      ),
    );
  }
}

// ── 알림 타일 ─────────────────────────────────────────────────
/// 개별 알림을 표시하는 ListTile 래퍼
class _NotificationTile extends StatelessWidget {
  final MockNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  /// 알림 타입 → 아이콘 반환
  static IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.newTicket:
        return Icons.fiber_new_outlined;
      case NotificationType.ticketAssigned:
        return Icons.person_add_outlined;
      case NotificationType.statusChanged:
        return Icons.update_outlined;
      case NotificationType.noteAdded:
        return Icons.note_add_outlined;
    }
  }

  /// 알림 타입 → 색상 반환
  static Color _color(NotificationType type) {
    switch (type) {
      case NotificationType.newTicket:
        return AppColors.statusNew;
      case NotificationType.ticketAssigned:
        return AppColors.info;
      case NotificationType.statusChanged:
        return AppColors.success;
      case NotificationType.noteAdded:
        return AppColors.warning;
    }
  }

  /// DateTime → 상대 시간 문자열
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(notification.type);
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        // 안읽음: 연한 배경 강조
        color: isUnread
            ? AppColors.info.withAlpha(12)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
            horizontal: HelpFlowSpacing.lg, vertical: HelpFlowSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타입 아이콘 (컬러 원형 배경)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(notification.type), size: 20, color: color),
            ),
            const SizedBox(width: HelpFlowSpacing.md),

            // 메시지 + 티켓 제목 + 시간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 안읽음 파란 점
                      if (isUnread) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.ticketTitle,
                    style: const TextStyle(
                        fontSize: 12, color: HelpFlowColors.gray400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: HelpFlowColors.gray400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [파일 요약]
// 알림 화면입니다.
// MockNotification: 알림 타입·티켓 ID·읽음 여부를 포함하는 목업 데이터 모델
// NotificationsScreen: 알림 목록 표시 + 개별 읽음 처리 + 모두 읽음 처리
// _NotificationTile: 타입별 아이콘·색상 + 안읽음 강조(파란 배경·점) + 탭 시 티켓 상세 이동
// FCM 연동 시 kMockNotifications → notificationsProvider Stream으로 교체합니다.
