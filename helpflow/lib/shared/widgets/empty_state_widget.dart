import 'package:flutter/material.dart';

/// 앱 공통 빈 상태(Empty State) 위젯
/// 데이터가 없거나 검색 결과가 없을 때 사용자에게 안내 메시지를 표시
class EmptyStateWidget extends StatelessWidget {
  /// 안내 아이콘
  final IconData icon;

  /// 주 메시지 (굵은 글씨)
  final String title;

  /// 부 메시지 (선택, 설명 텍스트)
  final String? subtitle;

  /// 액션 버튼 레이블 (선택)
  final String? actionLabel;

  /// 액션 버튼 콜백 (선택)
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '데이터가 없습니다',
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 영역 (배경 원)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            // 주 메시지
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // 부 메시지 (선택)
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼 (선택)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// [파일 요약]
// 데이터가 없는 상태를 사용자에게 안내하는 공통 Empty State 위젯입니다.
// 아이콘, 제목, 부제목, 액션 버튼을 조합하여 다양한 빈 상태를 표현할 수 있습니다.
