import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/notes/notes_provider.dart';
import '../../features/tickets/tickets_provider.dart';
import '../users/user_mock_data.dart';
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
/// USER 역할: 상태 변경·메모 입력 비활성(읽기 전용)
/// AGENT·ADMIN: 상태 변경 + 처리 메모 모두 활성
class TicketDetailScreen extends ConsumerStatefulWidget {
  /// go_router :id 경로 파라미터로 전달받은 티켓 ID
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

/// 티켓 상세 화면 상태 클래스
class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  /// 처리 메모 입력 컨트롤러 (상태·티켓 데이터는 Provider에서 직접 읽음)
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  /// 현재 상태에서 다음 상태 반환 (closed 이후는 null — 최종 상태)
  String? _nextStatus(String current) {
    switch (current) {
      case 'new':
        return 'in_progress';
      case 'in_progress':
        return 'resolved';
      case 'resolved':
        return 'closed';
      default:
        return null;
    }
  }

  /// 상태 변경 버튼 핸들러 — ticketsProvider를 통해 실제 상태 업데이트
  void _onStatusChange(String ticketId, String nextStatus) {
    ref.read(ticketsProvider.notifier).updateStatus(ticketId, nextStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('상태가 "${_statusLabel(nextStatus)}"(으)로 변경되었습니다'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 처리 메모 저장 핸들러 — notesProvider에 실제 저장 후 SnackBar 피드백
  void _onNoteSubmit() {
    final content = _noteCtrl.text.trim();
    if (content.isEmpty) return;

    // 현재 로그인 이메일을 작성자로 설정
    final authorEmail =
        ref.read(authProvider).valueOrNull?.email ?? '';

    // notesProvider에 메모 저장
    ref.read(notesProvider.notifier).addNote(
          ticketId: widget.ticketId,
          content: content,
          authorEmail: authorEmail,
        );

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
    // ticketsProvider 구독 → 상태 변경·담당자 배정 시 자동 반영
    final ticket = ref.watch(ticketsProvider)
        .where((t) => t.id == widget.ticketId)
        .firstOrNull;

    // 티켓을 찾지 못한 경우
    if (ticket == null) {
      return Scaffold(
          body: Center(
          child: Text(
            '티켓을 찾을 수 없습니다 (ID: ${widget.ticketId})',
            style: HelpFlowTextStyles.body1.copyWith(color: HelpFlowColors.gray400),
          ),
        ),
      );
    }

    // USER 역할은 읽기 전용 (상태 변경·메모 입력 비활성)
    final authUser = ref.watch(authProvider).valueOrNull;
    final userRole = authUser?.role ?? 'user';
    final userEmail = authUser?.email ?? '';
    final isReadOnly = userRole == 'user';
    final isAdmin = userRole == 'admin';
    final next = isReadOnly ? null : _nextStatus(ticket.status);

    // 편집 가능 조건: AGENT·ADMIN은 항상 / USER는 본인 'new' 티켓만
    final canEdit = userRole != 'user' ||
        (ticket.reporterEmail == userEmail && ticket.status == 'new');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 티켓 기본 정보 카드
            _TicketInfoSection(ticket: ticket),

            // 편집 가능 시 수정 버튼 표시
            if (canEdit) ...[
              const SizedBox(height: HelpFlowSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/tickets/edit/${ticket.id}'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('티켓 수정'),
                ),
              ),
            ],

            // 첨부 이미지 갤러리 (이미지가 있을 때만 표시)
            if (ticket.imageUrls.isNotEmpty) ...[
              const SizedBox(height: HelpFlowSpacing.xxl),
              _ImageGallerySection(imageUrls: ticket.imageUrls),
            ],

            const SizedBox(height: HelpFlowSpacing.xxl),

            // ADMIN 전용: 담당자 배정 섹션
            if (isAdmin) ...[
              _AgentAssignSection(ticket: ticket),
              const SizedBox(height: HelpFlowSpacing.xxl),
            ],

            // 상태 변경 섹션 (USER는 읽기 전용)
            _StatusSection(
              currentStatus: ticket.status,
              nextStatus: next,
              onStatusChange: () => _onStatusChange(ticket.id, next!),
              isReadOnly: isReadOnly,
            ),

            const SizedBox(height: HelpFlowSpacing.xxl),

            // 처리 메모 입력 섹션 (USER는 숨김)
            if (!isReadOnly) ...[
              _NoteSection(
                controller: _noteCtrl,
                onSubmit: _onNoteSubmit,
              ),
              const SizedBox(height: HelpFlowSpacing.xxl),

              // 처리 이력 섹션 — 저장된 메모를 최신순으로 표시
              _NoteHistorySection(ticketId: ticket.id),
            ],
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
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
              label: '담당자',
              value: ticket.agentName ?? '미배정',
              colorScheme: colorScheme,
            ),
            _InfoRow(
              label: '접수일',
              value:
                  '${ticket.createdAt.year}.${ticket.createdAt.month.toString().padLeft(2, '0')}.${ticket.createdAt.day.toString().padLeft(2, '0')}',
              colorScheme: colorScheme,
            ),
            // 연관 자산이 있을 때만 표시 — 탭 시 자산 상세 화면으로 이동
            if (ticket.assetId != null)
              InkWell(
                onTap: () => context.go('/assets/${ticket.assetId}'),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          '연관 자산',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: HelpFlowColors.gray400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              ticket.assetName ?? ticket.assetId!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.open_in_new,
                                size: 13, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
/// isReadOnly=true(USER 역할)이면 상태 변경 버튼 대신 안내 문구를 표시합니다.
class _StatusSection extends StatelessWidget {
  final String currentStatus;
  final String? nextStatus; // null이면 최종 상태 (버튼 미표시)
  final VoidCallback onStatusChange;
  final bool isReadOnly;

  const _StatusSection({
    required this.currentStatus,
    required this.nextStatus,
    required this.onStatusChange,
    this.isReadOnly = false,
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

            // 읽기 전용(USER): 안내 문구 표시
            if (isReadOnly)
              Text(
                '상태 변경은 에이전트·관리자만 가능합니다.',
                style: const TextStyle(
                    fontSize: 13, color: HelpFlowColors.gray400),
              )
            // 상태 변경 버튼 또는 최종 완료 표시 (AGENT·ADMIN)
            else if (nextStatus != null)
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
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
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

// ── 담당자 배정 섹션 (ADMIN 전용) ────────────────────────────
/// ADMIN이 kMockAgents 목록에서 담당 에이전트를 선택하여 배정하는 카드
/// ticketsProvider.assignAgent()를 통해 실제 상태 업데이트
class _AgentAssignSection extends ConsumerStatefulWidget {
  final MockTicket ticket;

  const _AgentAssignSection({required this.ticket});

  @override
  ConsumerState<_AgentAssignSection> createState() => _AgentAssignSectionState();
}

class _AgentAssignSectionState extends ConsumerState<_AgentAssignSection> {
  /// 현재 선택된 에이전트 ID (초기값: 티켓에 이미 배정된 에이전트)
  String? _selectedAgentId;

  @override
  void initState() {
    super.initState();
    _selectedAgentId = widget.ticket.agentId;
  }

  /// 배정 버튼 핸들러 — ticketsProvider를 통해 실제 배정 처리
  void _onAssign() {
    if (_selectedAgentId == null) return;
    final agent = kMockAgents.firstWhere((a) => a.id == _selectedAgentId);
    ref.read(ticketsProvider.notifier).assignAgent(
          widget.ticket.id,
          agent.id,
          agent.name,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${agent.name}님에게 배정되었습니다'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('담당자 배정', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),

            // 에이전트 선택 드롭다운
            DropdownButtonFormField<String>(
              initialValue: _selectedAgentId,
              hint: const Text('담당 에이전트 선택'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: HelpFlowSpacing.md,
                  vertical: HelpFlowSpacing.md,
                ),
              ),
              items: kMockAgents
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.name} (${a.email})'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAgentId = v),
            ),
            const SizedBox(height: HelpFlowSpacing.md),

            // 배정 버튼
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _selectedAgentId == null ? null : _onAssign,
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('배정'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 처리 메모 이력 섹션 ───────────────────────────────────────
/// 저장된 처리 메모 목록을 최신순으로 표시하는 카드
/// notesForTicketProvider를 구독하여 새 메모 저장 즉시 자동 갱신됩니다.
class _NoteHistorySection extends ConsumerWidget {
  final String ticketId;

  const _NoteHistorySection({required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 특정 티켓의 메모 목록만 구독
    final notes = ref.watch(notesForTicketProvider(ticketId));

    // 메모가 없으면 섹션 자체를 숨김
    if (notes.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '처리 이력 (${notes.length}건)',
              style: HelpFlowTextStyles.headline3,
            ),
            const SizedBox(height: HelpFlowSpacing.sm),
            const Divider(height: 1),

            // 메모 목록
            ...notes.map((note) => _NoteItem(note: note)),
          ],
        ),
      ),
    );
  }
}

// ── 처리 메모 아이템 ─────────────────────────────────────────
/// 개별 처리 메모 아이템 (작성자·시각·내용)
class _NoteItem extends StatelessWidget {
  final MockNote note;

  const _NoteItem({required this.note});

  /// 날짜+시각을 "YYYY.MM.DD HH:mm" 형식으로 변환
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HelpFlowSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 + 작성 시각 행
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: HelpFlowColors.gray400),
              const SizedBox(width: 4),
              Text(
                note.authorEmail,
                style: const TextStyle(
                    fontSize: 12, color: HelpFlowColors.gray400),
              ),
              const Spacer(),
              Text(
                _formatDateTime(note.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: HelpFlowColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: HelpFlowSpacing.sm),

          // 메모 내용
          Text(note.content, style: const TextStyle(fontSize: 13)),
          const Divider(height: HelpFlowSpacing.xl),
        ],
      ),
    );
  }
}

// ── 이미지 갤러리 섹션 ────────────────────────────────────────
/// 티켓에 첨부된 이미지 목록을 가로 스크롤 갤러리로 표시하는 카드
/// kIsWeb 분기: 웹에서는 이미지 경로 대신 placeholder 아이콘 표시
class _ImageGallerySection extends StatelessWidget {
  final List<String> imageUrls;

  const _ImageGallerySection({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '첨부 이미지 (${imageUrls.length}장)',
              style: HelpFlowTextStyles.headline3,
            ),
            const SizedBox(height: HelpFlowSpacing.md),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: HelpFlowSpacing.sm),
                itemBuilder: (context, index) {
                  final path = imageUrls[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        // 웹 환경: 로컬 파일 경로 접근 불가 → placeholder 표시
                        ? Container(
                            width: 120,
                            height: 120,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image_outlined,
                                size: 40, color: HelpFlowColors.gray400),
                          )
                        // 모바일 환경: 로컬 파일 직접 표시
                        : Image.file(
                            File(path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: HelpFlowColors.gray100,
                              child: const Icon(Icons.broken_image_outlined,
                                  color: HelpFlowColors.gray400),
                            ),
                          ),
                  );
                },
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
// _TicketInfoSection   : 제목·설명·카테고리·접수자·담당자·접수일·연관 자산 표시 카드
//                        연관 자산 행은 탭 시 /assets/:id 상세 화면으로 이동 (go_router)
// _AgentAssignSection  : ADMIN 전용 ConsumerStatefulWidget — ticketsProvider.assignAgent() 실제 연동
// _StatusSection       : 현재 상태 배지 + 다음 상태 변경 버튼 (USER는 읽기 전용)
// _NoteSection         : AGENT·ADMIN 전용 처리 내용 입력 + 저장 버튼 (notesProvider에 실제 저장)
// _ImageGallerySection : 첨부 이미지 가로 스크롤 갤러리 (kIsWeb 분기로 크로스 플랫폼 대응)
// _NoteHistorySection  : 저장된 처리 메모 이력 목록 (notesForTicketProvider 구독, 자동 갱신)
// _NoteItem            : 개별 메모 아이템 (작성자·시각·내용)
// 상태 흐름: new → in_progress → resolved → closed (closed 이후 버튼 없음)
// 편집 버튼: AGENT·ADMIN 항상 / USER는 본인·'new' 티켓만 표시
// ticketsProvider 구독: 상태 변경·담당자 배정 시 화면이 자동으로 재빌드됩니다.
