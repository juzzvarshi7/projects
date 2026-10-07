import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, accepted, rejected, cancelled, completed }

enum AppointmentPriority { low, medium, high, urgent }

class AppointmentModel {
  final String id;
  final String staffId;
  final String principalId;
  final String title;
  final String description;
  final DateTime scheduledDateTime;
  final int durationMinutes;
  final AppointmentStatus status;
  final AppointmentPriority priority;
  final String? location;
  final String? audioMessageUrl;
  final String? audioMessageId;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata;

  AppointmentModel({
    required this.id,
    required this.staffId,
    required this.principalId,
    required this.title,
    required this.description,
    required this.scheduledDateTime,
    this.durationMinutes = 30,
    this.status = AppointmentStatus.pending,
    this.priority = AppointmentPriority.medium,
    this.location,
    this.audioMessageUrl,
    this.audioMessageId,
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.metadata,
  });

  bool get isPending => status == AppointmentStatus.pending;
  bool get isAccepted => status == AppointmentStatus.accepted;
  bool get isRejected => status == AppointmentStatus.rejected;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get isCompleted => status == AppointmentStatus.completed;
  
  bool get hasAudioMessage => audioMessageUrl != null && audioMessageUrl!.isNotEmpty;
  
  DateTime get endDateTime => scheduledDateTime.add(Duration(minutes: durationMinutes));

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppointmentModel(
      id: doc.id,
      staffId: data['staffId'] ?? '',
      principalId: data['principalId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledDateTime: (data['scheduledDateTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 30,
      status: AppointmentStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      priority: AppointmentPriority.values.firstWhere(
        (priority) => priority.name == data['priority'],
        orElse: () => AppointmentPriority.medium,
      ),
      location: data['location'],
      audioMessageUrl: data['audioMessageUrl'],
      audioMessageId: data['audioMessageId'],
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'principalId': principalId,
      'title': title,
      'description': description,
      'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
      'durationMinutes': durationMinutes,
      'status': status.name,
      'priority': priority.name,
      'location': location,
      'audioMessageUrl': audioMessageUrl,
      'audioMessageId': audioMessageId,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'rejectionReason': rejectionReason,
      'metadata': metadata,
    };
  }

  AppointmentModel copyWith({
    String? title,
    String? description,
    DateTime? scheduledDateTime,
    int? durationMinutes,
    AppointmentStatus? status,
    AppointmentPriority? priority,
    String? location,
    String? audioMessageUrl,
    String? audioMessageId,
    List<String>? attachments,
    DateTime? updatedAt,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
  }) {
    return AppointmentModel(
      id: id,
      staffId: staffId,
      principalId: principalId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      audioMessageUrl: audioMessageUrl ?? this.audioMessageUrl,
      audioMessageId: audioMessageId ?? this.audioMessageId,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
    );
  }
}