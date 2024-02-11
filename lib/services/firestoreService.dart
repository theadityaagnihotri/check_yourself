import 'package:check_yourself/model/shared_checklist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> updateChecklist(
      FirestoreChecklistItem checklistItem) async {
    try {
      final checklistRef = FirebaseFirestore.instance
          .collection('checklists')
          .doc(checklistItem.id);

      await checklistRef.update({'checked': checklistItem.checked});
    } catch (e) {
      print('Error updating checklist: $e');
      throw e;
    }
  }

  static Future<void> createChecklistItem(
      FirestoreChecklistItem checklistItem) async {
    try {
      await FirebaseFirestore.instance
          .collection('checklists')
          .doc(checklistItem.id)
          .set(
            checklistItem.toJson(),
          );

      for (String userEmail in checklistItem.sharedWith) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .get();
        if (!userSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail)
              .set({
            'sharedChecklists': [checklistItem.id]
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail)
              .update({
            'sharedChecklists': FieldValue.arrayUnion([checklistItem.id])
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to create checklist item: $e');
    }
  }

  static Future<void> removeChecklistFromUser(
      String userEmail, String checklistId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userEmail);

      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final sharedChecklists =
            List<String>.from(userSnapshot.get('sharedChecklists'));

        sharedChecklists.remove(checklistId);

        await userRef.update({
          'sharedChecklists': sharedChecklists,
        });
      }
    } catch (e) {
      throw Exception('Failed to remove checklist from user: $e');
    }
  }

  static Future<void> updateChecklistItem(
      FirestoreChecklistItem checklistItem) async {
    try {
      final checklistRef = FirebaseFirestore.instance
          .collection('checklists')
          .doc(checklistItem.id);

      await checklistRef.set(checklistItem.toJson());
    } catch (e) {
      throw Exception('Failed to update checklist item: $e');
    }
  }

  static Future<void> deleteChecklistItem(
      String id, List<String> sharedWith) async {
    try {
      for (String userEmail in sharedWith) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .update({
          'sharedChecklists': FieldValue.arrayRemove([id])
        });
      }
      await FirebaseFirestore.instance
          .collection('checklists')
          .where('id', isEqualTo: id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
    } catch (e) {
      throw Exception('Failed to delete checklist item: $e');
    }
  }

  static Future<List<FirestoreChecklistItem>> loadChecklists(
      String userEmail) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();
      final List<FirestoreChecklistItem> tempchecklist = [];
      if (userDoc.exists) {
        List<String> sharedChecklists =
            List<String>.from(userDoc.data()!['sharedChecklists'] ?? []);

        for (String checklistId in sharedChecklists) {
          final checklistDoc = await FirebaseFirestore.instance
              .collection('checklists')
              .doc(checklistId)
              .get();
          if (checklistDoc.exists) {
            var data = checklistDoc.data() as Map<String, dynamic>;
            var checklistItem = FirestoreChecklistItem.fromJson(data);
            tempchecklist.add(checklistItem);
          }
        }
      }
      return tempchecklist;
    } catch (e) {
      throw Exception('Failed to load checklists: $e');
    }
  }
}
