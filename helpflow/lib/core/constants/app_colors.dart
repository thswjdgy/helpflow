import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 상수 정의
/// Material 3 시드 컬러 기반으로 설계
class AppColors {
  AppColors._(); // 인스턴스 생성 방지

  // ── 브랜드 컬러 ──────────────────────────────────────────────
  /// 주요 시드 컬러 (파란색 계열)
  static const Color primary = Color(0xFF0057FF);

  /// 라이트 모드 배경
  static const Color backgroundLight = Color(0xFFF8F9FB);

  /// 다크 모드 배경
  static const Color backgroundDark = Color(0xFF121318);

  // ── 상태 컬러 ──────────────────────────────────────────────
  /// 성공/완료 상태
  static const Color success = Color(0xFF2E7D32);

  /// 경고/처리중 상태
  static const Color warning = Color(0xFFF9A825);

  /// 오류/긴급 상태
  static const Color error = Color(0xFFD32F2F);

  /// 미처리 상태
  static const Color info = Color(0xFF0277BD);

  // ── 티켓 상태 컬러 ──────────────────────────────────────────
  /// 새 티켓
  static const Color statusNew = Color(0xFF1565C0);

  /// 처리중 티켓
  static const Color statusInProgress = Color(0xFFF57C00);

  /// 완료 티켓
  static const Color statusDone = Color(0xFF388E3C);

  /// 보류 티켓
  static const Color statusOnHold = Color(0xFF6D4C41);

  // ── 중립 컬러 ──────────────────────────────────────────────
  /// 사이드바 배경 (라이트)
  static const Color sidebarLight = Color(0xFFEEF2FF);

  /// 사이드바 배경 (다크)
  static const Color sidebarDark = Color(0xFF1A1D27);

  /// 구분선 컬러
  static const Color divider = Color(0xFFE0E0E0);
}

// [파일 요약]
// 앱 전체에서 사용하는 색상 상수를 한 곳에서 관리합니다.
// Material 3 시드 컬러(0xFF0057FF)를 기준으로 브랜드, 상태, 중립 색상을 정의합니다.
