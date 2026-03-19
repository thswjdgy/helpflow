import 'package:flutter/material.dart';

/// HelpFlow 통합 디자인 시스템
/// 토스(Toss) 스타일 기반: 순백색 배경, 둥근 모서리, 시스템 폰트, 절제된 UI
/// 색상·타이포그래피·버튼 스타일·여백 상수를 한 파일에서 관리합니다.

// ── 색상 ──────────────────────────────────────────────────────────────────

/// 토스 스타일 색상 팔레트
/// primary는 브랜드 파란색, gray 계열은 텍스트·배경 계층화에 사용
class HelpFlowColors {
  HelpFlowColors._(); // 인스턴스 생성 방지

  /// 브랜드 기본색 (파란색)
  static const Color primary = Color(0xFF0057FF);

  /// 앱 전체 배경색 (순백색)
  static const Color background = Color(0xFFFFFFFF);

  /// 카드·컨테이너 표면색 (라이트 모드 기준 순백 — 테두리로 배경과 구분)
  static const Color surface = Color(0xFFFFFFFF);

  /// 연한 회색 — 구분선·비활성 배경
  static const Color gray100 = Color(0xFFF2F3F5);

  /// 중간 회색 — 보조 텍스트·플레이스홀더
  static const Color gray400 = Color(0xFF8B95A1);

  /// 진한 회색 — 기본 서브 텍스트
  static const Color gray700 = Color(0xFF4E5968);

  /// 오류·경고 색상 (빨간색)
  static const Color error = Color(0xFFFF4D4F);
}

// ── 타이포그래피 ───────────────────────────────────────────────────────────

/// 시스템 폰트 기반 텍스트 스타일 정의
/// headline1~3: 제목 계열 / body1~2: 본문 / caption: 부가 정보 / button: 버튼 레이블
class HelpFlowTextStyles {
  HelpFlowTextStyles._(); // 인스턴스 생성 방지

  /// 대형 제목 — 페이지 헤더 등 (28pt, Bold)
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 중형 제목 — 섹션 헤더 (22pt, Bold)
  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// 소형 제목 — 카드·다이얼로그 제목 (18pt, SemiBold)
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// 기본 본문 (16pt, Regular)
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 보조 본문 (14pt, Regular)
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 캡션·부가 정보 (12pt, Regular)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// 버튼 레이블 (16pt, SemiBold)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

// ── 버튼 스타일 ────────────────────────────────────────────────────────────

/// FilledButton / OutlinedButton / TextButton 공통 스타일
/// 둥근 모서리 radius 12, 수평 24px · 수직 16px 여백 적용
class HelpFlowButtonStyles {
  HelpFlowButtonStyles._(); // 인스턴스 생성 방지

  /// 강조 버튼 — 채워진 배경 (FilledButton)
  static ButtonStyle get filled => FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: HelpFlowTextStyles.button,
      );

  /// 보조 버튼 — 외곽선만 (OutlinedButton)
  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: HelpFlowColors.gray100),
        textStyle: HelpFlowTextStyles.button,
      );

  /// 저강조 버튼 — 배경 없음 (TextButton)
  static ButtonStyle get text => TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: HelpFlowTextStyles.button,
      );
}

// ── 여백 상수 ──────────────────────────────────────────────────────────────

/// 토스 스타일 여백 체계 — 4의 배수 기반
class HelpFlowSpacing {
  HelpFlowSpacing._(); // 인스턴스 생성 방지

  /// 4px — 아이콘 내부 간격 등 최소 여백
  static const double xs = 4;

  /// 8px — 짧은 간격
  static const double sm = 8;

  /// 12px — 기본 내부 여백
  static const double md = 12;

  /// 16px — 섹션 간 기본 여백
  static const double lg = 16;

  /// 20px — 넓은 여백
  static const double xl = 20;

  /// 24px — 큰 섹션 간격
  static const double xxl = 24;

  /// 32px — 페이지 최상단·하단 여백
  static const double xxxl = 32;
}

// [파일 요약]
// HelpFlow 통합 디자인 시스템 파일입니다.
// HelpFlowColors  : 색상 팔레트 (primary #0057FF, background #FFFFFF, surface #FFFFFF, gray 계열, error)
// HelpFlowTextStyles : 시스템 폰트 텍스트 스타일 (headline1~3, body1~2, caption, button)
// HelpFlowButtonStyles: FilledButton / OutlinedButton / TextButton 스타일 (radius 12, 넉넉한 패딩)
// HelpFlowSpacing : 4 / 8 / 12 / 16 / 20 / 24 / 32px 여백 상수 체계
