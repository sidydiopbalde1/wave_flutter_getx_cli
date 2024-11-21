import 'package:get/get.dart';

class DistributorController extends GetxController {
  RxDouble solde = 5000.0.obs; // Solde de l'utilisateur
  RxBool afficherSolde = true.obs; // Permet d'afficher/masquer le solde
  RxList<Map<String, String>> transactions = <Map<String, String>>[].obs; // Liste des transactions

  void toggleAfficherSolde() {
    afficherSolde.value = !afficherSolde.value;
  }

  void ajouterTransaction(String type, String montant) {
    transactions.add({
      'type': type,
      'montant': montant,
      'date': DateTime.now().toIso8601String(),
    });
  }
}
