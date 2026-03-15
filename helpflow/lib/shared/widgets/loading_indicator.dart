import 'package:flutter/material.dart';

/// 앱 공통 로딩 인디케이터 위젯
/// 화면 중앙에 스피너와 선택적 메시지를 표시
class LoadingIndicator extends StatelessWidget {
  /// 스피너 아래에 표시할 메시지 (선택)
  final String? message;

  /// 스피너 색상 (기본: 테마 primaryColor)
  final Color? color;

  /// 스피너 크기 (기본: 40.0)
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 원형 프로그레스 인디케이터
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? theme.colorScheme.primary,
              strokeWidth: 3.0,
            ),
          ),

          // 메시지가 있을 때만 표시
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 인라인 소형 로딩 인디케이터 (버튼 내부 등에 사용)
class SmallLoadingIndicator extends StatelessWidget {
  /// 스피너 크기
  final double size;

  const SmallLoadingIndicator({super.key, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// [파일 요약]
// 데이터 로딩 시 화면 중앙에 스피너를 표시하는 공통 위젯입니다.
// LoadingIndicator(전체화면용)와 SmallLoadingIndicator(인라인용) 두 가지를 제공합니다.
