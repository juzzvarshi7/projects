import 'package:cloud_firestore/cloud_firestore.dart';

class AudioMessageModel {
  final String id;
  final String appointmentId;
  final String senderId;
  final String audioUrl;
  final String? transcription;
  final int durationSeconds;
  final String format;
  final int fileSizeBytes;
  final DateTime createdAt;
  final bool isProcessed;
  final Map<String, dynamic>? metadata;

  AudioMessageModel({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.audioUrl,
    this.transcription,
    required this.durationSeconds,
    this.format = 'mp3',
    required this.fileSizeBytes,
    required this.createdAt,
    this.isProcessed = false,
    this.metadata,
  });

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '${fileSizeBytes}B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  factory AudioMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AudioMessageModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      senderId: data['senderId'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      transcription: data['transcription'],
      durationSeconds: data['durationSeconds'] ?? 0,
      format: data['format'] ?? 'mp3',
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isProcessed: data['isProcessed'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'senderId': senderId,
      'audioUrl': audioUrl,
      'transcription': transcription,
      'durationSeconds': durationSeconds,
      'format': format,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProcessed': isProcessed,
      'metadata': metadata,
    };
  }
}