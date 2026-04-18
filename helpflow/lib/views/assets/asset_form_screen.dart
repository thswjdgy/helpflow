import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../core/utils/validators.dart';
import '../../features/assets/assets_provider.dart';
import 'asset_mock_data.dart';

// ── 자산 등록 폼 화면 ─────────────────────────────────────────
/// 새 자산 등록 폼 화면 (ADMIN 전용)
/// 이름·유형·위치·시리얼 번호를 입력받아 assetsProvider에 추가합니다.
class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();

  /// 선택된 자산 유형 (기본값: laptop)
  AssetType _assetType = AssetType.laptop;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  /// 폼 제출 핸들러 — 유효성 통과 시 assetsProvider에 자산 추가 후 목록으로 이동
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(assetsProvider.notifier).addAsset(
          name: _nameCtrl.text.trim(),
          type: _assetType,
          location: _locationCtrl.text.trim(),
          serialNumber: _serialCtrl.text.trim(),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('자산이 등록되었습니다'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/assets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: _AssetFormBody(
          formKey: _formKey,
          nameCtrl: _nameCtrl,
          locationCtrl: _locationCtrl,
          serialCtrl: _serialCtrl,
          assetType: _assetType,
          onTypeChanged: (t) => setState(() => _assetType = t),
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}

// ── 폼 본문 위젯 ─────────────────────────────────────────────
/// 4개 입력 필드(이름, 유형, 위치, 시리얼 번호)와 등록 버튼을 포함하는 폼
class _AssetFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController serialCtrl;
  final AssetType assetType;
  final ValueChanged<AssetType> onTypeChanged;
  final VoidCallback onSubmit;

  /// 자산 유형 옵션 (enum → 한국어 레이블)
  static final Map<AssetType, String> _typeOptions = {
    for (final t in AssetType.values) t: assetTypeLabel(t),
  };

  const _AssetFormBody({
    required this.formKey,
    required this.nameCtrl,
    required this.locationCtrl,
    required this.serialCtrl,
    required this.assetType,
    required this.onTypeChanged,
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
          // ── 자산 이름 입력 ─────────────────────────────────
          Text('자산 이름', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: nameCtrl,
            decoration: _inputDecoration(context, '예: MacBook Pro 16 (2024)'),
            validator: (v) => AppValidators.required(v, fieldName: '자산 이름'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 자산 유형 선택 ─────────────────────────────────
          Text('유형', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          DropdownButtonFormField<AssetType>(
            initialValue: assetType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: outline),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: HelpFlowSpacing.md,
                vertical: HelpFlowSpacing.md,
              ),
            ),
            items: _typeOptions.entries
                .map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onTypeChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 위치 입력 ──────────────────────────────────────
          Text('위치', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: locationCtrl,
            decoration: _inputDecoration(context, '예: 3층 개발팀 A'),
            validator: (v) => AppValidators.required(v, fieldName: '위치'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 시리얼 번호 입력 ───────────────────────────────
          Text('시리얼 번호', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: serialCtrl,
            decoration: _inputDecoration(context, '예: C02ZK3ABMD6T'),
            validator: (v) => AppValidators.required(v, fieldName: '시리얼 번호'),
          ),

          const SizedBox(height: HelpFlowSpacing.xxxl),

          // ── 등록 버튼 ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: const Text('자산 등록'),
            ),
          ),
        ],
      ),
    );
  }

  /// 공통 입력 필드 데코레이션
  static InputDecoration _inputDecoration(BuildContext context, String hint) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: HelpFlowColors.gray400, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outline),
      ),
    );
  }
}

// [파일 요약]
// 자산 등록 폼 화면입니다 (ADMIN 전용).
// AssetFormScreen  : ConsumerStatefulWidget — 폼 키·컨트롤러 관리
// _AssetFormBody   : 4개 입력 필드(이름/유형/위치/시리얼 번호) + AppValidators 검증 + 등록 버튼
// 제출 성공 시 assetsProvider.addAsset() 호출 → SnackBar → /assets 이동
