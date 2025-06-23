import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_lab/model/Internship.dart';

class InternshipsRepository{
  late CollectionReference internshipsCollection;
  InternshipsRepository(){
    internshipsCollection=FirebaseFirestore.instance.collection('internships');
  }
  Future<void> addInternship(Internship internship){
    var doc=internshipsCollection.doc();
    internship.id=doc.id;
    return doc.set(internship.toMap());
  }

  Future<void> updateInternship(Internship internship){
    return internshipsCollection.doc(internship.id).set(internship.toMap());
  }
  Future<void> deleteInternship(Internship internship){
    return internshipsCollection.doc(internship.id).delete();
  }

  Stream<List<Internship>> loadAllInternships(){
    return internshipsCollection.snapshots().map(
          (snapshot) {
        return convertToInternships(snapshot);
      },);
  }
  Future<List<Internship>> loadAllInternshipsOnce() async {
    var snapshot = await internshipsCollection.get();
    return convertToInternships(snapshot);
  }

  List<Internship> convertToInternships(QuerySnapshot snapshot) {
    List<Internship> internships = [];
    for (var snap in snapshot.docs) {
      // Manually add the ID to the map before passing to fromMap
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      data['id'] = snap.id; // Add the document ID
      internships.add(Internship.fromMap(data));
    }
    return internships;
  }

  Future<Internship?> getInternshipById(String internshipId) async {
    try {
      DocumentSnapshot doc = await internshipsCollection.doc(internshipId).get();
      if (doc.exists && doc.data() != null) { // Added null check for doc.data()
        // --- MODIFIED LINES ---
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID
        return Internship.fromMap(data); // Use the modified map
      }
      return null;
    } catch (e) {
      print('Error getting Internship by ID $internshipId: $e');
      return null;
    }
  }

  Stream<Internship?> getinternshipstreamById(String internshipId) {
    return internshipsCollection.doc(internshipId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        // --- MODIFIED LINES ---
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID
        return Internship.fromMap(data); // Use the modified map
      }
      return null; // Internship might be deleted
    }).handleError((e) {
      print('Error streaming Internship by ID $internshipId: $e');
      return null; // Handle error gracefully in the stream
    });
  }

}