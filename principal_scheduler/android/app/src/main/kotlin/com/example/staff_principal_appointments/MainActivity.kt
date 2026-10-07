package com.example.staff_principal_appointments

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaRecorder
import android.os.Build
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "audio_recorder"
    private var mediaRecorder: MediaRecorder? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        startRecording(path, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is required", null)
                    }
                }
                "stopRecording" -> {
                    stopRecording(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startRecording(path: String, result: MethodChannel.Result) {
        try {
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            
            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(path)
                
                prepare()
                start()
            }
            
            result.success(true)
        } catch (e: IOException) {
            result.error("RECORDING_ERROR", "Failed to start recording: ${e.message}", null)
        } catch (e: Exception) {
            result.error("RECORDING_ERROR", "Unexpected error: ${e.message}", null)
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            mediaRecorder = null
            result.success(true)
        } catch (e: Exception) {
            result.error("RECORDING_ERROR", "Failed to stop recording: ${e.message}", null)
        }
    }
}