import 'package:get/get.dart';

import '../controllers/qr_scanner_page_controller.dart';

class QrScannerPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrScannerPageController>(
      () => QrScannerPageController(),
    );
  }
}
