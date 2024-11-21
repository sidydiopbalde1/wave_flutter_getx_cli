import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/distributor_controller.dart';

class DistributeurPage extends StatelessWidget {
  final DistributorController controller = Get.put(DistributorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distributeur'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde Section
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solde :',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: controller.toggleAfficherSolde,
                      child: Text(
                        controller.afficherSolde.value
                            ? '${controller.solde.value.toStringAsFixed(2)} XOF'
                            : '******',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 16),

            // QR Code (simulé)
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Boutons de service
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _serviceButton('Retrait', Icons.money, Colors.blue),
                _serviceButton('Dépôt', Icons.account_balance, Colors.green),
                _serviceButton('Déplafonnement', Icons.lock_open, Colors.orange),
              ],
            ),
            SizedBox(height: 16),

            // Liste des transactions
            Text(
              'Transactions récentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Obx(() {
                if (controller.transactions.isEmpty) {
                  return Center(child: Text('Aucune transaction disponible.'));
                }
                return ListView.builder(
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          transaction['type'] == 'Retrait'
                              ? Icons.money_off
                              : transaction['type'] == 'Dépôt'
                                  ? Icons.account_balance_wallet
                                  : Icons.lock,
                          color: transaction['type'] == 'Retrait'
                              ? Colors.red
                              : transaction['type'] == 'Dépôt'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                        title: Text(transaction['type'] ?? ''),
                        subtitle: Text(transaction['date'] ?? ''),
                        trailing: Text(
                          '${transaction['montant']} XOF',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bouton de service
  Widget _serviceButton(String title, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Logique pour scanner le QR Code et effectuer une transaction
        Get.snackbar(
          'Scanner QR Code',
          'Veuillez scanner le QR Code pour $title',
          backgroundColor: color.withOpacity(0.8),
          colorText: Colors.white,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
