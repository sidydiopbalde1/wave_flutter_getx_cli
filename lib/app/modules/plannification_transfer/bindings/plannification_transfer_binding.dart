import 'package:get/get.dart';

import '../controllers/plannification_transfer_controller.dart';

class PlannificationTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlannificationTransferController>(
      () => PlannificationTransferController(),
    );
  }
}
