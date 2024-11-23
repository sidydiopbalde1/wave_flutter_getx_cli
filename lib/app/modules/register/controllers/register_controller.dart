// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/userModel.dart'; // Import du modèle UserModel
  import 'package:cloud_firestore/cloud_firestore.dart';
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
    print('🔄 Tentative de création d\'un nouvel utilisateur avec email : ${emailController.text.trim()}');

    // Créer un utilisateur avec email et mot de passe
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    print('✅ Utilisateur créé avec succès dans Firebase Authentication');

    // Récupérer l'ID de l'utilisateur
    User? user = userCredential.user;

    // Vérifier si l'utilisateur a été créé correctement
    if (user != null) {
      print('📋 UID utilisateur : ${user.uid}');

      // Créer un modèle `UserModel`
      UserModel userModel = UserModel(
        id: DateTime.now().toIso8601String() , 
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        email: emailController.text.trim(),
        telephone: telephoneController.text.trim(),
        solde: 0.0,
        plafond: 50000,
        codeSecret: '1234', 
        role: 'client', 
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Enregistrer les informations dans Firestore avec l'UID comme identifiant du document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userModel.toFirestore());
      print('✅ Données utilisateur enregistrées dans Firestore avec succès');

      // Afficher un message de succès
      Get.snackbar('Succès', 'Inscription réussie');
      print('🎉 Inscription réussie, redirection vers la page de connexion');

      // Naviguer vers l'écran de connexion ou l'écran principal
      Get.offAllNamed('/login');
    } else {
      print('❌ Erreur : Utilisateur non trouvé après la création');
      Get.snackbar('Erreur', 'Utilisateur introuvable.');
    }
  } catch (e) {
    // Gérer les erreurs
    print('❌ Erreur lors de l\'inscription : $e');
    Get.snackbar('Erreur', 'Erreur : ${e.toString()}');
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
