import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';

/// go_router 의 refreshListenable 로 사용하는 ChangeNotifier
/// authProvider 인증 상태가 변경될 때마다 GoRouter 에게
/// redirect 재평가를 요청한다.
class RouterNotifier extends ChangeNotifier {
  /// ref.listen 으로 authProvider 를 구독한다.
  /// 인증 상태 변경 시 notifyListeners() 를 호출해 GoRouter 를 깨운다.
  RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthUser?>>(
      authProvider,
      (_, _) => notifyListeners(), // 인증 상태 변경 → 라우터 재평가
    );
  }
}

/// RouterNotifier 를 Riverpod Provider 로 제공
/// GoRouter 생성 시 refreshListenable 에 전달한다.
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  // Provider 해제 시 ChangeNotifier 메모리 해제
  ref.onDispose(notifier.dispose);
  return notifier;
});

// ============================================================
// [파일 요약]
// 파일명: router_notifier.dart
// 역할: 인증 상태 변경을 go_router 에 전달하는 ChangeNotifier
// 주요 클래스/함수: RouterNotifier, routerNotifierProvider
// 연관 파일: auth_provider.dart, app_router.dart
// ============================================================
