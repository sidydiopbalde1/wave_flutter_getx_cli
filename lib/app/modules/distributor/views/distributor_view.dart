import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/distributor_controller.dart';
import '../../../routes/app_pages.dart';

class DistributorView extends StatelessWidget {
  final DistributorController controller = Get.put(DistributorController());

  DistributorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributeur'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 47, 92, 168),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSoldeSection(), // Solde Section
            const SizedBox(height: 24),
            _buildServicesSection(), // Services Section
            const SizedBox(height: 24),
            _buildTransactionsSection(), // Transactions Section
          ],
        ),
      ),
    );
  }

  // Section du solde
  Widget _buildSoldeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Solde :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: controller.toggleAfficherSolde,
              child: Row(
                children: [
                  Text(
                    controller.afficherSolde.value
                        ? '${controller.solde.value.toStringAsFixed(2)} XOF'
                        : '******',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    controller.afficherSolde.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section des services
 Widget _buildServicesSection() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            serviceButton('Retrait', Icons.money, Colors.blue),
            serviceButton('Dépôt', Icons.account_balance, Colors.green),
            serviceButton('Déplafonnement', Icons.lock_open, Colors.orange),
          ],
        ),
      ],
    ),
  );
}

  Widget serviceButton(String title, IconData icon, Color color) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: () => Get.toNamed(
          Routes.QR_SCANNER_PAGE,
          arguments: {'serviceType': title},
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section des transactions
  Widget _buildTransactionsSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () {
                  if (controller.transactions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune transaction disponible',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction['type']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTransactionIcon(transaction['type']),
            color: _getTransactionColor(transaction['type']),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              transaction['type'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${transaction['montant']} XOF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getTransactionColor(transaction['type']),
              ),
            ),
          ],
        ),
        subtitle: Text(
          transaction['date'] ?? '',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor(String? type) {
    switch (type) {
      case 'Retrait':
        return Colors.red;
      case 'Dépôt':
        return Colors.green;
      case 'Déplafonnement':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String? type) {
    switch (type) {
      case 'Retrait':
        return Icons.money_off;
      case 'Dépôt':
        return Icons.account_balance_wallet;
      case 'Déplafonnement':
        return Icons.lock_open;
      default:
        return Icons.help_outline;
    }
  }
}
