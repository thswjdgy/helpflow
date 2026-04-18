import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/assets/assets_provider.dart';
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

// [파일 요약]
// 자산 상세 화면입니다.
// AssetDetailScreen  : ConsumerWidget — assetsProvider 구독, assetId로 자산 조회
// _AssetInfoCard     : 타입 아이콘 + 이름 헤더 + 자산ID·유형·위치·시리얼 번호 상세 정보
// _AssetQrCard       : qr_flutter QrImageView — 자산 ID 인코딩 QR 코드 표시
// mobile_scanner 연동 시 QR 스캔 → /assets/:id 이동 흐름이 완성됩니다.
