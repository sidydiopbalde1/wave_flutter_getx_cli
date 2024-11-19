import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../transfer/views/transfer_view.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Ajoutez ici la logique de déconnexion
              // controller.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => _buildBalanceSection()),
          _buildServicesGrid(),
          // _buildTransactionsList(),
        ],
      ),
    );
  }

  /// Widget pour afficher le solde
  Widget _buildBalanceSection() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2.0,
      child: ListTile(
        title: const Text('Solde'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Text(
                  controller.isBalanceVisible.value
                      ? '${controller.balance.value.toStringAsFixed(2)} €'
                      : '****',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
            IconButton(
              icon: Icon(
                controller.isBalanceVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: controller.toggleBalanceVisibility,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour afficher la grille des services
  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          _buildServiceCard('Transfert', Icons.send, () => Get.to(() => TransferView())),
          _buildServiceCard('Planifier', Icons.schedule, () {
            // Ajouter la navigation pour planification
          }),
          _buildServiceCard('Historique', Icons.history, () {
            // Ajouter la navigation pour historique
          }),
        ],
      ),
    );
  }

  /// Widget pour un service individuel
  Widget _buildServiceCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.0, color: Colors.blue),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour la liste des transactions
  // Widget _buildTransactionsList() {
  //   return Expanded(
  //     child: Obx(() {
  //       final transactions = controller.transactions;
  //       if (transactions.isEmpty) {
  //         return const Center(
  //           child: Text(
  //             'Aucune transaction disponible',
  //             style: TextStyle(color: Colors.grey),
  //           ),
  //         );
  //       }
  //       return ListView.builder(
  //         padding: const EdgeInsets.all(12.0),
  //         itemCount: transactions.length,
  //         itemBuilder: (context, index) {
  //           final transaction = transactions[index];
  //           return Card(
  //             margin: const EdgeInsets.symmetric(vertical: 8.0),
  //             child: ListTile(
  //               title: Text(transaction.id),
  //               subtitle: Text(transaction.details),
  //               trailing: Text(
  //                 '${transaction.amount} €',
  //                 style: TextStyle(
  //                   color: transaction.amount < 0 ? Colors.red : Colors.green,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }),
  //   );
  // }
}
