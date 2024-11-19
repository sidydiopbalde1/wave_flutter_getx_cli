import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId; // Stocker l'ID de vérification pour valider le code

  // Connexion Gmail
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth?.accessToken == null || googleAuth?.idToken == null) {
        return null; // L'utilisateur a annulé la connexion
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Erreur de connexion avec Google: $e");
      return null;
    }
  }

  // Connexion téléphone - étape 1 : Envoyer un code de vérification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Authentification automatique (si possible)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Erreur de vérification: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Stocker l'ID pour utilisation ultérieure
          _verificationId = verificationId;
          print("Code envoyé au numéro $phoneNumber.");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Temps d'attente expiré
          _verificationId = verificationId;
          print("Temps d'attente expiré pour la vérification.");
        },
      );
    } catch (e) {
      print("Erreur lors de la vérification du téléphone: $e");
    }
  }

  // Connexion téléphone - étape 2 : Vérifier le code
  Future<User?> signInWithSmsCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        print("Erreur : l'ID de vérification est manquant.");
        return null;
      }

      // Créer les informations d'identification à partir du code SMS
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Authentifier l'utilisateur avec Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Erreur de connexion avec le code SMS: $e");
      return null;
    }
  }

  // Connexion Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print("Erreur de connexion avec Facebook: $e");
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      print("Erreur de déconnexion: $e");
    }
  }

  // Récupérer l'utilisateur actuel
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }
}
