import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';

// ── 목업 자산 데이터 ──────────────────────────────────────────
/// 자산 타입 enum
enum AssetType { laptop, desktop, printer, network, monitor, peripheral }

/// 자산 타입 → 한국어 레이블
String assetTypeLabel(AssetType type) {
  const m = {
    AssetType.laptop: '노트북',
    AssetType.desktop: '데스크탑',
    AssetType.printer: '프린터',
    AssetType.network: '네트워크 장비',
    AssetType.monitor: '모니터',
    AssetType.peripheral: '주변기기',
  };
  return m[type] ?? '기타';
}

/// 목업 자산 데이터 모델
class MockAsset {
  final String id;
  final String name;
  final AssetType type;
  final String location;
  final String serialNumber;

  /// QR 코드 연결 URL (Firestore 연동 전 플레이스홀더)
  final String? qrCodeUrl;

  const MockAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.serialNumber,
    this.qrCodeUrl,
  });
}

/// 목업 자산 목록 (10건)
final List<MockAsset> kMockAssets = [
  const MockAsset(
    id: 'AST-001',
    name: 'MacBook Pro 16 (2024)',
    type: AssetType.laptop,
    location: '3층 개발팀 A',
    serialNumber: 'C02ZK3ABMD6T',
  ),
  const MockAsset(
    id: 'AST-002',
    name: 'Dell XPS 15 9520',
    type: AssetType.laptop,
    location: '2층 디자인팀',
    serialNumber: 'DXPS15-00234',
  ),
  const MockAsset(
    id: 'AST-003',
    name: 'HP LaserJet Pro MFP M428fdn',
    type: AssetType.printer,
    location: '2층 공용 프린터실',
    serialNumber: 'CNBK123456',
  ),
  const MockAsset(
    id: 'AST-004',
    name: 'Cisco Catalyst 2960-X',
    type: AssetType.network,
    location: '서버실 랙 A-3',
    serialNumber: 'FDO2136P0AB',
  ),
  const MockAsset(
    id: 'AST-005',
    name: 'LG 27UK850-W 4K 모니터',
    type: AssetType.monitor,
    location: '3층 개발팀 B',
    serialNumber: 'LG27UK-00512',
  ),
  const MockAsset(
    id: 'AST-006',
    name: 'iMac 24 M3 (2024)',
    type: AssetType.desktop,
    location: '1층 마케팅팀',
    serialNumber: 'C02ZR5ABMD6T',
  ),
  const MockAsset(
    id: 'AST-007',
    name: 'ThinkPad X1 Carbon Gen 12',
    type: AssetType.laptop,
    location: '4층 재무팀',
    serialNumber: 'PF3KXABCD1',
  ),
  const MockAsset(
    id: 'AST-008',
    name: 'Logitech MX Keys S 키보드',
    type: AssetType.peripheral,
    location: '3층 개발팀 A',
    serialNumber: 'LOGI-MXKS-0089',
  ),
  const MockAsset(
    id: 'AST-009',
    name: 'Ubiquiti UniFi AP AC Pro',
    type: AssetType.network,
    location: '3층 천장 AP존',
    serialNumber: 'UAP-AC-PRO-0023',
  ),
  const MockAsset(
    id: 'AST-010',
    name: 'Samsung SyncMaster 32"',
    type: AssetType.monitor,
    location: '회의실 1',
    serialNumber: 'SM32-B2345',
  ),
];

