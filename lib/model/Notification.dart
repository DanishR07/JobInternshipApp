import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? applicationId; // Reference to the application
  final String? positionType; // 'job' or 'internship'
  final String? positionId; // ID of the job or internship

  UserNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.applicationId,
    this.positionType,
    this.positionId,
  });

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      applicationId: map['applicationId'] as String?,
      positionType: map['positionType'] as String?,
      positionId: map['positionId'] as String?,
    );
  }

  factory UserNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserNotification.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'applicationId': applicationId,
      'positionType': positionType,
      'positionId': positionId,
    };
  }

  UserNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? applicationId,
    String? positionType,
    String? positionId,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      applicationId: applicationId ?? this.applicationId,
      positionType: positionType ?? this.positionType,
      positionId: positionId ?? this.positionId,
    );
  }
}
