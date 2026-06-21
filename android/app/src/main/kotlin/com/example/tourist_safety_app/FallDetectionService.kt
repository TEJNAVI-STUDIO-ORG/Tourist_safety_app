package com.example.tourist_safety_app

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.*
import android.os.*
import androidx.core.app.NotificationCompat
import kotlin.math.abs
import kotlin.math.sqrt

class FallDetectionService : Service(), SensorEventListener {

    companion object {
        const val RUNNING_CHANNEL_ID  = "fall_monitor_channel"
        const val ALERT_CHANNEL_ID    = "fall_alert_channel"
        const val MONITOR_NOTIF_ID    = 1001
        const val ALERT_NOTIF_ID      = 1002
        const val ACTION_SAFE         = "com.example.tourist_safety_app.FALL_SAFE"
        const val ACTION_FALL_EVENT   = "com.example.tourist_safety_app.FALL_DETECTED"
        const val PREF_NAME           = "fall_prefs"
        const val KEY_PENDING         = "fall_pending"
        const val KEY_TIME            = "fall_time"
    }

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())

    // Fall state
    @Volatile private var freeFallTime: Long? = null
    @Volatile private var isProcessingFall = false
    @Volatile private var immobilityCheckActive = false
    @Volatile private var movementDuringImmobility = false

    // ─── Lifecycle ────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                MONITOR_NOTIF_ID,
                buildMonitorNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
            )
        } else {
            startForeground(MONITOR_NOTIF_ID, buildMonitorNotification())
        }

        // Partial wake-lock keeps CPU alive when screen is off
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "TouriSafe::FallWakeLock"
        )
        @Suppress("WakelockTimeout")
        wakeLock?.acquire(12 * 60 * 60 * 1000L) // max 12 h

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        accelerometer?.let { sensor ->
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    // START_STICKY → system restarts the service if it is killed for memory
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // ✅ ADD THIS BLOCK
        if (intent?.action == ACTION_SAFE) {
            clearFallAlert()
        }
        return START_STICKY
    }
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        wakeLock?.let { if (it.isHeld) it.release() }
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    // ─── Sensor ───────────────────────────────────────────────────────────────

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null || isProcessingFall) return
        if (event.sensor.type != Sensor.TYPE_ACCELEROMETER) return

        val x = event.values[0]; val y = event.values[1]; val z = event.values[2]
        val magnitude = sqrt(x * x + y * y + z * z)

        // Step 1 — free-fall window (near-zero g)
        if (magnitude < 2.0f) freeFallTime = System.currentTimeMillis()

        // Step 2 — high-impact spike within 1.5 s of free-fall
        val ff = freeFallTime
        if (ff != null && magnitude > 33f && (System.currentTimeMillis() - ff) < 1500) {
            isProcessingFall = true
            freeFallTime = null
            startImmobilityCheck()
        }

        // Track movement during 4-second immobility window
        if (immobilityCheckActive && abs(magnitude - 9.8f) > 3f) {
            movementDuringImmobility = true
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    // ─── Fall algorithm ───────────────────────────────────────────────────────

    private fun startImmobilityCheck() {
        immobilityCheckActive = true
        movementDuringImmobility = false
        handler.postDelayed({
            immobilityCheckActive = false
            if (movementDuringImmobility) resetState() else onFallConfirmed()
        }, 4000)
    }

    private fun onFallConfirmed() {
        // Persist so Flutter can pick it up on next cold-start
        getSharedPreferences(PREF_NAME, MODE_PRIVATE).edit()
            .putBoolean(KEY_PENDING, true)
            .putLong(KEY_TIME, System.currentTimeMillis())
            .apply()

        // Notify MainActivity (if alive) so it can call Flutter immediately
        sendBroadcast(Intent(ACTION_FALL_EVENT).apply { `package` = packageName })

        // High-priority notification (works even when app is killed)
        showFallAlert()
    }

    private fun showFallAlert() {
        val safePi = PendingIntent.getBroadcast(
            this, 0,
            Intent(this, FallActionReceiver::class.java).apply {
                action = ACTION_SAFE; `package` = packageName
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val openPi = PendingIntent.getActivity(
            this, 1,
            (packageManager.getLaunchIntentForPackage(packageName) ?: Intent()).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("from_fall", true)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notif = NotificationCompat.Builder(this, ALERT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("⚠️ Possible Fall Detected")
            .setContentText("Tap 'I AM SAFE' or SOS will be sent automatically")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("A possible fall was detected. If you're okay tap 'I AM SAFE' to cancel the alert."))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(false)
            .setOngoing(true)
            .setFullScreenIntent(openPi, true)
            .setContentIntent(openPi)
            .addAction(0, "✅  I AM SAFE", safePi)
            .build()

        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .notify(ALERT_NOTIF_ID, notif)
    }

    fun clearFallAlert() {
        resetState()
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(ALERT_NOTIF_ID)
    }

    private fun resetState() {
        isProcessingFall = false; freeFallTime = null
        movementDuringImmobility = false; immobilityCheckActive = false
        getSharedPreferences(PREF_NAME, MODE_PRIVATE).edit()
            .putBoolean(KEY_PENDING, false).apply()
    }

    // ─── Notifications ────────────────────────────────────────────────────────

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(
            NotificationChannel(RUNNING_CHANNEL_ID, "Fall Monitor", NotificationManager.IMPORTANCE_MIN)
                .apply { description = "Background fall detection"; setShowBadge(false) }
        )
        nm.createNotificationChannel(
            NotificationChannel(ALERT_CHANNEL_ID, "Fall Alerts", NotificationManager.IMPORTANCE_HIGH)
                .apply {
                    description = "Alerts when a fall is detected"
                    enableVibration(true); enableLights(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
        )
    }



    private fun buildMonitorNotification(): Notification {
    // Ensure channel exists before building notification
    createNotificationChannels()
    return NotificationCompat.Builder(this, RUNNING_CHANNEL_ID)
        .setSmallIcon(android.R.drawable.ic_menu_mylocation)
        .setContentTitle("TouriSafe")
        .setContentText("Fall detection active")
        .setPriority(NotificationCompat.PRIORITY_MIN)
        .setOngoing(true)
        .build()
        }
}
