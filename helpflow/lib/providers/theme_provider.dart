import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 다크모드 상태를 관리하는 Notifier
/// bool 값: false = 라이트 모드, true = 다크 모드
class ThemeNotifier extends Notifier<bool> {
  /// 초기 상태: 라이트 모드
  @override
  bool build() => false;

  /// 라이트 ↔ 다크 모드 토글
  void toggle() {
    state = !state;
  }

  /// 특정 모드 강제 설정
  void setDark({required bool isDark}) {
    state = isDark;
  }
}

/// 전역 테마 프로바이더
/// 사용 예: final isDark = ref.watch(themeProvider);
final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);

// [파일 요약]
// Riverpod NotifierProvider를 사용하여 앱 전체의 다크모드 상태(bool)를 관리합니다.
// toggle()으로 라이트/다크 전환, setDark()로 명시적 설정이 가능합니다.
// App 위젯에서 ref.watch(themeProvider)로 구독하여 ThemeMode를 결정합니다.
