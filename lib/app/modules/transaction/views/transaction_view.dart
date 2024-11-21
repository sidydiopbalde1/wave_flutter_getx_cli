import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import 'create_transaction_view.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transactionModel.dart';

class TransactionView extends StatelessWidget {
  TransactionView({super.key});

  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Fonctionnalité de filtrage à implémenter
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        // Vérification si les transactions sont vides
        if (controller.transactions.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTransactionList();
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateTransactionView()),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nouvelle Transaction', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined, 
            size: 100, 
            color: Colors.blue[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune transaction disponible',
            style: TextStyle(
              fontSize: 20, 
              color: Colors.blue[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Commencez par créer votre première transaction',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: _getTransactionColor(transaction.type),
          ),
        ),
        title: Text(
          '${transaction.montant.toStringAsFixed(2)} €',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: _getTransactionColor(transaction.type),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut : ${transaction.status}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              DateFormat('dd MMM yyyy HH:mm').format(transaction.date),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            transaction.type,
            style: TextStyle(
              color: _getTransactionColor(transaction.type),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'retrait':
        return Colors.red;
      case 'transfert':
        return Colors.blue;
      case 'depot':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'retrait':
        return Icons.arrow_upward;
      case 'transfert':
        return Icons.swap_horiz;
      case 'depot':
        return Icons.arrow_downward;
      default:
        return Icons.attach_money;
    }
  }
}
