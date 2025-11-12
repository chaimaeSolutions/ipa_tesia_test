import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/l10n/app_localizations.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final ValueNotifier<CameraFacing> _cameraFacing = ValueNotifier(
    CameraFacing.back,
  );

  final ValueNotifier<bool> _torchEnabled = ValueNotifier<bool>(false);

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    _cameraFacing.dispose();
    _torchEnabled.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _hasScanned = true);
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.scanQrCode,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: _torchEnabled,
              builder: (context, enabled, child) {
                return Icon(
                  enabled ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () {
              _controller.toggleTorch();
              _torchEnabled.value = !_torchEnabled.value;
            },
          ),
          IconButton(
            icon: ValueListenableBuilder<CameraFacing>(
              valueListenable: _cameraFacing,
              builder: (context, state, child) {
                return const Icon(Icons.cameraswitch, color: Colors.white);
              },
            ),
            onPressed: () {
              _controller.switchCamera();
              _cameraFacing.value =
                  _cameraFacing.value == CameraFacing.back
                      ? CameraFacing.front
                      : CameraFacing.back;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          CustomPaint(painter: ScannerOverlay(), child: Container()),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kTesiaColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loc.positionTheQrWithinFrame,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutSize = size.width * 0.7;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2;

    final cutoutPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
            const Radius.circular(12),
          ),
        );

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    final paint =
        Paint()
          ..color = kTesiaColor
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    final cornerLength = 40.0;

    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft + cornerLength, cutoutTop),
      paint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft, cutoutTop + cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop),
      paint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cornerLength, cutoutTop + cutoutSize),
      paint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      Offset(cutoutLeft, cutoutTop + cutoutSize - cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop + cutoutSize),
      paint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
