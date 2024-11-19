import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;  // Pour afficher l'indicateur de chargement
  var errorMessage = ''.obs;  // Pour afficher les erreurs d'authentification

  // Fonction pour se connecter avec email et mot de passe
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading(true);  // Affiche le chargement pendant l'authentification

      // Connexion avec email et mot de passe
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading(false);  // Cache l'indicateur de chargement une fois l'authentification terminée

      // Vérifier si l'utilisateur est connecté
      if (userCredential.user != null) {
        Get.offAllNamed('/home');  // Navigation vers l'écran principal après connexion réussie
      }
    } catch (e) {
      isLoading(false);  // Cache l'indicateur de chargement en cas d'erreur
      errorMessage.value = e.toString();  // Affiche l'erreur
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
