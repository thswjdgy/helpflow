import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../features/tickets/tickets_provider.dart';
import '../tickets/ticket_mock_data.dart';

/// 대시보드 화면
/// - ticketsProvider 집계 통계 카드 4개 (Wrap으로 반응형 배치)
/// - fl_chart PieChart 상태별 분포 차트
/// - ticketsProvider 최근 4건 티켓 목록
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ticketsProvider 구독 — 하위 위젯에 전달
    final tickets = ref.watch(ticketsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 통계 카드 영역 ────────────────────────────────────
          _StatCardsSection(tickets: tickets),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 상태별 파이 차트 (fl_chart) ───────────────────────
          _StatusPieChart(tickets: tickets),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 주간 접수 추이 바 차트 (fl_chart) ─────────────────
          _WeeklyBarChart(tickets: tickets),

          const SizedBox(height: AppSizes.spacingLg),

          // ── 최근 티켓 목록 ────────────────────────────────────
          _RecentTicketsSection(tickets: tickets),
        ],
      ),
    );
  }
}

// ── 통계 카드 섹션 ────────────────────────────────────────────
/// ticketsProvider에서 받은 목록을 집계하여 4개의 통계 카드를 Wrap으로 반응형 배치
class _StatCardsSection extends StatelessWidget {
  final List<MockTicket> tickets;

  const _StatCardsSection({required this.tickets});

  @override
  Widget build(BuildContext context) {
    // ticketsProvider 집계값
    final total = tickets.length;
    final inProgress = tickets.where((t) => t.status == 'in_progress').length;
    final done = tickets.where((t) => t.status == 'resolved').length;
    final pending = tickets.where((t) => t.status == 'new').length;

    // 집계 완료 후 카드 데이터 구성
    final stats = [
      _StatCardData(
        title: AppStrings.statsTotal,
        value: '$total',
        unit: '건',
        icon: Icons.confirmation_number_outlined,
        color: AppColors.primary,
      ),
      _StatCardData(
        title: AppStrings.statsInProgress,
        value: '$inProgress',
        unit: '건',
        icon: Icons.pending_outlined,
        color: AppColors.warning,
      ),
      _StatCardData(
        title: AppStrings.statsDone,
        value: '$done',
        unit: '건',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _StatCardData(
        title: AppStrings.statsPending,
        value: '$pending',
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

// ── 상태별 파이 차트 ──────────────────────────────────────────
/// ticketsProvider 목록을 상태별로 집계하여 fl_chart PieChart로 표시하는 섹션
class _StatusPieChart extends StatelessWidget {
  final List<MockTicket> tickets;

  const _StatusPieChart({required this.tickets});

  /// 상태 값 → 한국어 레이블
  static String _label(String s) {
    const m = {'new': '새 티켓', 'in_progress': '처리중', 'resolved': '완료', 'closed': '종료'};
    return m[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const SizedBox.shrink();

    // 상태별 건수 집계
    final counts = <String, int>{
      'new': tickets.where((t) => t.status == 'new').length,
      'in_progress': tickets.where((t) => t.status == 'in_progress').length,
      'resolved': tickets.where((t) => t.status == 'resolved').length,
      'closed': tickets.where((t) => t.status == 'closed').length,
    };
    final colors = {
      'new': AppColors.statusNew,
      'in_progress': AppColors.statusInProgress,
      'resolved': AppColors.statusDone,
      'closed': AppColors.statusOnHold,
    };

    // 건수가 0인 항목은 파이 섹션에서 제외
    final sections = counts.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              color: colors[e.key],
              title: '${e.value}',
              radius: 56,
              titleStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상태별 티켓 분포',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingMd),
            child: Row(
              children: [
                // 파이 차트 (좌측)
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 36,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingLg),

                // 범례 (우측)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: counts.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[e.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_label(e.key)}  ${e.value}건',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 주간 접수 추이 바 차트 ────────────────────────────────────
/// 오늘 기준 최근 7일간 날짜별 티켓 접수 건수를 fl_chart BarChart로 표시
class _WeeklyBarChart extends StatelessWidget {
  final List<MockTicket> tickets;

  const _WeeklyBarChart({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 최근 7일 날짜별 접수 건수 집계 (인덱스 0 = 6일 전, 6 = 오늘)
    final counts = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return tickets.where((t) {
        final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
        return d == day;
      }).length;
    });

    // 요일 레이블 (월~일)
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayLabels = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return weekdays[day.weekday - 1];
    });

    // Y축 최댓값 — 0건이면 최소 5로 설정
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount == 0 ? 4 : maxCount).toDouble() + 1;

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 접수 추이',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.spacingMd, AppSizes.spacingMd,
                AppSizes.spacingMd, AppSizes.spacingSm),
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: List.generate(
                    7,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: counts[i].toDouble(),
                          color: primaryColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          // 막대 배경 (전체 높이)
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: primaryColor.withAlpha(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    // 상단·우측 레이블 숨김
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    // 하단 요일 레이블
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            dayLabels[value.toInt()],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    // 좌측 정수 건수 레이블
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          if (value != value.truncateToDouble()) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withAlpha(40),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 최근 티켓 목록 ────────────────────────────────────────────
/// ticketsProvider 목록을 최신순으로 정렬하여 상위 4건을 표시하는 섹션
class _RecentTicketsSection extends StatelessWidget {
  final List<MockTicket> tickets;

  const _RecentTicketsSection({required this.tickets});

  @override
  Widget build(BuildContext context) {
    // 최신순 정렬 후 4건 추출
    final recent = (List<MockTicket>.from(tickets)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
        .take(4)
        .toList();

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
            children: recent
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
// _StatCardsSection  : ticketsProvider 집계값(총/처리중/완료/미처리) 통계 카드 4개 (Wrap 반응형)
// _StatusPieChart    : fl_chart 도넛 PieChart — 상태별 분포 + 범례
// _WeeklyBarChart    : fl_chart BarChart — 최근 7일 날짜별 접수 건수 (요일 레이블)
// _RecentTicketsSection : ticketsProvider 최신 4건, "전체 보기" → /tickets 이동
// Firestore 연동 시 ticketsProvider를 StreamProvider로 교체합니다.
