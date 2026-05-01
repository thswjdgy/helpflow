import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/tickets/tickets_provider.dart';
import '../tickets/ticket_mock_data.dart';

/// 리포트 화면
/// ticketsProvider를 구독하여 요약 카드·파이 차트·분포 섹션을 표시합니다.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ticketsProvider 구독 — 새 티켓 접수 시 통계 자동 갱신
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드 4개 (전체·처리중·완료·새 티켓)
            _SummaryCards(tickets: tickets),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 상태별 파이 차트 (fl_chart)
            _StatusPieChart(tickets: tickets),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 주간 접수 추이 바 차트 (fl_chart)
            _WeeklyBarChart(tickets: tickets),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 카테고리별 분포 바
            _DistributionSection(
              title: '카테고리별 분포',
              items: _categoryItems(tickets),
            ),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 우선순위별 분포 바
            _DistributionSection(
              title: '우선순위별 분포',
              items: _priorityItems(tickets),
            ),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 담당자별 처리 건수 (배정된 티켓만 집계)
            _AgentStatsSection(tickets: tickets),
          ],
        ),
      ),
    );
  }

  /// 카테고리별 건수 항목 생성
  static List<_DistItem> _categoryItems(List<MockTicket> tickets) {
    final total = tickets.length;
    final counts = {
      '하드웨어': tickets.where((t) => t.category == 'hardware').length,
      '소프트웨어': tickets.where((t) => t.category == 'software').length,
      '네트워크': tickets.where((t) => t.category == 'network').length,
      '기타': tickets.where((t) => t.category == 'etc').length,
    };
    return counts.entries.map((e) => _DistItem(
          label: e.key,
          count: e.value,
          ratio: total == 0 ? 0 : e.value / total,
          color: AppColors.info,
        )).toList();
  }

  /// 우선순위별 건수 항목 생성
  static List<_DistItem> _priorityItems(List<MockTicket> tickets) {
    final total = tickets.length;
    final data = [
      ('긴급', 'critical', AppColors.error),
      ('높음', 'high', AppColors.warning),
      ('중간', 'medium', AppColors.info),
      ('낮음', 'low', AppColors.success),
    ];
    return data.map((e) {
      final count = tickets.where((t) => t.priority == e.$2).length;
      return _DistItem(
        label: e.$1,
        count: count,
        ratio: total == 0 ? 0 : count / total,
        color: e.$3,
      );
    }).toList();
  }
}

// ── 상태별 파이 차트 ──────────────────────────────────────────
/// fl_chart PieChart로 상태별 티켓 수를 시각화
class _StatusPieChart extends StatelessWidget {
  final List<MockTicket> tickets;

  const _StatusPieChart({required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const SizedBox.shrink();

    final total = tickets.length;
    final data = [
      ('새 티켓', 'new', AppColors.statusNew),
      ('처리중', 'in_progress', AppColors.statusInProgress),
      ('완료', 'resolved', AppColors.statusDone),
      ('종료', 'closed', AppColors.statusOnHold),
    ];

    final sections = data
        .map((e) => (
              label: e.$1,
              count: tickets.where((t) => t.status == e.$2).length,
              color: e.$3,
            ))
        .where((e) => e.count > 0)
        .map((e) => PieChartSectionData(
              value: e.count.toDouble(),
              color: e.color,
              title: '${(e.count / total * 100).round()}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ))
        .toList();

    final legends = data
        .map((e) => (
              label: e.$1,
              count: tickets.where((t) => t.status == e.$2).length,
              color: e.$3,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('상태별 분포', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            Row(
              children: [
                // 파이 차트
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 32,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: HelpFlowSpacing.lg),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: legends
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: e.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${e.label}  ${e.count}건',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 요약 카드 섹션 ─────────────────────────────────────────────
/// 전체·처리중·완료·새 티켓 건수를 카드로 표시하는 섹션
class _SummaryCards extends StatelessWidget {
  final List<MockTicket> tickets;

  const _SummaryCards({required this.tickets});

  @override
  Widget build(BuildContext context) {
    // ticketsProvider 집계값
    final total = tickets.length;
    final inProgress = tickets.where((t) => t.status == 'in_progress').length;
    final resolved = tickets.where((t) => t.status == 'resolved').length;
    final newCount = tickets.where((t) => t.status == 'new').length;

    final cards = [
      _CardData('총 티켓', total, Icons.confirmation_number_outlined, AppColors.info),
      _CardData('처리중', inProgress, Icons.pending_outlined, AppColors.warning),
      _CardData('완료', resolved, Icons.check_circle_outlined, AppColors.success),
      _CardData('새 티켓', newCount, Icons.fiber_new_outlined, AppColors.statusNew),
    ];

    // Wrap: 화면 너비에 따라 2열 또는 4열로 자동 배치
    return Wrap(
      spacing: HelpFlowSpacing.md,
      runSpacing: HelpFlowSpacing.md,
      children: cards.map((d) => _SummaryCard(data: d)).toList(),
    );
  }
}

/// 요약 카드 데이터 모델
class _CardData {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _CardData(this.label, this.count, this.icon, this.color);
}

/// 개별 요약 카드 위젯
class _SummaryCard extends StatelessWidget {
  final _CardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(HelpFlowSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: data.color, size: 28),
              const SizedBox(height: HelpFlowSpacing.sm),
              Text(
                '${data.count}',
                style: HelpFlowTextStyles.headline2.copyWith(color: data.color),
              ),
              Text(
                data.label,
                style: const TextStyle(
                    fontSize: 13, color: HelpFlowColors.gray400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 분포 섹션 ────────────────────────────────────────────────
/// 레이블·건수·비율 바를 목록으로 표시하는 공통 섹션
class _DistributionSection extends StatelessWidget {
  final String title;
  final List<_DistItem> items;

  const _DistributionSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            ...items.map((item) => _DistRow(item: item)),
          ],
        ),
      ),
    );
  }
}

/// 분포 항목 데이터 모델
class _DistItem {
  final String label;
  final int count;
  final double ratio; // 0.0 ~ 1.0
  final Color color;

  const _DistItem({
    required this.label,
    required this.count,
    required this.ratio,
    required this.color,
  });
}

/// 레이블 + 건수 + LinearProgressIndicator 한 행
class _DistRow extends StatelessWidget {
  final _DistItem item;

  const _DistRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HelpFlowSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레이블 + 건수
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${item.count}건',
                  style: const TextStyle(
                      fontSize: 13, color: HelpFlowColors.gray400)),
            ],
          ),
          const SizedBox(height: 4),
          // 비율 바 (fl_chart 연동 시 교체)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.ratio,
              minHeight: 8,
              backgroundColor: item.color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
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

    // Y축 최댓값 — 0건이면 최소 4로 설정
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount == 0 ? 4 : maxCount).toDouble() + 1;

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            HelpFlowSpacing.lg, HelpFlowSpacing.lg,
            HelpFlowSpacing.lg, HelpFlowSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주간 접수 추이', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            SizedBox(
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
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
          ],
        ),
      ),
    );
  }
}

