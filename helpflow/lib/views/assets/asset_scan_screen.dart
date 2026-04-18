import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../features/assets/assets_provider.dart';

// ── QR 코드 스캔 화면 ─────────────────────────────────────────
/// 카메라로 자산 QR 코드를 스캔하여 자산 상세 화면으로 이동합니다.
/// AssetDetailScreen의 QR 코드를 스캔하면 해당 자산 ID를 인식합니다.
class AssetScanScreen extends ConsumerStatefulWidget {
  const AssetScanScreen({super.key});

  @override
  ConsumerState<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends ConsumerState<AssetScanScreen> {
  /// MobileScanner 컨트롤러 — 카메라 생명주기 관리
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// 중복 처리 방지 플래그 — 인식 후 한 번만 이동
  bool _processed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 바코드 인식 핸들러 — 자산 ID 확인 후 상세 화면 이동
  void _onDetect(BarcodeCapture capture) {
    if (_processed) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    // assetsProvider에서 스캔된 값과 일치하는 자산 검색
    final asset = ref.read(assetsProvider)
        .where((a) => a.id == rawValue)
        .firstOrNull;

    _processed = true;
    _controller.stop();

    if (!mounted) return;

    if (asset != null) {
      // 자산 발견 → 상세 화면으로 이동
      context.go('/assets/$rawValue');
    } else {
      // 등록되지 않은 자산 → 안내 SnackBar 후 목록으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('등록되지 않은 자산입니다 ($rawValue)'),
          duration: const Duration(seconds: 3),
        ),
      );
      context.go('/assets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 카메라 뷰 ─────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── 스캔 가이드 오버레이 ──────────────────────────────
          _ScanOverlay(),

          // ── 상단 안내 텍스트 ──────────────────────────────────
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Text(
              '자산 QR 코드를 프레임 안에 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ],
              ),
            ),
          ),

          // ── 하단 취소 버튼 ────────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/assets'),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  '취소',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 스캔 가이드 오버레이 ──────────────────────────────────────
/// 반투명 배경 + 중앙 투명 프레임으로 스캔 영역을 시각적으로 표시
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const frameSize = 240.0;
    const frameRadius = 12.0;
    final screenSize = MediaQuery.of(context).size;
    final left = (screenSize.width - frameSize) / 2;
    final top = (screenSize.height - frameSize) / 2;

    return CustomPaint(
      painter: _OverlayPainter(
        frameRect: Rect.fromLTWH(left, top, frameSize, frameSize),
        frameRadius: frameRadius,
      ),
    );
  }
}

/// 반투명 검은 배경 + 투명 프레임 + 모서리 강조선을 그리는 CustomPainter
class _OverlayPainter extends CustomPainter {
  final Rect frameRect;
  final double frameRadius;

  const _OverlayPainter({
    required this.frameRect,
    required this.frameRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black.withAlpha(140);

    // 전체 배경
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 프레임 영역을 투명하게 뚫기 (BlendMode.clear)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, Radius.circular(frameRadius)),
      clearPaint,
    );

    // 모서리 강조선 (흰색)
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cLen = 24.0; // 모서리 선 길이
    final l = frameRect.left;
    final t = frameRect.top;
    final r = frameRect.right;
    final b = frameRect.bottom;

    // 좌상
    canvas.drawLine(Offset(l, t + cLen), Offset(l, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l + cLen, t), cornerPaint);
    // 우상
    canvas.drawLine(Offset(r - cLen, t), Offset(r, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cLen), cornerPaint);
    // 좌하
    canvas.drawLine(Offset(l, b - cLen), Offset(l, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cLen, b), cornerPaint);
    // 우하
    canvas.drawLine(Offset(r - cLen, b), Offset(r, b), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - cLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// [파일 요약]
// 자산 QR 코드 스캔 화면입니다.
// AssetScanScreen    : ConsumerStatefulWidget — MobileScannerController 생명주기 관리
// _onDetect()        : 스캔된 값이 assetsProvider에 존재하면 /assets/:id 이동,
//                      없으면 SnackBar 안내 후 /assets 이동
// _ScanOverlay       : 반투명 배경 + 투명 프레임 + 모서리 강조선 오버레이
// DetectionSpeed.noDuplicates: 동일 QR 중복 인식 방지
