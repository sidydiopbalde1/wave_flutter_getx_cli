import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wave_getx_cli_v2/app/modules/transaction/controllers/transaction_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart'; // Importez AuthController

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enregistrez AuthService avant AuthController
  final authService = AuthService();
  
  // Enregistrez AuthController avec Get.put
  Get.put(AuthController(authService));
  Get.put(TransactionController());

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
