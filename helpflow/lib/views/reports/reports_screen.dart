import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// 리포트 화면 (추후 fl_chart 차트 대시보드로 구현 예정)
/// 현재는 플레이스홀더 화면으로 기본 구조만 제공합니다.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // 디자인 시스템 배경색 통일
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 영역
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: HelpFlowSpacing.lg),

            // 제목
            Text(
              '리포트',
              style: HelpFlowTextStyles.headline3.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: HelpFlowSpacing.sm),

            // 설명
            Text(
              '7~8주차 fl_chart 연동 후 구현 예정',
              style: HelpFlowTextStyles.body2.copyWith(
                color: HelpFlowColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [파일 요약]
// 리포트 화면의 플레이스홀더 구현입니다.
// 7~8주차에 fl_chart 연동 후 티켓 통계 차트(기간별 추이, 카테고리 분포 등)로 교체될 예정입니다.
// HelpFlowColors.background로 배경색을 통일합니다.
