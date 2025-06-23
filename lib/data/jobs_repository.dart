import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_lab/model/Job.dart';

class JobsRepository{
  late CollectionReference jobsCollection;
  JobsRepository(){
    jobsCollection=FirebaseFirestore.instance.collection('jobs');
  }
  Future<void> addJob(Job job){
    var doc=jobsCollection.doc();
    job.id=doc.id;
    return doc.set(job.toMap());
  }

  Future<void> updateJob(Job job){
    return jobsCollection.doc(job.id).set(job.toMap());
  }
  Future<void> deleteJob(Job job){
    return jobsCollection.doc(job.id).delete();
  }

  Stream<List<Job>> loadAllJobs(){
    return jobsCollection.snapshots().map(
          (snapshot) {
        return convertToJobs(snapshot);
      },);
  }
  Future<List<Job>> loadAllJobsOnce() async {
    var snapshot = await jobsCollection.get();
    return convertToJobs(snapshot);
  }

  List<Job> convertToJobs(QuerySnapshot snapshot) {
    List<Job> jobs = [];
    for (var snap in snapshot.docs) {
      // For QueryDocumentSnapshot in a list, data() doesn't contain ID by default.
      // We manually add it here before passing to fromMap.
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      data['id'] = snap.id; // Add the document ID
      jobs.add(Job.fromMap(data));
    }
    return jobs;
  }

  Future<Job?> getJobById(String jobId) async {
    try {
      final docSnapshot = await jobsCollection.doc(jobId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id; // Add the document ID
        return Job.fromMap(data); // Now use fromMap
      }
      return null;
    } catch (e) {
      print('Error getting job by ID $jobId: $e');
      return null;
    }
  }

  Stream<Job?> getJobStreamById(String jobId) {
    return jobsCollection.doc(jobId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID
        return Job.fromMap(data); // Now use fromMap
      }
      return null; // Job might be deleted
    }).handleError((e) {
      print('Error streaming job by ID $jobId: $e');
      return null; // Handle error gracefully in the stream
    });
  }

}