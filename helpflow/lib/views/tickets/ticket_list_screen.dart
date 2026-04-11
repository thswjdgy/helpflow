import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/tickets/tickets_provider.dart';
import 'ticket_mock_data.dart';

/// 티켓 목록 화면
/// 목업 데이터를 표시하며 상태·우선순위 필터 칩과 정렬·검색 기능을 제공합니다.
/// USER 역할: 본인 이메일 티켓만 표시 / AGENT·ADMIN: 전체 표시
/// Firestore 연동 시 kMockTickets → ticketProvider.when(...) 으로 교체합니다.
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

// ── 정렬 옵션 ─────────────────────────────────────────────────
/// 티켓 목록 정렬 방식
enum _SortOrder {
  newest, // 최신 접수순
  oldest, // 오래된 접수순
  highPriority, // 우선순위 높은순
}

// ── 메인 상태 클래스 ──────────────────────────────────────────
/// 필터 상태 관리 + 필터링·정렬·검색 로직 + 빌드
class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  /// 선택된 상태 필터 레이블 ('전체' = 필터 없음)
  String _statusFilter = '전체';

  /// 선택된 우선순위 필터 레이블 ('전체' = 필터 없음)
  String _priorityFilter = '전체';

  /// 현재 정렬 방식
  _SortOrder _sortOrder = _SortOrder.newest;

  /// 검색어 (제목 또는 접수자 이메일 포함 여부로 필터)
  String _searchQuery = '';

  // 상태 레이블 → 데이터 값 매핑
  static const Map<String, String> _statusMap = {
    '새 티켓': 'new',
    '처리중': 'in_progress',
    '완료': 'resolved',
    '종료': 'closed',
  };

  // 우선순위 레이블 → 데이터 값 매핑
  static const Map<String, String> _priorityMap = {
    '긴급': 'critical',
    '높음': 'high',
    '중간': 'medium',
    '낮음': 'low',
  };

  // 우선순위 정렬 기준 순서 (critical > high > medium > low)
  static const List<String> _priorityOrder = ['critical', 'high', 'medium', 'low'];

  /// allTickets·user를 받아 검색어·필터·정렬·역할 조건을 모두 적용한 목록 반환
  /// ref.watch()는 build()에서만 호출하고, 이 메서드에는 결과값을 인자로 전달합니다.
  List<MockTicket> _filterTickets(List<MockTicket> allTickets, String? role, String? email) {
    final query = _searchQuery.trim().toLowerCase();

    // 0단계: USER 역할이면 본인 이메일 티켓만, AGENT·ADMIN은 전체
    final base = (role == 'user' && email != null)
        ? allTickets.where((t) => t.reporterEmail == email).toList()
        : List<MockTicket>.from(allTickets);

    // 1단계: 검색어 + 상태 + 우선순위 AND 조건 적용
    var list = base.where((t) {
      final searchOk = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.reporterEmail.toLowerCase().contains(query);
      final statusOk =
          _statusFilter == '전체' || t.status == _statusMap[_statusFilter];
      final priorityOk =
          _priorityFilter == '전체' || t.priority == _priorityMap[_priorityFilter];
      return searchOk && statusOk && priorityOk;
    }).toList();

    // 2단계: 정렬 적용
    switch (_sortOrder) {
      case _SortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOrder.highPriority:
        list.sort((a, b) => _priorityOrder
            .indexOf(a.priority)
            .compareTo(_priorityOrder.indexOf(b.priority)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // ticketsProvider 전역 상태 구독 (새 티켓 추가 시 자동 반영)
    final allTickets = ref.watch(ticketsProvider);
    final authUser = ref.watch(authProvider).valueOrNull;
    final tickets = _filterTickets(allTickets, authUser?.role, authUser?.email);

    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Column(
        children: [
          // 검색창
          _SearchBar(
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          // 필터·정렬 영역
          _FilterSection(
            statusFilter: _statusFilter,
            priorityFilter: _priorityFilter,
            sortOrder: _sortOrder,
            onStatusChanged: (v) => setState(() => _statusFilter = v),
            onPriorityChanged: (v) => setState(() => _priorityFilter = v),
            onSortChanged: (v) => setState(() => _sortOrder = v),
          ),

          const Divider(height: 1),

          // 티켓 목록
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Text(
                      '조건에 맞는 티켓이 없습니다',
                      style: HelpFlowTextStyles.body2
                          .copyWith(color: HelpFlowColors.gray400),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: tickets.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) =>
                        _TicketCard(ticket: tickets[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 검색창 위젯 ──────────────────────────────────────────────
/// 제목 또는 접수자 이메일로 티켓을 검색하는 입력창
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '제목 또는 이메일 검색...',
          hintStyle: const TextStyle(
              fontSize: 13, color: HelpFlowColors.gray400),
          prefixIcon: const Icon(Icons.search, size: 20,
              color: HelpFlowColors.gray400),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: HelpFlowColors.gray100),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ── 필터·정렬 섹션 ────────────────────────────────────────────
/// 상태 필터 칩, 우선순위 필터 칩, 정렬 드롭다운을 포함하는 섹션
class _FilterSection extends StatelessWidget {
  final String statusFilter;
  final String priorityFilter;
  final _SortOrder sortOrder;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<_SortOrder> onSortChanged;

  static const List<String> _statusOptions = ['전체', '새 티켓', '처리중', '완료', '종료'];
  static const List<String> _priorityOptions = ['전체', '긴급', '높음', '중간', '낮음'];

  const _FilterSection({
    required this.statusFilter,
    required this.priorityFilter,
    required this.sortOrder,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 행: 정렬 드롭다운 + 상태 필터 칩
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              // 정렬 선택 드롭다운
              DropdownButtonHideUnderline(
                child: DropdownButton<_SortOrder>(
                  value: sortOrder,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: _SortOrder.newest, child: Text('최신순')),
                    DropdownMenuItem(
                        value: _SortOrder.oldest, child: Text('오래된순')),
                    DropdownMenuItem(
                        value: _SortOrder.highPriority, child: Text('우선순위순')),
                  ],
                  onChanged: (v) {
                    if (v != null) onSortChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 상태 필터 칩 목록
              ..._statusOptions.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(opt, style: const TextStyle(fontSize: 12)),
                    selected: statusFilter == opt,
                    onSelected: (_) => onStatusChanged(opt),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 하단 행: 우선순위 필터 칩
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Row(
            children: _priorityOptions
                .map(
                  (opt) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(opt, style: const TextStyle(fontSize: 12)),
                      selected: priorityFilter == opt,
                      onSelected: (_) => onPriorityChanged(opt),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── 티켓 카드 ────────────────────────────────────────────────
/// 개별 티켓 목록 아이템 위젯
/// 탭 시 /tickets/:id 경로로 이동합니다.
class _TicketCard extends StatelessWidget {
  final MockTicket ticket;

  const _TicketCard({required this.ticket});

  // 상태 → 한국어 레이블
  static String _statusLabel(String s) {
    const m = {'new': '새 티켓', 'in_progress': '처리중', 'resolved': '완료', 'closed': '종료'};
    return m[s] ?? s;
  }

  // 상태 → 색상
  static Color _statusColor(String s) {
    switch (s) {
      case 'new':
        return AppColors.statusNew;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusDone;
      default:
        return AppColors.statusOnHold;
    }
  }

  // 우선순위 → 한국어 레이블
  static String _priorityLabel(String p) {
    const m = {'critical': '긴급', 'high': '높음', 'medium': '중간', 'low': '낮음'};
    return m[p] ?? p;
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

  // 접수 시각을 상대 시간 문자열로 변환 (예: "30분 전", "2일 전")
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 티켓 상세 화면으로 이동
      onTap: () => context.go('/tickets/${ticket.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 티켓 ID (고정 너비)
            SizedBox(
              width: 68,
              child: Text(
                ticket.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HelpFlowColors.gray400,
                ),
              ),
            ),

            // 제목 + 메타 정보 (가변 너비)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ticket.reporterEmail} · ${_timeAgo(ticket.createdAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: HelpFlowColors.gray400),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 우선순위 배지
            _StatusBadge(
              label: _priorityLabel(ticket.priority),
              color: _priorityColor(ticket.priority),
            ),
            const SizedBox(width: 6),

            // 상태 배지
            _StatusBadge(
              label: _statusLabel(ticket.status),
              color: _statusColor(ticket.status),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상태/우선순위 배지 ─────────────────────────────────────────
/// 색상 배경 + 텍스트 레이블 배지 위젯 (목록·상세 공용)
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

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
// 티켓 목록 화면입니다.
// _FilterSection : 상태·우선순위 FilterChip + 정렬 DropdownButton (가로 스크롤)
// _TicketCard    : 개별 티켓 행 (ID / 제목·메타 / 우선순위·상태 배지) — 탭 시 상세 이동
// _StatusBadge   : 색상 배지 위젯 (목록 공용)
// ticketsProvider 구독: 새 티켓 접수·상태 변경 시 목록이 자동으로 갱신됩니다.
// USER 역할: 본인 이메일 티켓만 / AGENT·ADMIN: 전체 표시
