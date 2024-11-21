import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService; // Service d'authentification personnalisé
  final Rx<User?> user = Rx<User?>(null); // Utilisateur actuellement connecté
  final RxBool isLoading = false.obs; // Indicateur d'état de chargement

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    // Surveiller les changements d'état d'authentification
    FirebaseAuth.instance.authStateChanges().listen(_authStateListener);
  }

  void _authStateListener(User? newUser) {
    user.value = newUser;
    if (newUser != null) {
      Get.offAllNamed(Routes.HOME); // Redirection vers la page d'accueil
    } else {
      Get.offAllNamed(Routes.LOGIN); // Redirection vers la page de connexion
    }
  }

  /// Connexion via numéro de téléphone
  Future<void> signInWithPhone(String phone) async {
    try {
      isLoading.value = true;

      // Ajout du code pays si absent
      if (!phone.startsWith('+')) {
        phone = '+221$phone'; // Sénégal par défaut
      }

      // Appel du service pour vérifier le numéro
      await _authService.verifyPhoneNumber(phone);

      Get.snackbar(
        'Code envoyé',
        'Un code a été envoyé au numéro $phone. Veuillez le saisir.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('Échec de l’envoi du code', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Vérification du code SMS
  Future<void> verifySmsCode(String smsCode) async {
    try {
      isLoading.value = true;

      // Vérification via le service
      final User? authenticatedUser = await _authService.signInWithSmsCode(smsCode);

      if (authenticatedUser != null) {
        Get.offAllNamed(Routes.HOME); // Redirection
      } else {
        Get.snackbar(
          'Erreur',
          'Code de vérification invalide ou expiré.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _handleError('Échec de la vérification du code', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Connexion avec email et mot de passe
Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;

      // Connexion à Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // Récupération des données utilisateur depuis Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          final String role = userData['role'] ?? 'client'; // Rôle de l'utilisateur (par défaut : client)

          // Redirection en fonction du rôle
          if (role == 'distributor') {
            Get.offAllNamed('/distributor'); // Page pour administrateurs
          } else if (role == 'client') {
            Get.offAllNamed('/home'); // Page pour clients
          } else {
            Get.snackbar(
              'Erreur',
              'Rôle utilisateur inconnu.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          Get.snackbar(
            'Erreur',
            'Aucun profil trouvé pour cet utilisateur.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Erreur',
          'Échec de la connexion, vérifiez vos identifiants.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _handleError('Échec de la connexion', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(String message, dynamic error) {
    print('❌ $message : $error');
    Get.snackbar(
      'Erreur',
      '$message. ${error.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Connexion avec Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Connexion via Google
      final User? googleUser = await _authService.signInWithGoogle();

      if (googleUser != null) {
        Get.offAllNamed(Routes.HOME); // Redirection
      } else {
        Get.snackbar(
          'Erreur',
          'Échec de la connexion Google.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _handleError('Échec de la connexion Google', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.LOGIN); // Redirection vers login
    } catch (e) {
      _handleError('Échec de la déconnexion', e);
    }
  }

  /// Gestion des erreurs avec messages utilisateur
  // void _handleError(String title, dynamic error) {
  //   Get.snackbar(
  //     title,
  //     error.toString(),
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }
}
