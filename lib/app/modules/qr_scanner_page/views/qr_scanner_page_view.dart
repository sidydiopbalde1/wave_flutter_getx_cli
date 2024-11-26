import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../distributor/controllers/distributor_controller.dart';
import '../../transaction/views/transaction_form_view.dart';

class QRScannerPageView extends StatefulWidget {
  final String serviceType;

  const QRScannerPageView({Key? key, required this.serviceType}) : super(key: key);

  @override
  _QRScannerViewState createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerPageView> {
  bool isScanned = false;
  late DistributorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DistributorController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner pour ${widget.serviceType}'),
        backgroundColor: const Color(0xFF2F5CA8),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (!isScanned && barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  isScanned = true;
                  _handleScannedQRCode(code);
                }
              }
            },
          ),
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          _buildInstructionOverlay(),
        ],
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Placez le QR code dans le cadre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _handleScannedQRCode(String qrData) {
    // Naviguer vers TransactionFormView avec les données scannées
    Get.to(() => TransactionFormView(
          serviceType: widget.serviceType,
          phoneNumber: qrData,
        ));
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanArea = size.width * 0.8;
    final double left = (size.width - scanArea) / 2;
    final double top = (size.height - scanArea) / 2;
    final double right = left + scanArea;
    final double bottom = top + scanArea;

    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

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
      paint,
    );

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF2F5CA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    final Paint cornerPaint = Paint()
      ..color = const Color(0xFF2F5CA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final double cornerSize = 20;
    canvas.drawLine(Offset(left, top + cornerSize), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), cornerPaint);

    canvas.drawLine(Offset(right - cornerSize, top), Offset(right, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerSize), cornerPaint);

    canvas.drawLine(Offset(left, bottom - cornerSize), Offset(left, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerSize, bottom), cornerPaint);

    canvas.drawLine(Offset(right - cornerSize, bottom), Offset(right, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}