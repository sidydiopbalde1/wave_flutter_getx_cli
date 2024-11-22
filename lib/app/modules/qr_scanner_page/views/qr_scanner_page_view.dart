
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
 import '../../distributor/controllers/distributor_controller.dart';
class QrScannerPageView extends StatefulWidget {
  final String serviceType;

  const QrScannerPageView({Key? key, required this.serviceType}) : super(key: key);

  @override
  State<QrScannerPageView> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QrScannerPageView> {
  MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  void _processQRCode(String qrData) {
    if (!isScanned) {
      isScanned = true;
      Get.back();
      
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirmation ${widget.serviceType}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Voulez-vous effectuer un ${widget.serviceType} ?'),
              const SizedBox(height: 8),
              Text(
                'Code scanné : $qrData',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Succès',
                  'Transaction ${widget.serviceType} effectuée avec succès',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
                // Ajouter la transaction au contrôleur
                final DistributorController controller = Get.find();
                controller.addTransaction({
                  'type': widget.serviceType,
                  'montant': '10000',  // À remplacer par le montant réel
                  'date': DateTime.now().toString(),
                });
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                setState(() {
                  isScanned = false;
                });
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner pour ${widget.serviceType}'),
        backgroundColor: const Color.fromARGB(255, 47, 92, 168),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _processQRCode(barcode.rawValue ?? 'Code non valide');
              }
            },
          ),
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Placez le QR code dans le cadre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Classe pour l'overlay du scanner
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint overlayPaint = Paint()
      ..color = Colors.black54;

    // Overlay semi-transparent
   canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTRB(left, top, right, bottom),
            const Radius.circular(12),
          )),
      ),
      overlayPaint,
    );

    // Cadre de scan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        Radius.circular(12),
      ),
      borderPaint,
    );

    // Coins du cadre
    final double cornerSize = 20;
    final Paint cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Coin supérieur gauche
    canvas.drawLine(
      Offset(left, top + cornerSize),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerSize, top),
      cornerPaint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(right - cornerSize, top),
      Offset(right, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerSize),
      cornerPaint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(left, bottom - cornerSize),
      Offset(left, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerSize, bottom),
      cornerPaint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(right - cornerSize, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}