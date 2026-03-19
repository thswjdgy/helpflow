import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 인증된 사용자 정보를 담는 불변 데이터 모델
/// Firebase Auth 연동 시 User 객체로 교체 가능
@immutable
class AuthUser {
  /// 사용자 고유 ID
  final String uid;

  /// 사용자 이메일
  final String email;

  const AuthUser({required this.uid, required this.email});
}

/// 인증 상태를 관리하는 AsyncNotifier
/// - 앱 시작 시 Hive에서 저장된 인증 정보를 복원
/// - signIn / signOut 으로 상태 전환
/// - Firebase Auth 연동 시 build / signIn / signOut 내부만 교체하면 됨
class AuthNotifier extends AsyncNotifier<AuthUser?> {
  /// Hive 박스 이름 상수
  static const _boxName = 'auth_box';

  /// 앱 초기화 시 Hive에서 이전 로그인 상태 복원
  @override
  Future<AuthUser?> build() async {
    final box = await Hive.openBox(_boxName);

    // 저장된 uid, email 읽기
    final uid = box.get('uid') as String?;
    final email = box.get('email') as String?;

    // 둘 다 있을 때만 로그인 상태로 간주
    if (uid != null && email != null) {
      return AuthUser(uid: uid, email: email);
    }
    return null; // 비로그인 상태
  }

  /// 이메일/비밀번호로 로그인 후 Hive에 인증 정보 저장
  /// TODO: Firebase 연동 시 → FirebaseAuth.instance.signInWithEmailAndPassword() 로 교체
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      // 네트워크 지연 시뮬레이션 (Firebase 연동 전 임시)
      await Future.delayed(const Duration(milliseconds: 600));

      final box = await Hive.openBox(_boxName);
      final user = AuthUser(uid: 'uid-${email.hashCode}', email: email);

      // Hive에 인증 정보 영속화
      await box.put('uid', user.uid);
      await box.put('email', user.email);

      state = AsyncData(user); // 로그인 성공
    } catch (e, st) {
      state = AsyncError(e, st); // 로그인 실패
    }
  }

  /// 로그아웃: Hive 인증 정보 삭제 후 비로그인 상태로 전환
  /// TODO: Firebase 연동 시 → FirebaseAuth.instance.signOut() 추가
  Future<void> signOut() async {
    final box = await Hive.openBox(_boxName);
    await box.deleteAll(['uid', 'email']); // 저장된 인증 정보 삭제
    state = const AsyncData(null); // 비로그인 상태로 전환
  }
}

/// 앱 전역 인증 상태 Provider
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

// ============================================================
// [파일 요약]
// 파일명: auth_provider.dart
// 역할: Riverpod 기반 인증 상태 관리 (로그인/로그아웃, Hive 영속화)
// 주요 클래스/함수: AuthUser, AuthNotifier, authProvider
// 연관 파일: router_notifier.dart, login_screen.dart, app_router.dart
// ============================================================
