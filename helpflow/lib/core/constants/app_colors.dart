import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 상수 정의
/// 라이트/다크 모드 기준 색상을 모두 포함
class AppColors {
  AppColors._(); // 인스턴스 생성 방지

  // ── 브랜드 컬러 ──────────────────────────────────────────────
  /// 주요 시드 컬러 (파란색 계열)
  static const Color primary = Color(0xFF0057FF);

  // ── 라이트 모드 배경 ─────────────────────────────────────────
  /// 라이트 모드 전체 페이지 배경 (순백)
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// 라이트 모드 사이드바 배경
  static const Color sidebarLight = Color(0xFFF8F9FA);

  /// 라이트 모드 카드 배경 (순백 — border로 구분)
  static const Color cardLight = Color(0xFFFFFFFF);

  /// 라이트 모드 카드 테두리
  static const Color cardBorderLight = Color(0xFFE8EAED);

  /// 라이트 모드 주요 텍스트
  static const Color textLight = Color(0xFF191F28);

  // ── 다크 모드 배경 ───────────────────────────────────────────
  /// 다크 모드 전체 페이지 배경
  static const Color backgroundDark = Color(0xFF121212);

  /// 다크 모드 사이드바 배경 (배경보다 약간 밝음)
  static const Color sidebarDark = Color(0xFF1E1E1E);

  /// 다크 모드 카드 배경 (사이드바보다 약간 밝음)
  static const Color cardDark = Color(0xFF2C2C2C);

  /// 다크 모드 카드 테두리
  static const Color cardBorderDark = Color(0xFF3D3D3D);

  /// 다크 모드 주요 텍스트
  static const Color textDark = Color(0xFFF0F0F0);

  /// 다크 모드 서브텍스트 (보조 정보, 레이블 등)
  static const Color subtextDark = Color(0xFFA0A0A0);

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

  // ── 구분선 ──────────────────────────────────────────────────
  /// 구분선 컬러
  static const Color divider = Color(0xFFE0E0E0);
}

// [파일 요약]
// 앱 전체에서 사용하는 색상 상수를 한 곳에서 관리합니다.
// 라이트/다크 모드 기획 스펙에 맞춰 배경·사이드바·카드·텍스트 색상을 정의합니다.
// 라이트: 배경#FFFFFF / 사이드바#F8F9FA / 카드#FFFFFF(border #E8EAED) / 텍스트#191F28
// 다크:   배경#121212 / 사이드바#1E1E1E / 카드#2C2C2C(border #3D3D3D) / 텍스트#F0F0F0
