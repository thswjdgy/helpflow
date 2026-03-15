import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱 전체 Material 3 테마 정의
/// 라이트 테마와 다크 테마를 모두 제공
class AppTheme {
  AppTheme._(); // 인스턴스 생성 방지

  // ── 라이트 테마 ──────────────────────────────────────────────
  /// 라이트 모드 테마 객체
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar 스타일
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // 카드 스타일
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
      ),

      // FilledButton 스타일
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // NavigationRail 스타일
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarLight,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        space: 1,
      ),
    );
  }

  // ── 다크 테마 ──────────────────────────────────────────────
  /// 다크 모드 테마 객체
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar 스타일
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // 카드 스타일
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
      ),

      // FilledButton 스타일
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // NavigationRail 스타일
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
      ),
    );
  }
}

// [파일 요약]
// Material 3 기반의 라이트/다크 테마를 정의합니다.
// ColorScheme.fromSeed(seedColor: 0xFF0057FF)로 색상 팔레트를 자동 생성하며,
// AppBar, Card, FilledButton, NavigationRail 등 주요 컴포넌트 스타일을 포함합니다.
