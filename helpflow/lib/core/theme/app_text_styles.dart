import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 텍스트 스타일 상수 정의
/// Material 3 TextTheme 계층 구조를 따름
class AppTextStyles {
  AppTextStyles._(); // 인스턴스 생성 방지

  // ── 타이틀 계열 ──────────────────────────────────────────────
  /// 페이지 대제목 (예: 대시보드, 티켓 관리)
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 섹션 제목
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  // ── 바디 계열 ────────────────────────────────────────────────
  /// 본문 기본 (16pt)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );

  /// 본문 중간 (14pt)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );

  /// 본문 소형 (12pt)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );

  // ── 레이블 계열 ──────────────────────────────────────────────
  /// 네비게이션 레이블
  static const TextStyle navLabel = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// 통계 카드 수치
  static const TextStyle statValue = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
  );

  /// 통계 카드 레이블
  static const TextStyle statLabel = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// 버튼 텍스트
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

// [파일 요약]
// 앱 전체 텍스트 스타일(페이지 제목, 섹션 제목, 본문, 레이블 등)을
// Material 3 계층 구조를 따라 중앙 관리합니다.
