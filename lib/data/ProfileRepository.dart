import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/profile.dart'; // Make sure this path points to your NewUser model file

class UserRepository extends GetxService {
  late CollectionReference newUserCollection;

  UserRepository(){
    newUserCollection = FirebaseFirestore.instance.collection('users');
  }

  // --- CRITICAL FIX for addUser ---
  // Now returns the generated Firestore document ID
  Future<String> addUser(NewUser newUser) async {
    // Let Firestore auto-generate the document ID using .add()
    // It's crucial that newUser.userId holds the Firebase Auth UID.
    // The newUser.docId passed into this method can (and should be) empty.
    final docRef = await newUserCollection.add(newUser.toMap());
    // Return the auto-generated Firestore Document ID
    return docRef.id;
  }

  // --- Corrected getUserStream (already good, just including for completeness) ---
  Stream<NewUser?> getUserStream(String userInternalId) { // Renamed parameter for clarity
    if (userInternalId.isEmpty) {
      print('Warning: getUserStream called with empty userInternalId.');
      return Stream.value(null);
    }
    // Query where the 'userId' field in the document matches the provided userInternalId
    return newUserCollection
        .where('userId', isEqualTo: userInternalId)
        .limit(1) // Assuming 'userId' field is unique for each user
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        print('User document for internal userId $userInternalId does not exist.');
        return null; // No document found with that 'userId' field
      }
      // Get the first (and hopefully only) document
      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id; // IMPORTANT: Add the actual Firestore Document ID to the map
      return NewUser.fromMap(data); // Use your existing fromMap factory
    })
        .handleError((e) {
      print('Error in getUserStream for internal userId $userInternalId: $e');
      return null;
    });
  }

  // --- Corrected getUser (already good, just including for completeness) ---
  Future<NewUser?> getUser(String userInternalId) async { // Renamed parameter for clarity
    try {
      if (userInternalId.isEmpty) {
        return null;
      }
      final querySnapshot = await newUserCollection
          .where('userId', isEqualTo: userInternalId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final userData = doc.data() as Map<String, dynamic>;
        userData['docId'] = doc.id; // Include the actual Firestore Document ID
        return NewUser.fromMap(userData);
      }
      return null; // User not found
    } catch (e) {
      print('Error getting user (Future) for internal userId $userInternalId: $e');
      return null;
    }
  }

  // --- Consistency Fix: hasUserProfile also queries by the 'userId' field ---
  Future<bool> hasUserProfile(String userInternalId) async {
    try {
      if (userInternalId.isEmpty) {
        return false;
      }
      final querySnapshot = await newUserCollection
          .where('userId', isEqualTo: userInternalId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user profile existence for $userInternalId: $e');
      return false;
    }
  }

  // --- FIX for updateUser: Ensure newUser.docId is valid ---
  Future<void> updateUser(NewUser newUser) {
    if (newUser.docId.isEmpty) {
      // This should ideally not happen if addUser correctly assigns docId
      // and getUser correctly retrieves it. Log an error or throw.
      throw ArgumentError('Cannot update user: NewUser.docId is empty.');
    }
    // Now newUser.docId should contain the actual Firestore Document ID
    return newUserCollection.doc(newUser.docId).set(newUser.toMap(), SetOptions(merge: true));
  }

  // --- FIX for deleteUser: Ensure newUser.docId is valid ---
  Future<void> deleteUser(NewUser newUser) {
    if (newUser.docId.isEmpty) {
      throw ArgumentError('Cannot delete user: NewUser.docId is empty.');
    }
    return newUserCollection.doc(newUser.docId).delete();
  }
}