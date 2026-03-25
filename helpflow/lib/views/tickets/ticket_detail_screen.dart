import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import 'ticket_mock_data.dart';

// ── 파일 레벨 헬퍼 함수 ──────────────────────────────────────
// 여러 위젯에서 공통으로 사용하는 상태 변환 함수들

/// 상태 값(영문) → 한국어 레이블 변환
String _statusLabel(String status) {
  const map = {
    'new': '새 티켓',
    'in_progress': '처리중',
    'resolved': '완료',
    'closed': '종료',
  };
  return map[status] ?? status;
}

/// 상태 값 → 대표 색상 반환
Color _statusColor(String status) {
  switch (status) {
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

/// 카테고리 값(영문) → 한국어 레이블 변환
String _categoryLabel(String category) {
  const map = {
    'hardware': '하드웨어',
    'software': '소프트웨어',
    'network': '네트워크',
    'etc': '기타',
  };
  return map[category] ?? category;
}

// ── 티켓 상세 화면 ────────────────────────────────────────────
/// 티켓 상세 화면
/// ticketId로 kMockTickets에서 해당 티켓을 찾아 표시합니다.
/// 상태 변경(new→in_progress→resolved)과 처리 메모 입력을 로컬 상태로 관리합니다.
class TicketDetailScreen extends StatefulWidget {
  /// go_router :id 경로 파라미터로 전달받은 티켓 ID
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

/// 티켓 상세 화면 상태 클래스
class _TicketDetailScreenState extends State<TicketDetailScreen> {
  MockTicket? _ticket; // 조회된 목업 티켓 (없으면 null)
  String _currentStatus = ''; // 화면 내 로컬 상태 (변경 즉시 반영)
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ticketId로 목업 목록에서 티켓 검색
    _ticket = kMockTickets
        .where((t) => t.id == widget.ticketId)
        .firstOrNull;
    _currentStatus = _ticket?.status ?? '';
  }

  @override
  void dispose() {
    _noteCtrl.dispose(); // 텍스트 컨트롤러 메모리 해제
    super.dispose();
  }

  /// 현재 상태에서 다음 상태 반환 (resolved/closed 이후는 null)
  String? _nextStatus() {
    switch (_currentStatus) {
      case 'new':
        return 'in_progress';
      case 'in_progress':
        return 'resolved';
      default:
        return null; // 더 이상 전진 없음
    }
  }

  /// 상태 변경 버튼 핸들러 — 로컬 상태만 변경 (Firestore 연동 전)
  void _onStatusChange() {
    final next = _nextStatus();
    if (next == null) return;
    setState(() => _currentStatus = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('상태가 "${_statusLabel(next)}"(으)로 변경되었습니다'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 처리 메모 저장 핸들러 — SnackBar로 피드백 (Firestore 연동 전)
  void _onNoteSubmit() {
    if (_noteCtrl.text.trim().isEmpty) return;
    _noteCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('처리 내용이 저장되었습니다'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 티켓을 찾지 못한 경우
    if (_ticket == null) {
      return Scaffold(
        backgroundColor: HelpFlowColors.background,
        body: Center(
          child: Text(
            '티켓을 찾을 수 없습니다 (ID: ${widget.ticketId})',
            style: HelpFlowTextStyles.body1
                .copyWith(color: HelpFlowColors.gray400),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 티켓 기본 정보 카드
            _TicketInfoSection(ticket: _ticket!),

            const SizedBox(height: HelpFlowSpacing.xxl),

            // 상태 변경 섹션
            _StatusSection(
              currentStatus: _currentStatus,
              nextStatus: _nextStatus(),
              onStatusChange: _onStatusChange,
            ),

            const SizedBox(height: HelpFlowSpacing.xxl),

            // 처리 메모 입력 섹션
            _NoteSection(
              controller: _noteCtrl,
              onSubmit: _onNoteSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 티켓 정보 섹션 ────────────────────────────────────────────
/// 티켓의 제목·설명·메타 정보(카테고리, 접수자, 접수일)를 표시하는 카드
class _TicketInfoSection extends StatelessWidget {
  final MockTicket ticket;

  const _TicketInfoSection({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(ticket.title, style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.sm),

            // 설명
            Text(
              ticket.description,
              style: HelpFlowTextStyles.body2
                  .copyWith(color: HelpFlowColors.gray700),
            ),
            const SizedBox(height: HelpFlowSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: HelpFlowSpacing.lg),

            // 메타 정보 행 목록
            _InfoRow(
              label: '카테고리',
              value: _categoryLabel(ticket.category),
              colorScheme: colorScheme,
            ),
            _InfoRow(
              label: '접수자',
              value: ticket.reporterEmail,
              colorScheme: colorScheme,
            ),
            _InfoRow(
              label: '접수일',
              value:
                  '${ticket.createdAt.year}.${ticket.createdAt.month.toString().padLeft(2, '0')}.${ticket.createdAt.day.toString().padLeft(2, '0')}',
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

/// 라벨—값 한 줄 표시 위젯 (메타 정보 행에서 공통 사용)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 레이블 (고정 너비)
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: HelpFlowColors.gray400,
              ),
            ),
          ),
          // 값 (가변 너비)
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상태 변경 섹션 ────────────────────────────────────────────
/// 현재 상태 배지 + 다음 상태로 변경하는 버튼을 포함하는 카드
class _StatusSection extends StatelessWidget {
  final String currentStatus;
  final String? nextStatus; // null이면 최종 상태 (버튼 미표시)
  final VoidCallback onStatusChange;

  const _StatusSection({
    required this.currentStatus,
    required this.nextStatus,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('처리 상태', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),

            // 현재 상태 배지
            _CurrentStatusBadge(status: currentStatus),
            const SizedBox(height: HelpFlowSpacing.lg),

            // 상태 변경 버튼 또는 완료 표시
            if (nextStatus != null)
              FilledButton.icon(
                onPressed: onStatusChange,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text('"${_statusLabel(nextStatus!)}"(으)로 변경'),
              )
            else
              // 최종 상태(resolved/closed): 완료 표시
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: HelpFlowSpacing.md,
                    vertical: HelpFlowSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '처리 완료',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 현재 처리 상태를 색상 배지로 표시하는 위젯
class _CurrentStatusBadge extends StatelessWidget {
  final String status;

  const _CurrentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: HelpFlowSpacing.md, vertical: HelpFlowSpacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── 처리 메모 입력 섹션 ───────────────────────────────────────
/// 처리 내용을 자유 텍스트로 입력하고 저장하는 카드
class _NoteSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _NoteSection({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('처리 내용 입력', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),

            // 다중 행 텍스트 입력 필드
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '처리한 내용 또는 추가 메모를 입력하세요...',
                hintStyle:
                    const TextStyle(color: HelpFlowColors.gray400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: HelpFlowColors.gray100),
                ),
              ),
            ),
            const SizedBox(height: HelpFlowSpacing.md),

            // 저장 버튼 (우측 정렬)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// [파일 요약]
// 티켓 상세 화면입니다.
// _TicketInfoSection  : 제목·설명·카테고리·접수자·접수일 표시 카드
// _StatusSection      : 현재 상태 배지 + 다음 상태 변경 버튼 (new→in_progress→resolved)
// _NoteSection        : 처리 내용 텍스트 입력 + 저장 버튼
// 상태 변경과 메모 저장은 로컬 State로 관리하며, SnackBar로 피드백을 제공합니다.
// Firestore 연동 시 _onStatusChange/_onNoteSubmit 에서 ticketProvider를 호출하도록 교체합니다.
