import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/distributor/bindings/distributor_binding.dart';
import '../modules/distributor/views/distributor_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/plannification_transfer/bindings/plannification_transfer_binding.dart';
import '../modules/plannification_transfer/views/plannification_transfer_view.dart';
import '../modules/qr_scanner_page/bindings/qr_scanner_page_binding.dart';
import '../modules/qr_scanner_page/views/qr_scanner_page_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/transaction/bindings/transaction_binding.dart';
import '../modules/transaction/views/transaction_view.dart';
import '../modules/transfer/bindings/transfer_binding.dart';
import '../modules/transfer/views/transfer_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.TRANSFER,
      page: () => TransferView(),
      binding: TransferBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTION,
      page: () => TransactionView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: _Paths.DISTRIBUTOR,
      page: () => DistributorView(),
      binding: DistributorBinding(),
    ),
    GetPage(
      name: _Paths.QR_SCANNER_PAGE,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return QRScannerPageView(
          serviceType: arguments?['serviceType'] ?? 'Default',
        );
      },
      binding: QrScannerPageBinding(),
    ),
    GetPage(
      name: _Paths.PLANNIFICATION_TRANSFER,
      page: () =>  PlannificationTransferView(),
      binding: PlannificationTransferBinding(),
    ),
  ];
}
