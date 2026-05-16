import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../core/utils/validators.dart';
import '../../features/tickets/tickets_provider.dart';
import 'ticket_mock_data.dart';

// ── 티켓 수정 화면 ────────────────────────────────────────────
/// 기존 티켓의 제목·내용·카테고리·우선순위를 수정하는 폼 화면
/// ticketId로 ticketsProvider에서 티켓을 조회하여 필드를 pre-fill 합니다.
/// USER: 본인 티켓이 'new' 상태일 때만 수정 가능 (라우팅 레벨에서 별도 제어 가능)
/// AGENT·ADMIN: 모든 티켓 수정 가능
class TicketEditScreen extends ConsumerStatefulWidget {
  /// go_router /tickets/edit/:id 경로 파라미터
  final String ticketId;

  const TicketEditScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketEditScreen> createState() => _TicketEditScreenState();
}

class _TicketEditScreenState extends ConsumerState<TicketEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  /// 선택된 카테고리
  String _category = 'hardware';

  /// 선택된 우선순위
  String _priority = 'medium';

  /// SLA 마감 기한 (null이면 미설정)
  DateTime? _dueDate;

  /// 초기화 완료 여부 (최초 1회 pre-fill 후 true)
  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  /// 티켓 데이터로 폼 필드를 채웁니다 (최초 1회)
  void _initFields(MockTicket ticket) {
    if (_initialized) return;
    _titleCtrl.text = ticket.title;
    _contentCtrl.text = ticket.description;
    _category = ticket.category;
    _priority = ticket.priority;
    _dueDate = ticket.dueDate;
    _initialized = true;
  }

  /// 마감 기한 선택 핸들러 — 날짜 선택 후 시간 선택
  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now.add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : const TimeOfDay(hour: 18, minute: 0),
    );
    if (!mounted) return;

    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 18,
        pickedTime?.minute ?? 0,
      );
    });
  }

  /// 수정 제출 핸들러 — ticketsProvider.updateTicket() 호출 후 상세 화면으로 복귀
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 원본 기한이 있었는데 _dueDate가 null이면 명시적 제거
    final original = ref.read(ticketsProvider)
        .where((t) => t.id == widget.ticketId)
        .firstOrNull;
    final clearDueDate = original?.dueDate != null && _dueDate == null;

    ref.read(ticketsProvider.notifier).updateTicket(
          ticketId: widget.ticketId,
          title: _titleCtrl.text.trim(),
          description: _contentCtrl.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: clearDueDate,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('티켓이 수정되었습니다'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/tickets/${widget.ticketId}');
  }

  @override
  Widget build(BuildContext context) {
    // ticketsProvider 구독 — 티켓 조회
    final ticket = ref.watch(ticketsProvider)
        .where((t) => t.id == widget.ticketId)
        .firstOrNull;

    if (ticket == null) {
      return Scaffold(
        body: Center(
          child: Text(
            '티켓을 찾을 수 없습니다 (ID: ${widget.ticketId})',
            style: HelpFlowTextStyles.body1
                .copyWith(color: HelpFlowColors.gray400),
          ),
        ),
      );
    }

    // 최초 1회 폼 필드 초기화
    _initFields(ticket);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: _TicketEditBody(
          formKey: _formKey,
          titleCtrl: _titleCtrl,
          contentCtrl: _contentCtrl,
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          onCategoryChanged: (v) => setState(() => _category = v),
          onPriorityChanged: (v) => setState(() => _priority = v),
          onPickDueDate: _selectDueDate,
          onClearDueDate: () => setState(() => _dueDate = null),
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}

// ── 수정 폼 본문 ─────────────────────────────────────────────
/// 제목·내용·카테고리·우선순위 입력 필드와 수정 완료 버튼
class _TicketEditBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;
  final VoidCallback onSubmit;

  static const Map<String, String> _categoryOptions = {
    'hardware': '하드웨어',
    'software': '소프트웨어',
    'network': '네트워크',
    'etc': '기타',
  };

  static const Map<String, String> _priorityOptions = {
    'critical': '긴급',
    'high': '높음',
    'medium': '중간',
    'low': '낮음',
  };

  const _TicketEditBody({
    required this.formKey,
    required this.titleCtrl,
    required this.contentCtrl,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onPickDueDate,
    required this.onClearDueDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 제목 ───────────────────────────────────────────
          Text('제목', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: titleCtrl,
            decoration: _inputDecoration(context, '티켓 제목을 입력하세요'),
            validator: (v) => AppValidators.required(v, fieldName: '제목'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 내용 ───────────────────────────────────────────
          Text('내용', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: contentCtrl,
            maxLines: 5,
            decoration: _inputDecoration(context, '문제 상황을 자세히 설명해주세요'),
            validator: AppValidators.compose([
              (v) => AppValidators.required(v, fieldName: '내용'),
              AppValidators.minLength(10, fieldName: '내용'),
            ]),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 카테고리 ───────────────────────────────────────
          Text('카테고리', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: _dropdownDecoration(outline),
            items: _categoryOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onCategoryChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 우선순위 ───────────────────────────────────────
          Text('우선순위', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: priority,
            decoration: _dropdownDecoration(outline),
            items: _priorityOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onPriorityChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 마감 기한 (SLA) 선택 ──────────────────────────
          Text('마감 기한 / SLA (선택)', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDueDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    dueDate != null
                        ? '${dueDate!.year}.${dueDate!.month.toString().padLeft(2, '0')}.${dueDate!.day.toString().padLeft(2, '0')} '
                            '${dueDate!.hour.toString().padLeft(2, '0')}:${dueDate!.minute.toString().padLeft(2, '0')}'
                        : '기한 없음',
                    style: TextStyle(
                      color: dueDate != null
                          ? HelpFlowColors.gray700
                          : HelpFlowColors.gray400,
                    ),
                  ),
                ),
              ),
              if (dueDate != null) ...[
                const SizedBox(width: HelpFlowSpacing.sm),
                IconButton(
                  onPressed: onClearDueDate,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: '기한 제거',
                  color: HelpFlowColors.gray400,
                ),
              ],
            ],
          ),

          const SizedBox(height: HelpFlowSpacing.xxxl),

          // ── 수정 완료 버튼 ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: const Text('수정 완료'),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(BuildContext context, String hint) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: HelpFlowColors.gray400, fontSize: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline)),
    );
  }

  static InputDecoration _dropdownDecoration(Color outline) {
    return InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline)),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: HelpFlowSpacing.md, vertical: HelpFlowSpacing.md),
    );
  }
}

// [파일 요약]
// 티켓 수정 폼 화면입니다.
// TicketEditScreen   : ConsumerStatefulWidget — ticketId로 ticketsProvider에서 티켓 조회 후 pre-fill
//   _dueDate         : DateTime? — SLA 마감 기한 (initFields에서 기존 값 복원)
//   _selectDueDate() : showDatePicker → showTimePicker 순서로 마감 기한 변경
//   _initFields()    : _initialized 플래그로 build 재호출 시 컨트롤러 덮어쓰기 방지
//   _onSubmit()      : clearDueDate 플래그 계산 후 ticketsProvider.updateTicket() 호출
// _TicketEditBody    : 제목·내용·카테고리·우선순위·마감 기한 + AppValidators + '수정 완료' 버튼
