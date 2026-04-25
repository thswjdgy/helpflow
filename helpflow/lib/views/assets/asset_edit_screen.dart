import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../core/utils/validators.dart';
import '../../features/assets/assets_provider.dart';
import 'asset_mock_data.dart';

// ── 자산 수정 폼 화면 ─────────────────────────────────────────
/// 기존 자산 정보를 불러와 수정할 수 있는 폼 화면 (ADMIN 전용)
/// assetId로 assetsProvider에서 자산을 조회하여 필드를 pre-fill 합니다.
class AssetEditScreen extends ConsumerStatefulWidget {
  /// go_router /assets/edit/:id 경로 파라미터로 전달받은 자산 ID
  final String assetId;

  const AssetEditScreen({super.key, required this.assetId});

  @override
  ConsumerState<AssetEditScreen> createState() => _AssetEditScreenState();
}

class _AssetEditScreenState extends ConsumerState<AssetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();

  /// 선택된 자산 유형
  AssetType _assetType = AssetType.laptop;

  /// 초기화 완료 여부 (initState에서 pre-fill 후 true)
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  /// 현재 자산 데이터로 폼 필드를 채웁니다 (build 최초 1회 호출)
  void _initFields(MockAsset asset) {
    if (_initialized) return;
    _nameCtrl.text = asset.name;
    _locationCtrl.text = asset.location;
    _serialCtrl.text = asset.serialNumber;
    _assetType = asset.type;
    _initialized = true;
  }

  /// 수정 제출 핸들러 — 유효성 통과 시 assetsProvider.updateAsset() 호출
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(assetsProvider.notifier).updateAsset(
          id: widget.assetId,
          name: _nameCtrl.text.trim(),
          type: _assetType,
          location: _locationCtrl.text.trim(),
          serialNumber: _serialCtrl.text.trim(),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('자산 정보가 수정되었습니다'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    // 수정 완료 후 상세 화면으로 복귀
    context.go('/assets/${widget.assetId}');
  }

  @override
  Widget build(BuildContext context) {
    // assetsProvider 구독 — 자산 조회
    final asset = ref.watch(assetsProvider)
        .where((a) => a.id == widget.assetId)
        .firstOrNull;

    // 자산을 찾지 못한 경우
    if (asset == null) {
      return Scaffold(
        body: Center(
          child: Text(
            '자산을 찾을 수 없습니다 (ID: ${widget.assetId})',
            style: HelpFlowTextStyles.body1
                .copyWith(color: HelpFlowColors.gray400),
          ),
        ),
      );
    }

    // 최초 1회 폼 필드 초기화
    _initFields(asset);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: _AssetEditBody(
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

// ── 수정 폼 본문 ─────────────────────────────────────────────
/// 4개 입력 필드(이름, 유형, 위치, 시리얼 번호)와 수정 버튼
class _AssetEditBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController serialCtrl;
  final AssetType assetType;
  final ValueChanged<AssetType> onTypeChanged;
  final VoidCallback onSubmit;

  /// 자산 유형 옵션
  static final Map<AssetType, String> _typeOptions = {
    for (final t in AssetType.values) t: assetTypeLabel(t),
  };

  const _AssetEditBody({
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
          // ── 자산 이름 ──────────────────────────────────────
          Text('자산 이름', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: nameCtrl,
            decoration: _inputDecoration(context, '예: MacBook Pro 16 (2024)'),
            validator: (v) => AppValidators.required(v, fieldName: '자산 이름'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 자산 유형 ──────────────────────────────────────
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
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onTypeChanged(v);
            },
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 위치 ───────────────────────────────────────────
          Text('위치', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: locationCtrl,
            decoration: _inputDecoration(context, '예: 3층 개발팀 A'),
            validator: (v) => AppValidators.required(v, fieldName: '위치'),
          ),

          const SizedBox(height: HelpFlowSpacing.xl),

          // ── 시리얼 번호 ────────────────────────────────────
          Text('시리얼 번호', style: HelpFlowTextStyles.body1),
          const SizedBox(height: HelpFlowSpacing.sm),
          TextFormField(
            controller: serialCtrl,
            decoration: _inputDecoration(context, '예: C02ZK3ABMD6T'),
            validator: (v) => AppValidators.required(v, fieldName: '시리얼 번호'),
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
// 자산 수정 폼 화면입니다 (ADMIN 전용).
// AssetEditScreen   : ConsumerStatefulWidget — assetId로 assetsProvider에서 자산 조회 후 pre-fill
//   _initFields()   : 최초 1회 컨트롤러·유형 초기화 (_initialized 플래그로 중복 방지)
//   _onSubmit()     : assetsProvider.updateAsset() 호출 → SnackBar → /assets/:id 복귀
// _AssetEditBody    : 4개 입력 필드 + AppValidators 검증 + '수정 완료' 버튼
