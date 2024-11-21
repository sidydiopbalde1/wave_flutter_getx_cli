class TransactionModel {
  final String id; // Utilisation d'un id de type String pour Firestore
  final double montant;
  final String status;
  final DateTime date;
  final double frais;
  final String type;
  final String senderId;
  final String receiverId;
  final String recipientName;

  TransactionModel({
    required this.id,
    required this.montant,
    required this.status,
    required this.date,
    required this.frais,
    required this.type,
    required this.senderId,
    required this.receiverId,
    required this.recipientName,
  });

  // Convertir les données de Firestore en modèle TransactionModel
  factory TransactionModel.fromFirestore(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'], // Assurez-vous que 'id' est bien présent dans Firestore
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      montant: (data['montant'] as num).toDouble(), // Conversion vers double
      date: (data['date']).toDate(), // Conversion Timestamp -> DateTime
      type: data['type'] ?? 'Inconnu', // Valeur par défaut si non défini
      status: data['status'] ?? 'Inconnu', // Valeur par défaut si non défini
      frais: (data['frais'] as num).toDouble(), // Conversion vers double
      recipientName: data['recipientName']?? 'Feeling', // Valeur par défaut si non défini
    );
  }

  // Convertir le modèle TransactionModel en format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id, // Assurez-vous de bien inclure 'id' si vous le souhaitez
      'senderId': senderId,
      'receiverId': receiverId,
      'montant': montant,
      'date': date.toIso8601String(), // Date au format ISO 8601
      'type': type,
      'status': status,
      'frais': frais, // Inclure le champ 'frais'
      'recipientName': recipientName, // Inclure le champ'recipientName'
    };
  }
}
