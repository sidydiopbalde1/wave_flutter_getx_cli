import 'package:get/get.dart';

class DistributorController extends GetxController {
  // Variables observables
  var solde = 50000.0.obs;
  var afficherSolde = false.obs;
  var transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Charger les transactions initiales (simulation)
    _loadInitialTransactions();
  }

  // Méthode pour basculer l'affichage du solde
  void toggleAfficherSolde() {
    afficherSolde.value = !afficherSolde.value;
  }

  // Méthode pour ajouter une transaction
  void addTransaction(Map<String, dynamic> transaction) {
    transactions.insert(0, transaction); // Ajouter au début de la liste
    
    // Mettre à jour le solde en fonction du type de transaction
    double montant = double.tryParse(transaction['montant'].toString()) ?? 0;
    
    switch(transaction['type']) {
      case 'Retrait':
        solde.value -= montant;
        break;
      case 'Dépôt':
        solde.value += montant;
        break;
      case 'Déplafonnement':
        // Logique spécifique pour le déplafonnement si nécessaire
        break;
    }
  }

  // Méthode privée pour charger les transactions initiales
  void _loadInitialTransactions() {
    // Simulation de transactions passées
    final List<Map<String, dynamic>> initialTransactions = [
      {
        'type': 'Dépôt',
        'montant': '15000',
        'date': '2024-03-20 14:30:00',
      },
      {
        'type': 'Retrait',
        'montant': '5000',
        'date': '2024-03-19 10:15:00',
      },
      {
        'type': 'Déplafonnement',
        'montant': '50000',
        'date': '2024-03-18 16:45:00',
      },
    ];

    transactions.assignAll(initialTransactions);
  }

  // Méthode pour effectuer un retrait
  Future<bool> effectuerRetrait(double montant) async {
    if (montant <= solde.value) {
      solde.value -= montant;
      addTransaction({
        'type': 'Retrait',
        'montant': montant.toString(),
        'date': DateTime.now().toString(),
      });
      return true;
    }
    return false;
  }

  // Méthode pour effectuer un dépôt
  void effectuerDepot(double montant) {
    solde.value += montant;
    addTransaction({
      'type': 'Dépôt',
      'montant': montant.toString(),
      'date': DateTime.now().toString(),
    });
  }

  // Méthode pour effectuer un déplafonnement
  Future<bool> effectuerDeplafonnement(double nouveauPlafond) async {
    addTransaction({
      'type': 'Déplafonnement',
      'montant': nouveauPlafond.toString(),
      'date': DateTime.now().toString(),
    });
    return true;
  }
}