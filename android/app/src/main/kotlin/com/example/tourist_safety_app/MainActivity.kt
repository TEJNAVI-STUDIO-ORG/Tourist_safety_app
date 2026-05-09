package com.example.tourist_safety_app

import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendSMS") {

                val numbers =
                    call.argument<List<String>>("numbers")

                val message =
                    call.argument<String>("message")

                if (numbers != null && message != null) {

                    try {

                        val smsManager =
                            SmsManager.getDefault()

                        for (number in numbers) {

                            smsManager.sendTextMessage(
                                number,
                                null,
                                message,
                                null,
                                null
                            )
                        }

                        result.success("SMS Sent")

                    } catch (e: Exception) {

                        result.error(
                            "SMS_ERROR",
                            e.message,
                            null
                        )
                    }

                } else {

                    result.error(
                        "INVALID_ARGUMENTS",
                        "Missing numbers or message",
                        null
                    )
                }

            } else {

                result.notImplemented()
            }
        }
    }
}