import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm_app/models/baseModel.dart';
import 'package:crm_app/services/business_config.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the dynamic collection path based on business info
  Future<String> _getCollectionPath(BaseModel model) async {
    final businessInfo = await BusinessConfig.getBusinessInfo();
    final String businessID =
        businessInfo['businessID']?.replaceAll(RegExp(r'[-/]'), '') ?? '';
    final String phone =
        businessInfo['phone']?.replaceAll(RegExp(r'[-/]'), '') ?? '';

    if (businessID.isEmpty || phone.isEmpty) {
      throw Exception('Business information is not set properly.');
    }

    final collectionPathBase = "businesses/$businessID$phone";
    final DocumentReference businessDocRef = _firestore.doc(collectionPathBase);
    final DocumentSnapshot businessDocSnapshot = await businessDocRef.get();

    if (!businessDocSnapshot.exists) {
      await businessDocRef.set({
        'businessName': businessInfo['businessName'],
        'businessID': businessID,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Business document created at $collectionPathBase.');
    }

    return "$collectionPathBase/${model.getModelName()}";
  }

  // Insert new document with a specific ID
  Future<void> insert(BaseModel model) async {
    try {
      String collectionPath = await _getCollectionPath(model);
      String documentId =
          model.id; // Use the model's ID as Firebase document ID
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(model.toMap());
      print(
          'Document inserted successfully with ID $documentId in $collectionPath');
    } catch (e) {
      print('Failed to insert document: $e');
      throw Exception('Insert failed');
    }
  }

  // Update an existing document by ID
  Future<void> update(BaseModel model, String docID) async {
    try {
      String collectionPath = await _getCollectionPath(model);
      await _firestore
          .collection(collectionPath)
          .doc(docID)
          .update(model.toMap());
      print('Document $docID updated successfully in $collectionPath');
    } catch (e) {
      print('Failed to update document $docID: $e');
      throw Exception('Update failed');
    }
  }

  // Delete a document by ID
  Future<void> delete(BaseModel model, String docID) async {
    try {
      String collectionPath = await _getCollectionPath(model);
      await _firestore.collection(collectionPath).doc(docID).delete();
      print('Document $docID deleted successfully from $collectionPath');
    } catch (e) {
      print('Failed to delete document $docID: $e');
      throw Exception('Delete failed');
    }
  }

  // Retrieve all documents in the model's collection
  Future<List<Map<String, dynamic>>> fetchAll(BaseModel model) async {
    try {
      String collectionPath = await _getCollectionPath(model);
      QuerySnapshot snapshot =
          await _firestore.collection(collectionPath).get();
      print('Documents fetched successfully from $collectionPath');
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Failed to fetch documents: $e');
      throw Exception('Fetch failed');
    }
  }

  // Fetch records modified since lastSyncTime
  Future<List<Map<String, dynamic>>> fetchSince(
      BaseModel model, DateTime lastSyncTime) async {
    try {
      String collectionPath = await _getCollectionPath(model);
      Timestamp lastSyncTimestamp = Timestamp.fromDate(lastSyncTime);
      QuerySnapshot snapshot = await _firestore
          .collection(collectionPath)
          .where('lastModifiedAt', isGreaterThan: lastSyncTimestamp)
          .get();

      print('Documents fetched since last sync from $collectionPath');
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error fetching records since last sync: $e');
      return [];
    }
  }
}
