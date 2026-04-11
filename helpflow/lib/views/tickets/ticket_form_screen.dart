import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/tickets/tickets_provider.dart';

// ── 티켓 접수 폼 화면 ────────────────────────────────────────
/// 새 티켓 접수 폼 화면
/// authProvider에서 현재 로그인 이메일을 읽어 접수자로 설정합니다.
/// Firestore 연동 전까지는 제출 시 SnackBar 피드백만 제공합니다.
class TicketFormScreen extends ConsumerStatefulWidget {
  const TicketFormScreen({super.key});

  @override
  ConsumerState<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends ConsumerState<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  /// 선택된 카테고리 값 (영문 key)
  String _category = 'hardware';

  /// 선택된 우선순위 값 (영문 key)
  String _priority = 'medium';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  /// 폼 제출 핸들러 — 유효성 통과 시 ticketsProvider에 티켓 추가 후 목록으로 이동
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ticketsProvider를 통해 실제로 티켓 추가 (알림도 자동 생성됨)
    ref.read(ticketsProvider.notifier).addTicket(
          title: _titleCtrl.text.trim(),
          description: _contentCtrl.text.trim(),
          category: _category,
          priority: _priority,
          reporterEmail: ref.read(authProvider).valueOrNull?.email ?? '',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('티켓이 접수되었습니다'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/tickets');
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인 사용자 이메일 (비로그인 시 빈 문자열)
    final userEmail =
        ref.watch(authProvider).valueOrNull?.email ?? '';

    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: _FormBody(
          formKey: _formKey,
          titleCtrl: _titleCtrl,
          contentCtrl: _contentCtrl,
          category: _category,
          priority: _priority,
          reporterEmail: userEmail,
          onCategoryChanged: (v) => setState(() => _category = v),
          onPriorityChanged: (v) => setState(() => _priority = v),
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}

// ── 폼 본문 위젯 ────────────────────────────────────────────
/// 4개 입력 필드(제목, 내용, 카테고리, 우선순위)와 제출 버튼을 포함하는 폼
class _FormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final String category;
  final String priority;
  final String reporterEmail;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onSubmit;

  // 카테고리 옵션 (영문 key → 한국어 레이블)
  static const Map<String, String> _categoryOptions = {
    'hardware': '하드웨어',
    'software': '소프트웨어',
    'network': '네트워크',
    'etc': '기타',
  };

  // 우선순위 옵션 (영문 key → 한국어 레이블)
  static const Map<String, String> _priorityOptions = {
    'critical': '긴급',
    'high': '높음',
    'medium': '중간',
    'low': '낮음',
  };

  const _FormBody({
    required this.formKey,
    required this.titleCtrl,
    required this.contentCtrl,
    required this.category,
    required this.priority,
    required this.reporterEmail,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 접수자 정보 표시 (읽기 전용)
          if (reporterEmail.isNotEmpty) ...[
            Text(
              '접수자: $reporterEmail',
              style: const TextStyle(
                fontSize: 13,
                color: HelpFlowColors.gray400,
              ),
            ),
            const SizedBox(height: HelpFlowSpacing.lg),
          ],

          // ── 제목 입력 ────────────────────────────────────
          Text('제목', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: titleCtrl,
            decoration: _inputDecoration('티켓 제목을 입력하세요'),
            validator: (v) => AppValidators.required(v, fieldName: '제목'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 내용 입력 ────────────────────────────────────
          Text('내용', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: contentCtrl,
            maxLines: 5,
            decoration: _inputDecoration('문제 상황을 자세히 설명해주세요'),
            validator: AppValidators.compose([
              (v) => AppValidators.required(v, fieldName: '내용'),
              AppValidators.minLength(10, fieldName: '내용'),
            ]),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 카테고리 선택 ─────────────────────────────────
          Text('카테고리', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          _DropdownField<String>(
            value: category,
            items: _categoryOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onCategoryChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 우선순위 선택 ─────────────────────────────────
          Text('우선순위', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          _DropdownField<String>(
            value: priority,
            items: _priorityOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onPriorityChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xxxl),

          // ── 제출 버튼 ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: const Text('티켓 접수'),
            ),
          ),
        ],
      ),
    );
  }

  /// 공통 입력 필드 데코레이션
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: HelpFlowColors.gray400, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: HelpFlowColors.gray100),
      ),
    );
  }
}

// ── 드롭다운 필드 공통 위젯 ──────────────────────────────────
/// 카테고리·우선순위에 공통으로 사용하는 드롭다운 래퍼
class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: HelpFlowColors.gray100),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HelpFlowSpacing.md,
          vertical: HelpFlowSpacing.md,
        ),
      ),
    );
  }
}

// [파일 요약]
// 새 티켓 접수 폼 화면입니다.
// TicketFormScreen: ConsumerStatefulWidget — authProvider에서 이메일 읽기, 폼 키 관리
// _FormBody: 4개 입력 필드(제목/내용/카테고리/우선순위) + AppValidators 검증 + 제출 버튼
// _DropdownField: 카테고리·우선순위 드롭다운 공통 래퍼
// 제출 성공 시 ticketsProvider.addTicket() 호출 → SnackBar 피드백 → /tickets 이동
// addTicket()은 내부적으로 notificationsProvider에 새 알림도 자동 추가합니다.
