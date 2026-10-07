import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/audio_message_model.dart';
import '../config/app_config.dart';
import '../utils/exceptions.dart';

class AudioService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterTts _flutterTts = FlutterTts();
  
  static bool _isRecording = false;
  static String? _currentRecordingPath;
  static DateTime? _recordingStartTime;

  // Initialize audio service
  static Future<void> initialize() async {
    await _initializeTTS();
    await _requestPermissions();
  }

  // Initialize Text-to-Speech
  static Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Request audio permissions
  static Future<bool> _requestPermissions() async {
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    
    return microphoneStatus.isGranted && storageStatus.isGranted;
  }

  // Start recording audio
  static Future<bool> startRecording() async {
    try {
      if (_isRecording) {
        throw AudioException('Recording is already in progress');
      }

      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        throw AudioException('Microphone permission is required for recording');
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${tempDir.path}/$fileName';
      
      // Start recording using platform channel
      await _startPlatformRecording(_currentRecordingPath!);
      
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      
      return true;
    } catch (e) {
      throw AudioException('Failed to start recording: ${e.toString()}');
    }
  }

  // Stop recording audio
  static Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        throw AudioException('No recording in progress');
      }

      await _stopPlatformRecording();
      
      _isRecording = false;
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      
      // Check recording duration
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        if (duration.inMinutes > AppConfig.maxAudioDurationMinutes) {
          // Delete the file if it's too long
          if (recordingPath != null && File(recordingPath).existsSync()) {
            await File(recordingPath).delete();
          }
          throw AudioException('Recording exceeds maximum duration of ${AppConfig.maxAudioDurationMinutes} minutes');
        }
      }
      
      _recordingStartTime = null;
      return recordingPath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      throw AudioException('Failed to stop recording: ${e.toString()}');
    }
  }

  // Platform-specific recording start
  static Future<void> _startPlatformRecording(String path) async {
    const platform = MethodChannel('audio_recorder');
    try {
      await platform.invokeMethod('startRecording', {'path': path});
    } on PlatformException catch (e) {
      throw AudioException('Platform recording error: ${e.message}');
    }
  }

  // Platform-specific recording stop
  static Future<void> _stopPlatformRecording() async {
    const platform = MethodChannel('audio_recorder');
    try {
      await platform.invokeMethod('stopRecording');
    } on PlatformException catch (e) {
      throw AudioException('Platform recording error: ${e.message}');
    }
  }

  // Upload audio message
  static Future<AudioMessageModel> uploadAudioMessage({
    required String appointmentId,
    required String senderId,
    required String audioPath,
  }) async {
    try {
      final file = File(audioPath);
      if (!file.existsSync()) {
        throw AudioException('Audio file not found');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        throw AudioException('Audio file is too large (max 10MB)');
      }

      // Generate unique filename
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storageRef = _storage.ref().child('audio_messages/$appointmentId/$fileName');
      
      // Upload file
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Get audio duration (simplified - in real implementation, use audio analysis)
      final durationSeconds = await _getAudioDuration(audioPath);
      
      // Create audio message model
      final audioMessage = AudioMessageModel(
        id: '', // Will be set by Firestore
        appointmentId: appointmentId,
        senderId: senderId,
        audioUrl: downloadUrl,
        durationSeconds: durationSeconds,
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      final docRef = await _firestore.collection('audio_messages').add(audioMessage.toFirestore());
      final doc = await docRef.get();
      
      // Update appointment with audio message reference
      await _firestore.collection('appointments').doc(appointmentId).update({
        'audioMessageUrl': downloadUrl,
        'audioMessageId': docRef.id,
        'updatedAt': Timestamp.now(),
      });
      
      // Clean up local file
      await file.delete();
      
      return AudioMessageModel.fromFirestore(doc);
    } catch (e) {
      throw AudioException('Failed to upload audio message: ${e.toString()}');
    }
  }

  // Get audio duration (simplified implementation)
  static Future<int> _getAudioDuration(String audioPath) async {
    // In a real implementation, you would use a proper audio analysis library
    // For now, return a default duration based on file size
    final file = File(audioPath);
    final fileSize = await file.length();
    // Rough estimate: 1MB ≈ 60 seconds for typical voice recording
    return (fileSize / (1024 * 1024) * 60).round();
  }

  // Generate text-to-speech audio
  static Future<String?> generateTextToSpeech(String text) async {
    try {
      if (text.isEmpty) {
        throw AudioException('Text cannot be empty');
      }

      // Use Google Cloud TTS API
      final audioUrl = await _generateTTSWithGoogleCloud(text);
      return audioUrl;
    } catch (e) {
      // Fallback to local TTS
      try {
        await _flutterTts.speak(text);
        return null; // Local TTS doesn't return URL
      } catch (fallbackError) {
        throw AudioException('Failed to generate text-to-speech: ${e.toString()}');
      }
    }
  }

  // Generate TTS with Google Cloud
  static Future<String> _generateTTSWithGoogleCloud(String text) async {
    try {
      final url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=${AppConfig.gcloudApiKey}';
      
      final requestBody = {
        'input': {'text': text},
        'voice': {
          'languageCode': 'en-US',
          'name': 'en-US-Wavenet-D',
          'ssmlGender': 'NEUTRAL'
        },
        'audioConfig': {
          'audioEncoding': 'MP3',
          'speakingRate': 1.0,
          'pitch': 0.0,
          'volumeGainDb': 0.0
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final audioContent = responseData['audioContent'];
        
        // Save audio to Firebase Storage
        final audioBytes = base64Decode(audioContent);
        final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final storageRef = _storage.ref().child('tts_audio/$fileName');
        
        await storageRef.putData(audioBytes);
        return await storageRef.getDownloadURL();
      } else {
        throw AudioException('Google Cloud TTS API error: ${response.statusCode}');
      }
    } catch (e) {
      throw AudioException('Failed to generate TTS with Google Cloud: ${e.toString()}');
    }
  }

  // Get audio message by ID
  static Future<AudioMessageModel?> getAudioMessage(String audioMessageId) async {
    try {
      final doc = await _firestore.collection('audio_messages').doc(audioMessageId).get();
      if (doc.exists) {
        return AudioMessageModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw AudioException('Failed to get audio message: ${e.toString()}');
    }
  }

  // Get audio messages for appointment
  static Future<List<AudioMessageModel>> getAppointmentAudioMessages(String appointmentId) async {
    try {
      final snapshot = await _firestore
          .collection('audio_messages')
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => AudioMessageModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw AudioException('Failed to get appointment audio messages: ${e.toString()}');
    }
  }

  // Delete audio message
  static Future<void> deleteAudioMessage(String audioMessageId) async {
    try {
      final audioMessage = await getAudioMessage(audioMessageId);
      if (audioMessage != null) {
        // Delete from Storage
        final storageRef = _storage.refFromURL(audioMessage.audioUrl);
        await storageRef.delete();
        
        // Delete from Firestore
        await _firestore.collection('audio_messages').doc(audioMessageId).delete();
      }
    } catch (e) {
      throw AudioException('Failed to delete audio message: ${e.toString()}');
    }
  }

  // Check if currently recording
  static bool get isRecording => _isRecording;
  
  // Get current recording duration
  static Duration? get currentRecordingDuration {
    if (_recordingStartTime != null && _isRecording) {
      return DateTime.now().difference(_recordingStartTime!);
    }
    return null;
  }

  // Stop TTS
  static Future<void> stopTTS() async {
    await _flutterTts.stop();
  }

  // Set TTS settings
  static Future<void> setTTSSettings({
    double? speechRate,
    double? volume,
    double? pitch,
    String? language,
  }) async {
    if (speechRate != null) await _flutterTts.setSpeechRate(speechRate);
    if (volume != null) await _flutterTts.setVolume(volume);
    if (pitch != null) await _flutterTts.setPitch(pitch);
    if (language != null) await _flutterTts.setLanguage(language);
  }
}