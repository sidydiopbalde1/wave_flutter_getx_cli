// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.processScheduledTransactions = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    try {
      // Récupérer toutes les transactions planifiées dont la date est passée
      const scheduledTransactionsSnapshot = await firestore
        .collection('transactions')
        .where('status', '==', 'scheduled')
        .where('scheduledDate', '<=', now)
        .get();

      if (scheduledTransactionsSnapshot.empty) {
        console.log('Aucune transaction planifiée à traiter');
        return null;
      }

      // Traiter chaque transaction
      const batch = firestore.batch();
      
      for (const doc of scheduledTransactionsSnapshot.docs) {
        const transaction = doc.data();
        
        try {
          // Vérifier l'existence des utilisateurs
          const [senderDoc, recipientDoc] = await Promise.all([
            firestore.collection('users').doc(transaction.senderId).get(),
            firestore.collection('users').doc(transaction.recipientId).get()
          ]);

          if (!senderDoc.exists || !recipientDoc.exists) {
            console.error(`Utilisateur non trouvé pour la transaction ${doc.id}`);
            // Marquer la transaction comme échouée
            batch.update(doc.ref, {
              status: 'failed',
              failureReason: 'Utilisateur non trouvé',
              processedAt: now
            });
            continue;
          }

          const senderData = senderDoc.data();
          const recipientData = recipientDoc.data();
          const amount = transaction.amount;

          // Vérifier le solde de l'expéditeur
          if (senderData.balance < amount) {
            console.error(`Solde insuffisant pour la transaction ${doc.id}`);
            // Marquer la transaction comme échouée
            batch.update(doc.ref, {
              status: 'failed',
              failureReason: 'Solde insuffisant',
              processedAt: now
            });
            continue;
          }

          // Mettre à jour les soldes
          batch.update(senderDoc.ref, {
            balance: admin.firestore.FieldValue.increment(-amount)
          });

          batch.update(recipientDoc.ref, {
            balance: admin.firestore.FieldValue.increment(amount)
          });

          // Marquer la transaction comme réussie
          batch.update(doc.ref, {
            status: 'completed',
            processedAt: now
          });

          // Créer une notification pour l'expéditeur
          const senderNotificationRef = firestore.collection('notifications').doc();
          batch.set(senderNotificationRef, {
            userId: transaction.senderId,
            type: 'scheduled_transaction_completed',
            title: 'Transfert planifié exécuté',
            message: `Votre transfert planifié de ${amount} FCFA vers ${recipientData.name} a été exécuté avec succès.`,
            read: false,
            createdAt: now
          });

          // Créer une notification pour le destinataire
          const recipientNotificationRef = firestore.collection('notifications').doc();
          batch.set(recipientNotificationRef, {
            userId: transaction.recipientId,
            type: 'received_scheduled_transfer',
            title: 'Transfert reçu',
            message: `Vous avez reçu un transfert planifié de ${amount} FCFA de ${senderData.name}.`,
            read: false,
            createdAt: now
          });

        } catch (error) {
          console.error(`Erreur lors du traitement de la transaction ${doc.id}:`, error);
          // Marquer la transaction comme échouée
          batch.update(doc.ref, {
            status: 'failed',
            failureReason: error.message,
            processedAt: now
          });
        }
      }

      // Exécuter toutes les opérations en batch
      await batch.commit();
      console.log('Traitement des transactions planifiées terminé');
      return null;

    } catch (error) {
      console.error('Erreur lors du traitement des transactions planifiées:', error);
      return null;
    }
});

// Fonction pour nettoyer les anciennes transactions planifiées échouées
exports.cleanupFailedScheduledTransactions = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const oneWeekAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    );

    try {
      const failedTransactionsSnapshot = await firestore
        .collection('transactions')
        .where('status', '==', 'failed')
        .where('processedAt', '<=', oneWeekAgo)
        .get();

      if (failedTransactionsSnapshot.empty) {
        return null;
      }

      const batch = firestore.batch();
      failedTransactionsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`${failedTransactionsSnapshot.size} transactions échouées nettoyées`);
      return null;
    } catch (error) {
      console.error('Erreur lors du nettoyage des transactions échouées:', error);
      return null;
    }
});