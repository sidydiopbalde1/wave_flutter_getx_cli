import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/userModel.dart'; // Import du modèle UserModel

class RegisterController extends GetxController {
  // Contrôleurs pour les champs de formulaire
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isPasswordVisible = false.obs;

  // Méthode pour enregistrer un utilisateur
  Future<void> registerUser() async {
    try {
      // Créer un utilisateur avec email et mot de passe
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Récupérer l'ID de l'utilisateur
      User? user = userCredential.user;
      if (user != null) {
        // Enregistrer les informations supplémentaires dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nom': nomController.text,
          'prenom': prenomController.text,
          'telephone': telephoneController.text,
          'email': emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Récupérer les données de l'utilisateur depuis Firestore
        await fetchUserData(user.uid);

        // Afficher un message de succès
        Get.snackbar('Succès', 'Inscription réussie');
        // Naviguer vers l'écran de connexion ou l'écran principal
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // Gérer les erreurs
      Get.snackbar('Erreur', 'Erreur : ${e.toString()}');
      print('Erreur lors de l\'inscription: $e');
    }
  }

  // Méthode pour récupérer les données d'un utilisateur depuis Firestore
  Future<void> fetchUserData(String userId) async {
    try {
      // Récupérer le document de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      // Vérifier si le document existe
      if (userDoc.exists) {
        // Convertir les données du document en un modèle UserModel
        UserModel user = UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);

        // Afficher ou manipuler l'utilisateur
        print('Utilisateur récupéré : ${user.nom} ${user.prenom}');
        // Vous pouvez également sauvegarder cet utilisateur dans un état global ou le manipuler comme nécessaire
      } else {
        print('Utilisateur non trouvé');
      }
    } catch (e) {
      print('Erreur de récupération des données de l\'utilisateur : $e');
    }
  }

  // Méthode pour basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    nomController.dispose();
    prenomController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
