package com.example.flutter_chat.fcm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.flutter_chat.MainActivity

/**
 * CustomCallService shows incoming call notification when app is not running.
 * Provides Accept/Decline actions with custom styling.
 * 
 * Flow when app is OFF:
 *   FCM → FCMBroadcastReceiver → startService(CustomCallService)
 *   → CustomCallService shows call notification
 *   → User taps Accept → launches MainActivity
 *   → User taps Decline → CallDeclineReceiver → POST /calls/end
 */
class CustomCallService : Service() {
    companion object {
        private const val TAG = "CustomCallService"
        private const val CHANNEL_ID = "call_notifications"
        private const val CHANNEL_NAME = "Call Notifications"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d(TAG, "onCreate")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: intent=${intent?.action}")
        
        if (intent?.action == "com.example.flutter_chat.INCOMING_CALL") {
            val callId = intent.getStringExtra("callId") ?: ""
            val callerName = intent.getStringExtra("callerName") ?: "Incoming Call"
            
            if (callId.isNotEmpty()) {
                showCallNotification(callId, callerName)
            }
        }
        
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_MAX
            ).apply {
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showCallNotification(callId: String, callerName: String) {
        try {
            // Intent to launch app when user taps Accept
            val acceptIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("callId", callId)
                putExtra("action", "accept_call")
            }
            val acceptPendingIntent = PendingIntent.getActivity(
                this,
                callId.hashCode(),
                acceptIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Intent for decline action
            val declineIntent = Intent(this, CallDeclineReceiver::class.java).apply {
                action = "com.example.flutter_chat.DECLINE_CALL"
                putExtra(CallDeclineReceiver.EXTRA_CALL_ID, callId)
            }
            val declinePendingIntent = PendingIntent.getBroadcast(
                this,
                callId.hashCode() + 1,
                declineIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Build notification
            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Incoming Call")
                .setContentText(callerName)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setFullScreenIntent(acceptPendingIntent, true)
                .addAction(
                    android.R.drawable.ic_menu_call,
                    "Accept",
                    acceptPendingIntent
                )
                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Decline",
                    declinePendingIntent
                )
                .setAutoCancel(true)
                .build()

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(callId.hashCode(), notification)

            Log.d(TAG, "showCallNotification: displayed for callId=$callId, callerName=$callerName")
        } catch (e: Exception) {
            Log.e(TAG, "showCallNotification: error", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}


