import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/assets/assets_provider.dart';
import '../../features/auth/auth_provider.dart';
import 'asset_mock_data.dart';

// ── 자산 상세 화면 ────────────────────────────────────────────
/// 자산 ID로 assetsProvider에서 자산을 찾아 상세 정보와 QR 코드를 표시합니다.
/// go_router /assets/:id 경로 파라미터로 assetId를 전달받습니다.
class AssetDetailScreen extends ConsumerWidget {
  /// go_router :id 경로 파라미터
  final String assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // assetsProvider 구독 — 자산 목록에서 해당 ID 검색
    final asset = ref.watch(assetsProvider)
        .where((a) => a.id == assetId)
        .firstOrNull;

    // 자산을 찾지 못한 경우
    if (asset == null) {
      return Scaffold(
        body: Center(
          child: Text(
            '자산을 찾을 수 없습니다 (ID: $assetId)',
            style: HelpFlowTextStyles.body1
                .copyWith(color: HelpFlowColors.gray400),
          ),
        ),
      );
    }

    // 현재 로그인 사용자 역할 확인 (ADMIN만 수정·삭제 가능)
    final userRole = ref.watch(authProvider).valueOrNull?.role ?? 'user';
    final isAdmin = userRole == 'admin';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 자산 기본 정보 카드
            _AssetInfoCard(asset: asset),

            const SizedBox(height: HelpFlowSpacing.xxl),

            // QR 코드 카드 (자산 ID 인코딩)
            _AssetQrCard(asset: asset),

            // ADMIN 전용: 수정·삭제 버튼 영역
            if (isAdmin) ...[
              const SizedBox(height: HelpFlowSpacing.xxl),
              _AdminActionsCard(asset: asset),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 자산 정보 카드 ────────────────────────────────────────────
/// 자산의 전체 상세 정보를 표시하는 카드
class _AssetInfoCard extends StatelessWidget {
  final MockAsset asset;

  const _AssetInfoCard({required this.asset});

  /// 자산 타입 → 아이콘
  static IconData _icon(AssetType type) {
    switch (type) {
      case AssetType.laptop:
        return Icons.laptop_outlined;
      case AssetType.desktop:
        return Icons.desktop_windows_outlined;
      case AssetType.printer:
        return Icons.print_outlined;
      case AssetType.network:
        return Icons.router_outlined;
      case AssetType.monitor:
        return Icons.monitor_outlined;
      case AssetType.peripheral:
        return Icons.keyboard_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 타입 아이콘 + 자산 이름
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon(asset.type),
                      size: 26, color: AppColors.info),
                ),
                const SizedBox(width: HelpFlowSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: HelpFlowTextStyles.headline3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        assetTypeLabel(asset.type),
                        style: const TextStyle(
                            fontSize: 13, color: HelpFlowColors.gray400),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: HelpFlowSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: HelpFlowSpacing.lg),

            // 상세 정보 행 목록
            _DetailRow(
              label: '자산 ID',
              value: asset.id,
              colorScheme: colorScheme,
            ),
            _DetailRow(
              label: '유형',
              value: assetTypeLabel(asset.type),
              colorScheme: colorScheme,
            ),
            _DetailRow(
              label: '위치',
              value: asset.location,
              colorScheme: colorScheme,
            ),
            _DetailRow(
              label: '시리얼 번호',
              value: asset.serialNumber,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

/// 라벨—값 한 줄 표시 위젯
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레이블 (고정 너비)
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: HelpFlowColors.gray400),
            ),
          ),
          // 값 (가변 너비)
          Expanded(
            child: Text(
              value,
              style:
                  TextStyle(fontSize: 13, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR 코드 카드 ──────────────────────────────────────────────
/// 자산 ID를 인코딩한 QR 코드를 qr_flutter로 생성하여 표시하는 카드
/// mobile_scanner 연동 시 이 QR 코드를 스캔하여 자산을 즉시 조회할 수 있습니다.
class _AssetQrCard extends StatelessWidget {
  final MockAsset asset;

  const _AssetQrCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    // QR 데이터: 자산 ID (예: "AST-001")
    // Firestore 연동 후에는 자산 상세 URL로 교체 예정
    final qrData = asset.qrCodeUrl ?? asset.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR 코드', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.sm),
            Text(
              'mobile_scanner로 스캔하면 자산 정보를 즉시 조회할 수 있습니다.',
              style: const TextStyle(
                  fontSize: 12, color: HelpFlowColors.gray400),
            ),
            const SizedBox(height: HelpFlowSpacing.lg),

            // QR 코드 이미지 (중앙 정렬)
            Center(
              child: Container(
                padding: const EdgeInsets.all(HelpFlowSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  // 다크모드에서도 QR 코드 배경을 항상 흰색으로 고정
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: HelpFlowSpacing.md),

            // QR 데이터 레이블
            Center(
              child: Text(
                qrData,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HelpFlowColors.gray400,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ADMIN 수정·삭제 버튼 영역 ─────────────────────────────────
/// ADMIN 전용 — 자산 수정 이동 버튼 + 삭제 확인 다이얼로그
class _AdminActionsCard extends ConsumerWidget {
  final MockAsset asset;

  const _AdminActionsCard({required this.asset});

  /// 삭제 확인 다이얼로그 표시 후 확인 시 assetsProvider.deleteAsset() 호출
  void _onDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('자산 삭제'),
        content: Text('"${asset.name}"을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(assetsProvider.notifier).deleteAsset(asset.id);
              context.go('/assets');
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('자산 관리', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            Row(
              children: [
                // 수정 버튼 → /assets/edit/:id 이동
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/assets/edit/${asset.id}'),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('수정'),
                  ),
                ),
                const SizedBox(width: HelpFlowSpacing.md),
                // 삭제 버튼 → 확인 다이얼로그
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onDelete(context, ref),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('삭제'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
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

// [파일 요약]
// 자산 상세 화면입니다.
// AssetDetailScreen  : ConsumerWidget — assetsProvider + authProvider 구독
// _AssetInfoCard     : 타입 아이콘 + 이름 헤더 + 자산ID·유형·위치·시리얼 번호 상세 정보
// _AssetQrCard       : qr_flutter QrImageView — 자산 ID 인코딩 QR 코드 표시
// _AdminActionsCard  : ADMIN 전용 — 수정(/assets/edit/:id) + 삭제 확인 다이얼로그
