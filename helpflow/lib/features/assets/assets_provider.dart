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

  /// 기존 자산 수정 — ID로 찾아 필드만 교체 (불변 업데이트)
  void updateAsset({
    required String id,
    required String name,
    required AssetType type,
    required String location,
    required String serialNumber,
  }) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(
            name: name,
            type: type,
            location: location,
            serialNumber: serialNumber,
          )
        else
          a,
    ];
  }

  /// 자산 삭제 — ID와 일치하는 항목 제거
  void deleteAsset(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

/// 앱 전역 자산 목록 Provider (목업 기반)
/// Firestore 연동 시 AsyncNotifierProvider 버전으로 교체합니다.
final assetsProvider =
    NotifierProvider<AssetsNotifier, List<MockAsset>>(AssetsNotifier.new);

// [파일 요약]
// 목업 기반 자산 목록 전역 상태 Provider입니다.
// AssetsNotifier: addAsset() / updateAsset() / deleteAsset() CRUD 메서드
//   - ID 자동생성: AST-011, AST-012, …
//   - updateAsset(): 불변 업데이트 (copyWith 패턴)
//   - deleteAsset(): ID 일치 항목 필터 제거
// assetsProvider: 앱 전역 자산 목록 NotifierProvider
// Firestore 연동 시 features/assets/firestore_assets_provider.dart로 교체합니다.
