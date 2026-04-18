import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/assets/asset_mock_data.dart';

/// 목업 기반 자산 목록 전역 상태 관리 Notifier
/// - kMockAssets를 초기값으로 사용
/// - addAsset CRUD 지원
/// Firestore 연동 시 build()를 Stream으로 교체하고 메서드에서 Firestore 호출로 교체합니다.
class AssetsNotifier extends Notifier<List<MockAsset>> {
  /// 초기 상태: 목업 자산 목록 복사본
  @override
  List<MockAsset> build() => List.from(kMockAssets);

  // ── 내부 헬퍼 ────────────────────────────────────────────────

  /// 다음 자산 ID 자동 생성 (현재 최대 번호 + 1)
  /// 형식: AST-001, AST-002, …
  String _nextId() {
    final nums = state
        .map((a) => int.tryParse(a.id.replaceAll('AST-', '')) ?? 0)
        .toList();
    final maxNum = nums.isEmpty ? 0 : nums.reduce((a, b) => a > b ? a : b);
    return 'AST-${(maxNum + 1).toString().padLeft(3, '0')}';
  }

  // ── 공개 메서드 ──────────────────────────────────────────────

  /// 새 자산 등록 — ID 자동 생성, 목록 맨 앞에 추가
  void addAsset({
    required String name,
    required AssetType type,
    required String location,
    required String serialNumber,
  }) {
    final newAsset = MockAsset(
      id: _nextId(),
      name: name,
      type: type,
      location: location,
      serialNumber: serialNumber,
    );
    // 최신 자산을 맨 앞에 추가
    state = [newAsset, ...state];
  }
}

/// 앱 전역 자산 목록 Provider (목업 기반)
/// Firestore 연동 시 AsyncNotifierProvider 버전으로 교체합니다.
final assetsProvider =
    NotifierProvider<AssetsNotifier, List<MockAsset>>(AssetsNotifier.new);

// [파일 요약]
// 목업 기반 자산 목록 전역 상태 Provider입니다.
// AssetsNotifier: addAsset() 메서드 — ID 자동생성(AST-011, AST-012, …)
// assetsProvider: 앱 전역 자산 목록 NotifierProvider
// Firestore 연동 시 features/assets/firestore_assets_provider.dart로 교체합니다.
