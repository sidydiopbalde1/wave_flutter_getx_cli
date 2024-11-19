// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final double solde;
  final String? photo;
  final String codeSecret;
  final String? plafond;
  final int roleId;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.solde,
    this.photo,
    required this.codeSecret,
    this.plafond,
    required this.roleId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory pour créer une instance depuis un `Map` (Firestore ou autre)
  factory UserModel.fromFirestore(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      solde: double.tryParse(json['solde'].toString()) ?? 0.0, // Gestion des valeurs invalides
      photo: json['photo'] as String?,
      codeSecret: json['code_secret'] as String,
      plafond: json['plafond']?.toString(), // Conversion en String si nécessaire
      roleId: json['role_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Méthode pour convertir l'objet en `Map` (utilisé pour Firestore ou autre base de données)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'solde': solde,
      'photo': photo,
      'code_secret': codeSecret,
      'plafond': plafond,
      'role_id': roleId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

    // Méthode pour sauvegarder un utilisateur dans Firestore
  // Future<void> save() async {
  //   try {
  //     // Référence à la collection 'users'
  //     CollectionReference users = FirebaseFirestore.instance.collection('users');
      
  //     // Ajout du document
  //     await users.add(toFirestore());
  //     print("Utilisateur ajouté avec succès");
  //   } catch (e) {
  //     print("Erreur lors de l'ajout de l'utilisateur: $e");
  //   }
  // }
}

