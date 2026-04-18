// HelpFlow 자산 목업 데이터
// Firestore 연동 전까지 자산 목록·상세 화면에서 공통으로 사용하는 임시 데이터입니다.

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

  /// QR 코드 연결 URL (없으면 자산 ID를 QR 데이터로 사용)
  final String? qrCodeUrl;

  const MockAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.serialNumber,
    this.qrCodeUrl,
  });

  /// 일부 필드만 바꾼 복사본 반환 (Provider 불변 업데이트에 사용)
  MockAsset copyWith({
    String? id,
    String? name,
    AssetType? type,
    String? location,
    String? serialNumber,
    String? qrCodeUrl,
  }) {
    return MockAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }
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

// [파일 요약]
// HelpFlow 자산 목업 데이터 파일입니다.
// AssetType: 자산 타입 enum (laptop/desktop/printer/network/monitor/peripheral)
// MockAsset: id·name·type·location·serialNumber·qrCodeUrl 필드 + copyWith() 메서드
// kMockAssets: 10건 목업 자산 목록
// Firestore 연동 시 이 파일을 제거하고 assetsProvider(features/assets/assets_provider.dart)로 교체합니다.
