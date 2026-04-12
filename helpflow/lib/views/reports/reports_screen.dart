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

// [파일 요약]
// 리포트 화면입니다.
// ReportsScreen      : ConsumerWidget — ticketsProvider 구독, 새 티켓 접수 시 자동 갱신
// _SummaryCards      : 총 티켓·처리중·완료·새 티켓 요약 카드 (Wrap 반응형)
// _StatusPieChart    : fl_chart PieChart — 상태별 분포 시각화
// _DistributionSection: 카테고리·우선순위별 LinearProgressIndicator 분포 바
