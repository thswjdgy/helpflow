import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// 앱 루트 위젯
/// - Riverpod ConsumerWidget으로 themeProvider를 구독
/// - 다크모드 상태에 따라 ThemeMode 동적 전환
/// - MaterialApp.router로 go_router 연동
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크모드 상태 구독 (변경 시 자동 리빌드)
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      // 앱 제목
      title: AppStrings.appName,

      // 다크모드 여부에 따라 ThemeMode 결정
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // 라이트 테마
      theme: AppTheme.lightTheme,

      // 다크 테마
      darkTheme: AppTheme.darkTheme,

      // go_router 연동
      routerConfig: AppRouter.router,

      // 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
    );
  }
}

// [파일 요약]
// 앱 루트 위젯(App)을 정의합니다.
// Riverpod ConsumerWidget으로 themeProvider를 구독하여 라이트/다크 테마를 동적으로 전환하고,
// MaterialApp.router에 AppRouter.router를 연결합니다.
