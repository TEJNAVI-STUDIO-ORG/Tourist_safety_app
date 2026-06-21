package com.example.tourist_safety_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Global Boot Receiver that ensures all safety services are started.
 * Restarts FlutterBackgroundService and FallDetectionService.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val validActions = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON"
        )
        if (intent.action !in validActions) return

        // 2. Restart Native Fall Detection Service
        val fallServiceIntent = Intent(context, FallDetectionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(fallServiceIntent)
        } else {
            context.startService(fallServiceIntent)
        }
    }
}
