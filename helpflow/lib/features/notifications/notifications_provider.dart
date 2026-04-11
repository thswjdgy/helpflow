import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/notifications/notifications_screen.dart';

/// 알림 목록 상태를 관리하는 Notifier
/// - kMockNotifications를 초기값으로 사용
/// - 읽음 처리(markRead) / 전체 읽음(markAllRead) 지원
/// - FCM 연동 시 build()에서 Firebase 스트림으로 교체합니다.
class NotificationsNotifier extends Notifier<List<MockNotification>> {
  /// 초기 상태: 목업 알림 목록 복사본
  @override
  List<MockNotification> build() {
    return List.from(kMockNotifications);
  }

  /// 특정 알림을 읽음으로 표시
  void markRead(String notificationId) {
    state = [
      for (final n in state)
        if (n.id == notificationId) n.copyWith(isRead: true) else n,
    ];
  }

  /// 모든 알림을 읽음으로 표시
  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  /// 새 알림을 목록 맨 앞에 추가 (티켓 접수·상태변경·담당자배정 시 호출)
  void addNotification(MockNotification notification) {
    state = [notification, ...state];
  }

  /// 안읽음 알림 개수 (TopBar 뱃지에 사용)
  int get unreadCount => state.where((n) => !n.isRead).length;
}

/// 앱 전역 알림 Provider
final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<MockNotification>>(
  NotificationsNotifier.new,
);

/// 안읽음 알림 개수만 노출하는 파생 Provider (TopBar에서 성능 최적화)
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

// [파일 요약]
// 알림 상태를 전역으로 관리하는 Riverpod Provider입니다.
// NotificationsNotifier: 알림 목록 + markRead/markAllRead 메서드
// notificationsProvider: 알림 목록 전체 상태
// unreadCountProvider: 안읽음 개수 파생 Provider (TopBar 뱃지 최적화)
// FCM 연동 시 build()를 Firebase 메시지 스트림으로 교체합니다.
