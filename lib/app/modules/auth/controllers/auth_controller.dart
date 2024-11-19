import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    // Écoute des changements dans l'état d'authentification Firebase
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      user.value = newUser;
      if (newUser != null) {
        Get.offAllNamed(Routes.HOME); // Redirection vers la page d'accueil
      } else {
        Get.offAllNamed(Routes.LOGIN); // Redirection vers la page de connexion
      }
    });
  }

  Future<void> signInWithPhone(String phone) async {
    try {
      isLoading.value = true;

      // Vérification et ajout du code pays si nécessaire
      if (!phone.startsWith('+')) {
        phone = '+221$phone'; // Ajout du code pays Sénégal
      }

      // Envoi du code de vérification via AuthService
      await _authService.verifyPhoneNumber(phone);

      // Affichage d'une notification indiquant que le code a été envoyé
      Get.snackbar(
        'Code envoyé',
        'Un code a été envoyé au numéro $phone. Veuillez le saisir pour continuer.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l’envoi du code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    try {
      isLoading.value = true;

      // Vérification du code saisi par l'utilisateur
      final User? authenticatedUser = await _authService.signInWithSmsCode(smsCode);

      if (authenticatedUser != null) {
        Get.offAllNamed(Routes.HOME); // Redirection vers la page d'accueil
      } else {
        Get.snackbar(
          'Erreur',
          'Code de vérification invalide ou expiré.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la vérification du code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Connexion via Google
      final User? user = await _authService.signInWithGoogle();

      if (user != null) {
        Get.offAllNamed(Routes.HOME); // Redirection vers la page d'accueil
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;

      // Connexion via Facebook
      final User? user = await _authService.signInWithFacebook();

      if (user != null) {
        Get.offAllNamed(Routes.HOME); // Redirection vers la page d'accueil
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion Facebook: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      // Déconnexion
      await _authService.signOut();
      Get.offAllNamed(Routes.LOGIN); // Redirection vers la page de connexion
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la déconnexion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
