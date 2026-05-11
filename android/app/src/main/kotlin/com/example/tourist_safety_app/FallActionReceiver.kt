package com.example.tourist_safety_app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Handles the "I AM SAFE" action from the fall-detected notification.
 * Works even when the app is completely killed.
 */
class FallActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != FallDetectionService.ACTION_SAFE) return

        // Dismiss the fall-alert notification
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(FallDetectionService.ALERT_NOTIF_ID)

        // Clear the pending flag so Flutter doesn't re-show the dialog on next open
        context.getSharedPreferences(FallDetectionService.PREF_NAME, Context.MODE_PRIVATE)
            .edit().putBoolean(FallDetectionService.KEY_PENDING, false).apply()
    }
}