// ── 자산 관리 화면 ────────────────────────────────────────────
/// 자산 목록 화면 (ADMIN 전용)
/// kMockAssets를 타입별로 필터하여 카드 목록으로 표시합니다.
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  /// 선택된 타입 필터 (null = 전체)
  AssetType? _typeFilter;

  /// 현재 필터가 적용된 자산 목록
  List<MockAsset> get _filteredAssets => _typeFilter == null
      ? kMockAssets
      : kMockAssets.where((a) => a.type == _typeFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 타입 필터 칩 영역
          _TypeFilterRow(
            selected: _typeFilter,
            onChanged: (t) => setState(() => _typeFilter = t),
          ),
          const Divider(height: 1),

          // 자산 목록
          Expanded(
            child: _filteredAssets.isEmpty
                ? Center(
                    child: Text(
                      '해당 조건의 자산이 없습니다',
                      style: HelpFlowTextStyles.body2
                          .copyWith(color: HelpFlowColors.gray400),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(HelpFlowSpacing.md),
                    itemCount: _filteredAssets.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: HelpFlowSpacing.sm),
                    itemBuilder: (context, i) =>
                        _AssetCard(asset: _filteredAssets[i]),
                  ),
          ),
        ],
      ),
      // ADMIN: 새 자산 등록 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddAsset,
        icon: const Icon(Icons.add),
        label: const Text('자산 등록'),
      ),
    );
  }

  /// 자산 등록 플레이스홀더 (Firestore 연동 전)
  void _onAddAsset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('자산 등록 기능은 Firestore 연동 후 구현 예정입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── 타입 필터 행 ─────────────────────────────────────────────
/// 자산 타입별 FilterChip을 가로 스크롤로 표시
class _TypeFilterRow extends StatelessWidget {
  final AssetType? selected;
  final ValueChanged<AssetType?> onChanged;

  static const List<AssetType> _types = AssetType.values;

  const _TypeFilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: HelpFlowSpacing.md, vertical: HelpFlowSpacing.sm),
      child: Row(
        children: [
          // 전체 필터 칩
          Padding(
            padding: const EdgeInsets.only(right: HelpFlowSpacing.sm),
            child: FilterChip(
              label: const Text('전체'),
              selected: selected == null,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onChanged(null),
            ),
          ),
          // 타입별 필터 칩
          ..._types.map((t) => Padding(
                padding: const EdgeInsets.only(right: HelpFlowSpacing.sm),
                child: FilterChip(
                  label: Text(assetTypeLabel(t)),
                  selected: selected == t,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) =>
                      onChanged(selected == t ? null : t),
                ),
              )),
        ],
      ),
    );
  }
}

// ── 자산 카드 ─────────────────────────────────────────────────
/// 개별 자산 정보를 카드 형태로 표시하는 위젯
class _AssetCard extends StatelessWidget {
  final MockAsset asset;

  const _AssetCard({required this.asset});

  /// 자산 타입 → 아이콘 반환
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.md),
        child: Row(
          children: [
            // 자산 타입 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icon(asset.type),
                  size: 22, color: AppColors.info),
            ),
            const SizedBox(width: HelpFlowSpacing.md),

            // 자산 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${assetTypeLabel(asset.type)} · ${asset.location}',
                    style: const TextStyle(
                        fontSize: 12, color: HelpFlowColors.gray400),
                  ),
                  Text(
                    'S/N: ${asset.serialNumber}',
                    style: const TextStyle(
                        fontSize: 11, color: HelpFlowColors.gray400),
                  ),
                ],
              ),
            ),

            // 자산 ID + QR 아이콘 (플레이스홀더)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.id,
                  style: const TextStyle(
                      fontSize: 11,
                      color: HelpFlowColors.gray400,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Tooltip(
                  message: 'QR 코드 (Firestore 연동 후 활성화)',
                  child: Icon(Icons.qr_code_outlined,
                      size: 20, color: HelpFlowColors.gray400),
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
// 자산 관리 화면입니다 (ADMIN 전용).
// AssetsScreen: kMockAssets를 타입별 FilterChip으로 필터하여 목록 표시
// _AssetCard: 이름·타입·위치·시리얼번호·QR 플레이스홀더를 카드 형태로 표시
// FloatingActionButton으로 자산 등록 진입 (Firestore 연동 후 구현)
// QR 코드 기능은 9~10주차 mobile_scanner 연동 시 완성합니다.
