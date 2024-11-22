import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../distributor/controllers/distributor_controller.dart';

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
    // Initialize the DistributorController
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
                  _processQRCode(code);
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

  // Overlay de texte avec des instructions à l'écran
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

  // Traitement du QR code scanné
  void _processQRCode(String qrData) {
    // MobileScanner().stop(); // Arrêter le scanner après la détection du QR code
    _showAmountDialog(qrData); // Afficher le dialog pour entrer le montant
  }

  // Affichage d'une boîte de dialogue pour saisir le montant
  void _showAmountDialog(String qrData) {
    final TextEditingController montantController = TextEditingController();
    final String scannedPhoneNumber = qrData;

    Get.dialog(
      AlertDialog(
        title: Text('Montant pour ${widget.serviceType}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScannedPhoneCard(scannedPhoneNumber),
            const SizedBox(height: 16),
            _buildAmountInputField(montantController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              isScanned = false; // Réinitialiser l'état du scan
              // MobileScanner().start(); // Relancer le scanner
              Get.back();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _processTransaction(
              montantController.text,
              scannedPhoneNumber,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F5CA8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Carte d'affichage du numéro de téléphone scanné
  Widget _buildScannedPhoneCard(String phoneNumber) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phone, color: Color(0xFF2F5CA8)),
        title: const Text('Téléphone scanné'),
        subtitle: Text(phoneNumber),
      ),
    );
  }

  // Champ pour saisir le montant
  Widget _buildAmountInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Montant en XOF',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.money),
        suffixText: 'XOF',
      ),
      autofocus: true,
    );
  }

  // Traitement de la transaction après confirmation
  void _processTransaction(String montant, String phoneNumber) async {
    final double? amount = double.tryParse(montant.replaceAll(',', '.'));
    if (amount == null) {
      // Get.snackbar(
      //   'Erreur',
      //   'Veuillez entrer un montant valide',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return;
    }

    String message;
    try {
      switch (widget.serviceType) {
        case 'Retrait':
          message = await _controller.effectuerRetrait(amount, phoneNumber);
          break;
        case 'Dépôt':
          message = await _controller.effectuerDepot(amount, phoneNumber);
          break;
        case 'Déplafonnement':
          message = await _controller.deplafonnerUtilisateur(amount, phoneNumber);
          break;
        default:
          message = 'Type de service non reconnu';
      }

      // Fermer la snackbar après un petit délai
      Future.delayed(const Duration(milliseconds: 500), () {
        // Get.snackbar(
        //   widget.serviceType,
        //   message,
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green.withOpacity(0.1),
        //   colorText: Colors.green,
        //   duration: const Duration(seconds: 3),
        // );
        // Get.back(); // Ferme les dialogues après l'affichage de la snackbar
      });
    } catch (e) {
      // Get.snackbar(
      //   'Erreur',
      //   'Une erreur est survenue lors de la transaction',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
    }
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
