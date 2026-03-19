import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// 앱 루트 위젯
/// - themeProvider 로 라이트/다크 테마를 동적 전환
/// - routerProvider 로 인증 상태 기반 go_router 연동
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크모드 상태 구독 (변경 시 자동 리빌드)
    final isDark = ref.watch(themeProvider);

    // routerProvider: 인증 리다이렉트가 포함된 GoRouter 인스턴스
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,

      // 다크모드 여부에 따라 ThemeMode 결정
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // 라이트 테마
      theme: AppTheme.lightTheme,

      // 다크 테마
      darkTheme: AppTheme.darkTheme,

      // 인증 리다이렉트가 포함된 GoRouter 연결
      routerConfig: router,

      // 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
    );
  }
}

// [파일 요약]
// 앱 루트 위젯(App)을 정의합니다.
// themeProvider 로 라이트/다크 테마를 동적 전환하고,
// routerProvider(인증 리다이렉트 포함)를 MaterialApp.router 에 연결합니다.