// ── 담당자별 처리 건수 섹션 ──────────────────────────────────
/// 담당자(에이전트)별 배정·처리·완료 티켓 건수를 카드로 표시
/// agentName이 있는 티켓만 집계합니다.
class _AgentStatsSection extends StatelessWidget {
  final List<MockTicket> tickets;

  const _AgentStatsSection({required this.tickets});

  @override
  Widget build(BuildContext context) {
    // 담당자가 배정된 티켓만 추출
    final assigned = tickets.where((t) => t.agentName != null).toList();

    // 담당자 이름 목록 중복 제거
    final agentNames = assigned.map((t) => t.agentName!).toSet().toList()
      ..sort();

    if (agentNames.isEmpty) {
      return const SizedBox.shrink();
    }

    // 담당자별 통계 계산
    final stats = agentNames.map((name) {
      final agentTickets = assigned.where((t) => t.agentName == name);
      return _AgentStat(
        name: name,
        total: agentTickets.length,
        resolved: agentTickets
            .where((t) => t.status == 'resolved' || t.status == 'closed')
            .length,
        inProgress: agentTickets.where((t) => t.status == 'in_progress').length,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('담당자별 처리 현황', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            const Divider(height: 1),
            ...stats.map((s) => _AgentStatRow(stat: s)),
          ],
        ),
      ),
    );
  }
}

/// 담당자 1명의 통계 데이터 모델
class _AgentStat {
  final String name;
  final int total;
  final int resolved;
  final int inProgress;

  const _AgentStat({
    required this.name,
    required this.total,
    required this.resolved,
    required this.inProgress,
  });
}

/// 담당자 1행 — 이름 + 배정·처리중·완료 건수 칩
class _AgentStatRow extends StatelessWidget {
  final _AgentStat stat;

  const _AgentStatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HelpFlowSpacing.md),
      child: Row(
        children: [
          // 담당자 아이콘 + 이름
          const Icon(Icons.person_outline,
              size: 18, color: HelpFlowColors.gray400),
          const SizedBox(width: HelpFlowSpacing.sm),
          Expanded(
            child: Text(
              stat.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          // 처리중 칩
          _StatChip(
            label: '처리중 ${stat.inProgress}',
            color: AppColors.statusInProgress,
          ),
          const SizedBox(width: HelpFlowSpacing.sm),
          // 완료 칩
          _StatChip(
            label: '완료 ${stat.resolved}',
            color: AppColors.statusDone,
          ),
          const SizedBox(width: HelpFlowSpacing.sm),
          // 전체 칩
          _StatChip(
            label: '전체 ${stat.total}',
            color: HelpFlowColors.gray400,
          ),
        ],
      ),
    );
  }
}

/// 통계 수치를 작은 색상 칩으로 표시
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// [파일 요약]
// 리포트 화면입니다.
// ReportsScreen       : ConsumerWidget — ticketsProvider 구독, 새 티켓 접수 시 자동 갱신
// _SummaryCards       : 총 티켓·처리중·완료·새 티켓 요약 카드 (Wrap 반응형)
// _StatusPieChart     : fl_chart PieChart — 상태별 분포 시각화
// _WeeklyBarChart     : fl_chart BarChart — 최근 7일 날짜별 접수 건수 (요일 레이블)
// _DistributionSection: 카테고리·우선순위별 LinearProgressIndicator 분포 바
// _AgentStatsSection  : 담당자별 배정·처리중·완료 건수 카드 (배정 티켓만 집계)
