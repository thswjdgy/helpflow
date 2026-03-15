import 'package:flutter/material.dart';

/// 앱 공통 버튼 위젯
/// FilledButton(기본), OutlinedButton(보조), TextButton(텍스트) 세 가지 변형 지원
class CustomButton extends StatelessWidget {
  /// 버튼 레이블 텍스트
  final String label;

  /// 클릭 콜백 (null이면 버튼 비활성화)
  final VoidCallback? onPressed;

  /// 버튼 왼쪽에 표시할 아이콘 (선택)
  final IconData? icon;

  /// 버튼 변형 타입
  final _ButtonVariant _variant;

  /// 로딩 상태 표시 여부
  final bool isLoading;

  /// 버튼 너비 확장 여부
  final bool fullWidth;

  /// FilledButton (기본, 강조 액션)
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : _variant = _ButtonVariant.filled;

  /// OutlinedButton (보조 액션)
  const CustomButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : _variant = _ButtonVariant.outlined;

  /// TextButton (저강조 액션)
  const CustomButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : _variant = _ButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    // 로딩 중이거나 onPressed가 null이면 비활성화
    final effectiveOnPressed = isLoading ? null : onPressed;

    // 버튼 내부 콘텐츠 (로딩 스피너 or 아이콘+텍스트)
    Widget child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 6),
                  Text(label),
                ],
              )
            : Text(label);

    // 버튼 변형에 따라 위젯 결정
    Widget button;
    switch (_variant) {
      case _ButtonVariant.filled:
        button = FilledButton(onPressed: effectiveOnPressed, child: child);
      case _ButtonVariant.outlined:
        button = OutlinedButton(onPressed: effectiveOnPressed, child: child);
      case _ButtonVariant.text:
        button = TextButton(onPressed: effectiveOnPressed, child: child);
    }

    // fullWidth이면 SizedBox로 가로 확장
    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// 버튼 변형 내부 열거형
enum _ButtonVariant { filled, outlined, text }

// [파일 요약]
// FilledButton / OutlinedButton / TextButton 세 가지 변형을 지원하는 공통 버튼 위젯입니다.
// isLoading으로 로딩 스피너 표시, fullWidth로 가로 확장, icon으로 아이콘 추가가 가능합니다.
