import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../tickets/ticket_mock_data.dart';

/// 리포트 화면
/// kMockTickets를 집계하여 요약 카드·상태 분포·카테고리 분포·우선순위 분포를 표시합니다.
/// fl_chart 연동 시 LinearProgressIndicator → 차트로 교체합니다.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드 4개 (전체·처리중·완료·새 티켓)
            _SummaryCards(),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 상태별 분포
            _DistributionSection(
              title: '상태별 분포',
              items: _statusItems(),
            ),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 카테고리별 분포
            _DistributionSection(
              title: '카테고리별 분포',
              items: _categoryItems(),
            ),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 우선순위별 분포
            _DistributionSection(
              title: '우선순위별 분포',
              items: _priorityItems(),
            ),
          ],
        ),
      ),
    );
  }

  /// 상태별 건수 항목 생성
  static List<_DistItem> _statusItems() {
    final total = kMockTickets.length;
    final counts = {
      '새 티켓': kMockTickets.where((t) => t.status == 'new').length,
      '처리중': kMockTickets.where((t) => t.status == 'in_progress').length,
      '완료': kMockTickets.where((t) => t.status == 'resolved').length,
      '종료': kMockTickets.where((t) => t.status == 'closed').length,
    };
    final colors = {
      '새 티켓': AppColors.statusNew,
      '처리중': AppColors.statusInProgress,
      '완료': AppColors.statusDone,
      '종료': AppColors.statusOnHold,
    };
    return counts.entries.map((e) => _DistItem(
          label: e.key,
          count: e.value,
          ratio: total == 0 ? 0 : e.value / total,
          color: colors[e.key] ?? AppColors.info,
        )).toList();
  }

  /// 카테고리별 건수 항목 생성
  static List<_DistItem> _categoryItems() {
    final total = kMockTickets.length;
    final counts = {
      '하드웨어': kMockTickets.where((t) => t.category == 'hardware').length,
      '소프트웨어': kMockTickets.where((t) => t.category == 'software').length,
      '네트워크': kMockTickets.where((t) => t.category == 'network').length,
      '기타': kMockTickets.where((t) => t.category == 'etc').length,
    };
    return counts.entries.map((e) => _DistItem(
          label: e.key,
          count: e.value,
          ratio: total == 0 ? 0 : e.value / total,
          color: AppColors.info,
        )).toList();
  }

  /// 우선순위별 건수 항목 생성
  static List<_DistItem> _priorityItems() {
    final total = kMockTickets.length;
    final data = [
      ('긴급', 'critical', AppColors.error),
      ('높음', 'high', AppColors.warning),
      ('중간', 'medium', AppColors.info),
      ('낮음', 'low', AppColors.success),
    ];
    return data.map((e) {
      final count = kMockTickets.where((t) => t.priority == e.$2).length;
      return _DistItem(
        label: e.$1,
        count: count,
        ratio: total == 0 ? 0 : count / total,
        color: e.$3,
      );
    }).toList();
  }
}

// ── 요약 카드 섹션 ─────────────────────────────────────────────
/// 전체·처리중·완료·새 티켓 건수를 카드로 표시하는 섹션
class _SummaryCards extends StatelessWidget {
  // kMockTickets 집계 상수
  static int get _total => kMockTickets.length;
  static int get _inProgress =>
      kMockTickets.where((t) => t.status == 'in_progress').length;
  static int get _resolved =>
      kMockTickets.where((t) => t.status == 'resolved').length;
  static int get _newCount =>
      kMockTickets.where((t) => t.status == 'new').length;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData('총 티켓', _total, Icons.confirmation_number_outlined, AppColors.info),
      _CardData('처리중', _inProgress, Icons.pending_outlined, AppColors.warning),
      _CardData('완료', _resolved, Icons.check_circle_outlined, AppColors.success),
      _CardData('새 티켓', _newCount, Icons.fiber_new_outlined, AppColors.statusNew),
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
// ReportsScreen: kMockTickets를 집계하여 4개 섹션 표시
// _SummaryCards: 총 티켓·처리중·완료·새 티켓 요약 카드 (Wrap 반응형)
// _DistributionSection: 상태·카테고리·우선순위별 LinearProgressIndicator 분포 바
// fl_chart 연동 시 _DistRow의 LinearProgressIndicator를 차트로 교체합니다.
