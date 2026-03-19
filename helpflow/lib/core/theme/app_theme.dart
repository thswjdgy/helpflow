import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../design_system.dart';

/// 앱 전체 Material 3 테마 정의
/// 라이트/다크 테마를 모두 제공하며 기획 스펙 색상을 명시적으로 적용한다.
/// - 라이트: 배경#FFFFFF / 사이드바#F8F9FA / 카드#FFFFFF(border #E8EAED)
/// - 다크:   배경#121212 / 사이드바#1E1E1E / 카드#2C2C2C(border #3D3D3D)
class AppTheme {
  AppTheme._(); // 인스턴스 생성 방지

  // ── 라이트 테마 ──────────────────────────────────────────────
  /// 라이트 모드 테마 객체
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HelpFlowColors.primary,
      brightness: Brightness.light,
      // 카드·컨테이너 표면색 명시 (#FFFFFF — border 로 배경과 구분)
      surface: HelpFlowColors.surface,
      // 주요 텍스트 색상 명시
      onSurface: AppColors.textLight,
      error: HelpFlowColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Scaffold 전체 배경 (순백)
      scaffoldBackgroundColor: AppColors.backgroundLight,

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

      // AppBar: 배경 = 페이지 배경과 동일 (구분선으로 분리)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // 카드: 순백 배경 + #E8EAED 테두리 (elevation 없음)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: AppColors.cardBorderLight),
        ),
        color: AppColors.cardLight,
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),

      // NavigationRail (태블릿·데스크탑 사이드바 테마 기본값)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarLight,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: const IconThemeData(color: HelpFlowColors.gray400),
      ),

      // NavigationBar (모바일 하단 탭)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(HelpFlowTextStyles.caption),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorderLight,
        space: 1,
      ),
    );
  }

  // ── 다크 테마 ──────────────────────────────────────────────
  /// 다크 모드 테마 객체
  /// 모든 주요 색상을 명시적으로 지정해 플랫폼 자동 생성값에 의존하지 않는다.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HelpFlowColors.primary,
      brightness: Brightness.dark,
      // 카드 표면색 명시 (#2C2C2C)
      surface: AppColors.cardDark,
      // 주요 텍스트 (#F0F0F0)
      onSurface: AppColors.textDark,
      // 보조 텍스트 / 아이콘 (#A0A0A0)
      onSurfaceVariant: AppColors.subtextDark,
      error: HelpFlowColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Scaffold 전체 배경 (#121212)
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // 텍스트 테마 — 색상은 colorScheme.onSurface 에서 자동 상속
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

      // AppBar: 사이드바와 동일한 색상(#1E1E1E)으로 상단 영역 통일
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sidebarDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // 카드: #2C2C2C 배경 + #3D3D3D 테두리
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: AppColors.cardBorderDark),
        ),
        color: AppColors.cardDark,
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),

      // NavigationRail: 사이드바 색상 (#1E1E1E)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: const IconThemeData(color: AppColors.subtextDark),
      ),

      // NavigationBar (모바일 하단 탭)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.sidebarDark,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(HelpFlowTextStyles.caption),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorderDark,
        space: 1,
      ),
    );
  }
}

// [파일 요약]
// 파일명: app_theme.dart
// 역할: Material 3 라이트/다크 테마 정의 — 기획 스펙 색상 명시 적용
// 주요 클래스/함수: AppTheme.lightTheme, AppTheme.darkTheme
// 연관 파일: app_colors.dart, design_system.dart, main_layout.dart, top_bar_widget.dart
