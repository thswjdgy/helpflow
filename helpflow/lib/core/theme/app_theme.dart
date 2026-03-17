import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../design_system.dart';

/// 앱 전체 Material 3 테마 정의
/// 라이트 테마와 다크 테마를 모두 제공하며,
/// HelpFlow 디자인 시스템(design_system.dart)의 색상·타이포그래피·버튼 스타일을 연동합니다.
class AppTheme {
  AppTheme._(); // 인스턴스 생성 방지

  // ── 라이트 테마 ──────────────────────────────────────────────
  /// 라이트 모드 테마 객체
  /// HelpFlowColors.primary를 씨드 컬러로 사용하고,
  /// 주요 색상을 디자인 시스템 상수로 명시적 오버라이드합니다.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HelpFlowColors.primary, // 디자인 시스템 primary 사용
      brightness: Brightness.light,
      surface: HelpFlowColors.surface, // 카드·시트 표면색 명시
      error: HelpFlowColors.error, // 디자인 시스템 error 색상
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // 전체 Scaffold 배경색을 순백색으로 통일
      scaffoldBackgroundColor: HelpFlowColors.background,

      // 텍스트 테마 — HelpFlowTextStyles 연동
      textTheme: TextTheme(
        displayLarge: HelpFlowTextStyles.headline1,
        headlineLarge: HelpFlowTextStyles.headline1,
        headlineMedium: HelpFlowTextStyles.headline2,
        titleLarge: HelpFlowTextStyles.headline3,
        bodyLarge: HelpFlowTextStyles.body1,
        bodyMedium: HelpFlowTextStyles.body2,
        bodySmall: HelpFlowTextStyles.caption,
        labelLarge: HelpFlowTextStyles.button,
      ),

      // AppBar 스타일
      appBarTheme: AppBarTheme(
        backgroundColor: HelpFlowColors.background,
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
        color: HelpFlowColors.surface,
      ),

      // FilledButton — 디자인 시스템 스타일 적용 (radius 12)
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),

      // OutlinedButton — 디자인 시스템 스타일 적용
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),

      // TextButton — 디자인 시스템 스타일 적용
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),

      // NavigationRail 스타일 (태블릿·데스크탑 사이드바)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: HelpFlowColors.gray100,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: const IconThemeData(color: HelpFlowColors.gray400),
      ),

      // NavigationBar 스타일 (모바일 하단 탭)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HelpFlowColors.background,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(HelpFlowTextStyles.caption),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: HelpFlowColors.gray100,
        space: 1,
      ),
    );
  }

  // ── 다크 테마 ──────────────────────────────────────────────
  /// 다크 모드 테마 객체
  /// 동일한 씨드 컬러를 사용하되 brightness를 dark로 설정합니다.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HelpFlowColors.primary,
      brightness: Brightness.dark,
      error: HelpFlowColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // 텍스트 테마 — HelpFlowTextStyles 연동 (다크 모드 공통 적용)
      textTheme: TextTheme(
        displayLarge: HelpFlowTextStyles.headline1,
        headlineLarge: HelpFlowTextStyles.headline1,
        headlineMedium: HelpFlowTextStyles.headline2,
        titleLarge: HelpFlowTextStyles.headline3,
        bodyLarge: HelpFlowTextStyles.body1,
        bodyMedium: HelpFlowTextStyles.body2,
        bodySmall: HelpFlowTextStyles.caption,
        labelLarge: HelpFlowTextStyles.button,
      ),

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

      // FilledButton — 디자인 시스템 스타일 적용
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),

      // OutlinedButton — 디자인 시스템 스타일 적용
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),

      // TextButton — 디자인 시스템 스타일 적용
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),

      // NavigationRail 스타일 (다크)
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
// HelpFlow 디자인 시스템(design_system.dart)과 연동하여:
// - 씨드 컬러: HelpFlowColors.primary (0xFF0057FF)
// - 배경색: HelpFlowColors.background (라이트) / AppColors.backgroundDark (다크)
// - 텍스트 테마: HelpFlowTextStyles 전체 계층 매핑
// - 버튼 테마: HelpFlowButtonStyles (radius 12) 적용
// - NavigationBar/Rail 테마 포함
