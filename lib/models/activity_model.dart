import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String userId;
  final String activityType;
  final DateTime date;
  int durationMinutes;
  final String? notes;
  final bool isManual;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.date,
    required this.durationMinutes,
    this.notes,
    required this.isManual,
    required this.status,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final startTimeData = data['startTime'] as Timestamp?;
    final endTimeData = data['endTime'] as Timestamp?;
    final dateData = data['date'] as Timestamp?;
    final createdAtData = data['createdAt'] as Timestamp?;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] as String,
      activityType: data['activityType'] as String,
      date: dateData?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] as int? ?? 0,
      notes: data['notes'] as String?,
      isManual: data['isManual'] as bool? ?? false,
      status: data['status'] as String,
      startTime: startTimeData?.toDate(),
      endTime: endTimeData?.toDate(),
      createdAt: createdAtData?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'activityType': activityType,
      'date': date,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'isManual': isManual,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt,
    };
  }
}
