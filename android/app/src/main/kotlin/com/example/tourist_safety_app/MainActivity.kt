package com.example.tourist_safety_app

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SMS_CHANNEL  = "sms_channel"
    private val FALL_CHANNEL = "fall_detection_channel"

    private var fallMethodChannel: MethodChannel? = null

    // Receives ACTION_FALL_EVENT broadcast from FallDetectionService
    private val fallReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == FallDetectionService.ACTION_FALL_EVENT) {
                // Forward to Flutter — shows the countdown dialog
                fallMethodChannel?.invokeMethod("fallDetected", null)
            }
        }
    }

    // ─── Flutter engine setup ─────────────────────────────────────────────────

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── SMS channel ──────────────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendSMS" -> {
                        val numbers = call.argument<List<String>>("numbers")
                        val message = call.argument<String>("message")
                        if (numbers != null && message != null) {
                            sendSilentSMS(numbers, message, result)
                        } else {
                            result.error("INVALID_ARGS", "Missing numbers or message", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Fall detection channel ───────────────────────────────────────────
        fallMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, FALL_CHANNEL
        )
        fallMethodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startFallService()
                    result.success(null)
                }
                "stopService" -> {
                    stopService(Intent(this, FallDetectionService::class.java))
                    result.success(null)
                }
                "checkPendingFall" -> {
                    val prefs = getSharedPreferences(FallDetectionService.PREF_NAME, MODE_PRIVATE)
                    result.success(
                        mapOf(
                            "pending" to prefs.getBoolean(FallDetectionService.KEY_PENDING, false),
                            "time"    to prefs.getLong(FallDetectionService.KEY_TIME, 0L)
                        )
                    )
                }
                "clearFall" -> {
                    getSharedPreferences(FallDetectionService.PREF_NAME, MODE_PRIVATE)
                        .edit().putBoolean(FallDetectionService.KEY_PENDING, false).apply()
                    // Also cancel the alert notification
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE)
                            as android.app.NotificationManager
                    nm.cancel(FallDetectionService.ALERT_NOTIF_ID)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ─── Activity lifecycle ───────────────────────────────────────────────────

    override fun onResume() {
        super.onResume()
        // Register receiver for live fall events from the native service
        val filter = IntentFilter(FallDetectionService.ACTION_FALL_EVENT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(fallReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(fallReceiver, filter)
        }
    }

    override fun onPause() {
        super.onPause()
        try { unregisterReceiver(fallReceiver) } catch (_: Exception) {}
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private fun startFallService() {
        val intent = Intent(this, FallDetectionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    @SuppressLint("MissingPermission")
    private fun sendSilentSMS(
        numbers: List<String>,
        message: String,
        result: MethodChannel.Result
    ) {
        try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                applicationContext.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

            var allSent = true
            for (number in numbers) {
                // Automatically splits messages longer than 160 chars
                val parts = smsManager.divideMessage(message)
                if (parts.size == 1) {
                    smsManager.sendTextMessage(number, null, message, null, null)
                } else {
                    smsManager.sendMultipartTextMessage(number, null, parts, null, null)
                }
            }
            result.success(if (allSent) "SMS Sent" else "Partial Send")
        } catch (e: Exception) {
            result.error("SMS_ERROR", e.message, null)
        }
    }
}