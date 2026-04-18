import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/assets/assets_provider.dart';
import 'asset_mock_data.dart';

// ── 자산 관리 화면 ────────────────────────────────────────────
/// 자산 목록 화면 (ADMIN 전용)
/// assetsProvider를 구독하여 타입별 FilterChip + 검색으로 목록을 필터합니다.
class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  /// 선택된 타입 필터 (null = 전체)
  AssetType? _typeFilter;

  /// 검색어 (이름·위치·시리얼 번호 포함 여부로 필터)
  String _searchQuery = '';

  /// 필터 + 검색이 모두 적용된 자산 목록
  List<MockAsset> _filteredAssets(List<MockAsset> all) {
    final query = _searchQuery.trim().toLowerCase();
    return all.where((a) {
      final typeOk = _typeFilter == null || a.type == _typeFilter;
      final searchOk = query.isEmpty ||
          a.name.toLowerCase().contains(query) ||
          a.location.toLowerCase().contains(query) ||
          a.serialNumber.toLowerCase().contains(query);
      return typeOk && searchOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // assetsProvider 구독 — 자산 등록 시 자동 갱신
    final allAssets = ref.watch(assetsProvider);
    final filtered = _filteredAssets(allAssets);

    return Scaffold(
      body: Column(
        children: [
          // 검색창
          _AssetSearchBar(
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          // 타입 필터 칩 영역
          _TypeFilterRow(
            selected: _typeFilter,
            onChanged: (t) => setState(() => _typeFilter = t),
          ),
          const Divider(height: 1),

          // 자산 목록
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      '해당 조건의 자산이 없습니다',
                      style: HelpFlowTextStyles.body2
                          .copyWith(color: HelpFlowColors.gray400),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(HelpFlowSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: HelpFlowSpacing.sm),
                    itemBuilder: (context, i) => _AssetCard(
                      asset: filtered[i],
                      onTap: () => context.go('/assets/${filtered[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
      // ADMIN: 새 자산 등록 버튼 + QR 스캔 버튼
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // QR 스캔 버튼 (소형)
          FloatingActionButton.small(
            heroTag: 'scan',
            onPressed: () => context.go('/assets/scan'),
            tooltip: 'QR 코드 스캔',
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          // 자산 등록 버튼
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => context.go('/assets/new'),
            icon: const Icon(Icons.add),
            label: const Text('자산 등록'),
          ),
        ],
      ),
    );
  }
}

// ── 자산 검색창 ────────────────────────────────────────────────
/// 자산 이름·위치·시리얼 번호로 검색하는 입력창
class _AssetSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _AssetSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '자산 이름·위치·시리얼 번호 검색...',
          hintStyle:
              const TextStyle(fontSize: 13, color: HelpFlowColors.gray400),
          prefixIcon: const Icon(Icons.search,
              size: 20, color: HelpFlowColors.gray400),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
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
                  onSelected: (_) => onChanged(selected == t ? null : t),
                ),
              )),
        ],
      ),
    );
  }
}

// ── 자산 카드 ─────────────────────────────────────────────────
/// 개별 자산 정보를 카드 형태로 표시하는 위젯
/// 탭 시 /assets/:id 상세 화면으로 이동합니다.
class _AssetCard extends StatelessWidget {
  final MockAsset asset;
  final VoidCallback onTap;

  const _AssetCard({required this.asset, required this.onTap});

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                child:
                    Icon(_icon(asset.type), size: 22, color: AppColors.info),
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

              // 자산 ID + 이동 아이콘
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
                  const Icon(Icons.chevron_right,
                      size: 18, color: HelpFlowColors.gray400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [파일 요약]
// 자산 관리 목록 화면입니다 (ADMIN 전용).
// AssetsScreen: ConsumerStatefulWidget — assetsProvider 구독, 타입 필터 + 검색
// _AssetSearchBar: 이름·위치·시리얼 번호 TextField 검색창
// _TypeFilterRow: 자산 타입별 FilterChip 가로 스크롤 필터
// _AssetCard: 카드 탭 시 /assets/:id 상세 화면으로 이동 (InkWell 래핑)
// FloatingActionButton: /assets/new 자산 등록 폼으로 이동
