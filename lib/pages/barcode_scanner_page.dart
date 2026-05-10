import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.itf14,
      BarcodeFormat.codabar,
    ],
  );

  bool scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleDetect(BarcodeCapture capture) {
    if (scanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;

    if (code == null || code.trim().isEmpty) return;

    scanned = true;

    Navigator.of(context).pop(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scanBarcodeTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.flash,
            icon: const Icon(Icons.flash_on),
            onPressed: controller.toggleTorch,
          ),
          IconButton(
            tooltip: context.l10n.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
            onPressed: controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: handleDetect),
          const _ScannerOverlay(),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
