class TransactionModel {
   final int id;
  final double montant;
  final String status;
  final DateTime date;
  final double frais;
  final String type;
  final int senderId;
  final int receiverId;

  TransactionModel({
    required this.id,
    required this.montant,
    required this.status,
    required this.date,
    required this.frais,
    required this.type,
    required this.senderId,
    required this.receiverId,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      montant: data['montant'],
      date: DateTime.parse(data['date']),
      type: data['type'],
      status: data['status'],
      frais: data['frais'],
      

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'montant': montant,
      'date': date.toIso8601String(),
      'type': type
    };
  }
}