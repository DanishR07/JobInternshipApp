import 'package:cloud_firestore/cloud_firestore.dart';

class AppliedPosition {
  String id;
  String userId;
  String positionId; // This can be jobId or internshipId
  String positionType; // 'job' or 'internship'
  DateTime appliedDate;
  String status;

  AppliedPosition({
    required this.id,
    required this.userId,
    required this.positionId,
    required this.positionType,
    required this.appliedDate,
    this.status = 'Pending',
  });

  factory AppliedPosition.fromMap(Map<String, dynamic> map) {
    return AppliedPosition(
      id: map['id'] as String,
      userId: map['userId'] as String,
      positionId: map['positionId'] as String,
      positionType: map['positionType'] as String,
      // Removed title and companyName from here
      appliedDate: (map['appliedDate'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'Pending',
    );
  }

  factory AppliedPosition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppliedPosition.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'positionId': positionId,
      'positionType': positionType,
      // Removed title and companyName from here
      'appliedDate': Timestamp.fromDate(appliedDate),
      'status': status,
    };
  }

  // --- ADD THIS copyWith METHOD ---
  AppliedPosition copyWith({
    String? id,
    String? userId,
    String? positionId,
    String? positionType,
    DateTime? appliedDate,
    String? status,
  }) {
    return AppliedPosition(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      positionId: positionId ?? this.positionId,
      positionType: positionType ?? this.positionType,
      appliedDate: appliedDate ?? this.appliedDate,
      status: status ?? this.status, // This is the field you want to update
    );
  }
}