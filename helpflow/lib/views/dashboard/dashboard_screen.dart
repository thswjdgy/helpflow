import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

/// 대시보드 화면
/// - 통계 카드 4개 (Wrap으로 반응형 배치)
/// - 차트 플레이스홀더 (7~8주차 fl_chart 연동 예정)
/// - 최근 티켓 임시 목록
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 통계 카드 영역 ────────────────────────────────────
          _StatCardsSection(),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 차트 플레이스홀더 ─────────────────────────────────
          _ChartPlaceholder(),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 최근 티켓 목록 ────────────────────────────────────
          _RecentTicketsSection(),
        ],
      ),
    );
  }
}

// ── 통계 카드 섹션 ───────────────────────────────────────────────
/// 4개의 통계 카드를 Wrap으로 반응형 배치
class _StatCardsSection extends StatelessWidget {
  // 임시 통계 데이터 (추후 Provider로 교체)
  static const List<_StatCardData> _stats = [
    _StatCardData(
      title: AppStrings.statsTotal,
      value: '128',
      unit: '건',
      icon: Icons.confirmation_number_outlined,
      color: AppColors.primary,
    ),
    _StatCardData(
      title: AppStrings.statsInProgress,
      value: '42',
      unit: '건',
      icon: Icons.pending_outlined,
      color: AppColors.warning,
    ),
    _StatCardData(
      title: AppStrings.statsDone,
      value: '76',
      unit: '건',
      icon: Icons.check_circle_outline,
      color: AppColors.success,
    ),
    _StatCardData(
      title: AppStrings.statsPending,
      value: '10',
      unit: '건',
      icon: Icons.warning_amber_outlined,
      color: AppColors.error,
    ),
  ];

  const _StatCardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '현황 요약',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        // Wrap으로 반응형 배치 — 카드가 공간에 맞게 자동 줄바꿈
        Wrap(
          spacing: AppSizes.spacingMd,
          runSpacing: AppSizes.spacingMd,
          children: _stats.map((data) => _StatCard(data: data)).toList(),
        ),
      ],
    );
  }
}

/// 통계 카드 데이터 모델
class _StatCardData {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

/// 개별 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: AppSizes.statCardMinWidth,
      height: AppSizes.statCardHeight,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingMd),
          child: Row(
            children: [
              // 아이콘 배경 원
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),

              const SizedBox(width: 12),

              // 수치 + 레이블
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          data.value,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data.unit,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 차트 플레이스홀더 ──────────────────────────────────────────
/// 7~8주차 fl_chart 연동 전까지 표시하는 플레이스홀더
class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '티켓 추이',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withAlpha(100),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.chartPlaceholder,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 최근 티켓 목록 ─────────────────────────────────────────────
/// 임시 최근 티켓 데이터로 구성된 목록
class _RecentTicketsSection extends StatelessWidget {
  // 임시 티켓 데이터 (추후 Hive에서 로드)
  static const List<_MockTicket> _mockTickets = [
    _MockTicket(id: 'HF-001', title: '로그인 오류 발생', status: '처리중', priority: '높음', time: '10분 전'),
    _MockTicket(id: 'HF-002', title: '비밀번호 재설정 요청', status: '새 티켓', priority: '중간', time: '1시간 전'),
    _MockTicket(id: 'HF-003', title: '이메일 발송 지연 문제', status: '완료', priority: '낮음', time: '어제'),
    _MockTicket(id: 'HF-004', title: '결제 오류 긴급 처리', status: '처리중', priority: '긴급', time: '2일 전'),
  ];

  const _RecentTicketsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentTickets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSm),
        Card(
          child: Column(
            children: _mockTickets
                .map((ticket) => _TicketListItem(ticket: ticket))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// 임시 티켓 데이터 모델
class _MockTicket {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String time;

  const _MockTicket({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.time,
  });
}

/// 최근 티켓 목록 아이템 위젯
class _TicketListItem extends StatelessWidget {
  final _MockTicket ticket;

  const _TicketListItem({required this.ticket});

  /// 상태에 따른 색상 반환
  Color _statusColor() {
    switch (ticket.status) {
      case '처리중':
        return AppColors.warning;
      case '완료':
        return AppColors.success;
      case '새 티켓':
        return AppColors.statusNew;
      default:
        return AppColors.info;
    }
  }

  /// 우선순위에 따른 색상 반환
  Color _priorityColor() {
    switch (ticket.priority) {
      case '긴급':
        return AppColors.error;
      case '높음':
        return AppColors.warning;
      case '낮음':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Text(
        ticket.id,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        ticket.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        ticket.time,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 우선순위 뱃지
          _Badge(label: ticket.priority, color: _priorityColor()),
          const SizedBox(width: 6),
          // 상태 뱃지
          _Badge(label: ticket.status, color: _statusColor()),
        ],
      ),
    );
  }
}

/// 상태/우선순위 뱃지 위젯
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// [파일 요약]
// 대시보드 화면 구현입니다.
// 4개의 통계 카드(총/처리중/완료/미처리)를 Wrap으로 반응형 배치하고,
// fl_chart 연동 전 차트 플레이스홀더와 임시 최근 티켓 목록을 표시합니다.
// 모든 데이터는 2주차 Hive 연동 후 실제 데이터로 교체될 예정입니다.
