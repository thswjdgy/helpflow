import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../tickets/ticket_mock_data.dart';

/// 대시보드 화면
/// - kMockTickets 집계 통계 카드 4개 (Wrap으로 반응형 배치)
/// - 차트 플레이스홀더 (7~8주차 fl_chart 연동 예정)
/// - kMockTickets 최근 4건 티켓 목록
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
          const _StatCardsSection(),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 차트 플레이스홀더 ─────────────────────────────────
          const _ChartPlaceholder(),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 최근 티켓 목록 ────────────────────────────────────
          const _RecentTicketsSection(),
        ],
      ),
    );
  }
}

// ── 통계 카드 섹션 ────────────────────────────────────────────
/// kMockTickets를 집계하여 4개의 통계 카드를 Wrap으로 반응형 배치
class _StatCardsSection extends StatelessWidget {
  const _StatCardsSection();

  // kMockTickets 실시간 집계값
  static int get _total => kMockTickets.length;
  static int get _inProgress =>
      kMockTickets.where((t) => t.status == 'in_progress').length;
  static int get _done =>
      kMockTickets.where((t) => t.status == 'resolved').length;
  static int get _pending =>
      kMockTickets.where((t) => t.status == 'new').length;

  @override
  Widget build(BuildContext context) {
    // 집계 완료 후 카드 데이터 구성
    final stats = [
      _StatCardData(
        title: AppStrings.statsTotal,
        value: '$_total',
        unit: '건',
        icon: Icons.confirmation_number_outlined,
        color: AppColors.primary,
      ),
      _StatCardData(
        title: AppStrings.statsInProgress,
        value: '$_inProgress',
        unit: '건',
        icon: Icons.pending_outlined,
        color: AppColors.warning,
      ),
      _StatCardData(
        title: AppStrings.statsDone,
        value: '$_done',
        unit: '건',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _StatCardData(
        title: AppStrings.statsPending,
        value: '$_pending',
        unit: '건',
        icon: Icons.warning_amber_outlined,
        color: AppColors.error,
      ),
    ];

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
          children: stats.map((data) => _StatCard(data: data)).toList(),
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

// ── 차트 플레이스홀더 ─────────────────────────────────────────
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

// ── 최근 티켓 목록 ────────────────────────────────────────────
/// kMockTickets를 최신순으로 정렬하여 상위 4건을 표시하는 섹션
class _RecentTicketsSection extends StatelessWidget {
  const _RecentTicketsSection();

  /// kMockTickets에서 최신 4건 추출
  static List<MockTicket> get _recentTickets {
    final sorted = List<MockTicket>.from(kMockTickets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _recentTickets;

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
            // 티켓 목록 화면으로 이동
            TextButton(
              onPressed: () => context.go('/tickets'),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSm),
        Card(
          child: Column(
            children: tickets
                .map((ticket) => _TicketListItem(ticket: ticket))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// 최근 티켓 목록 아이템 위젯 (MockTicket 사용)
class _TicketListItem extends StatelessWidget {
  final MockTicket ticket;

  const _TicketListItem({required this.ticket});

  // 상태 값(영문) → 한국어 레이블
  static String _statusLabel(String s) {
    const m = {'new': '새 티켓', 'in_progress': '처리중', 'resolved': '완료', 'closed': '종료'};
    return m[s] ?? s;
  }

  // 우선순위 값(영문) → 한국어 레이블
  static String _priorityLabel(String p) {
    const m = {'critical': '긴급', 'high': '높음', 'medium': '중간', 'low': '낮음'};
    return m[p] ?? p;
  }

  // 상태 → 색상
  static Color _statusColor(String s) {
    switch (s) {
      case 'new':
        return AppColors.statusNew;
      case 'in_progress':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.statusOnHold;
    }
  }

  // 우선순위 → 색상
  static Color _priorityColor(String p) {
    switch (p) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }

  // 접수 시각 → 상대 시간 문자열
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
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
        _timeAgo(ticket.createdAt),
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 우선순위 배지
          _Badge(
            label: _priorityLabel(ticket.priority),
            color: _priorityColor(ticket.priority),
          ),
          const SizedBox(width: 6),
          // 상태 배지
          _Badge(
            label: _statusLabel(ticket.status),
            color: _statusColor(ticket.status),
          ),
        ],
      ),
    );
  }
}

/// 상태/우선순위 배지 위젯
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
// 대시보드 화면입니다.
// _StatCardsSection: kMockTickets 집계값(총/처리중/완료/미처리)으로 통계 카드 표시
// _ChartPlaceholder: 7~8주차 fl_chart 연동 전 플레이스홀더
// _RecentTicketsSection: kMockTickets 최신 4건 표시, "전체 보기" → /tickets 이동
// Firestore 연동 시 kMockTickets → ticketProvider로 교체합니다.
