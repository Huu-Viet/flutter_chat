package com.example.flutter_chat.fcm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

/**
 * CallDeclineReceiver handles decline action from call notification when app is not running.
 * When user taps "Decline" on incoming call notification → sends POST /calls/{callId}/end
 */
class CallDeclineReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "CallDeclineReceiver"
        private const val API_BASE_URL = "https://api.squad.id.vn"
        private const val PREF_NAME = "FlutterSharedPreferences"
        private const val TOKEN_KEY = "flutter.auth_token"
        private const val TIMEOUT_SECONDS = 10L
        const val EXTRA_CALL_ID = "callId"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        
        val callId = intent.getStringExtra(EXTRA_CALL_ID) ?: return
        Log.d(TAG, "onReceive: user declined call, callId=$callId")
        
        // Dismiss notification
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(callId.hashCode())
        
        // Send API call to decline
        val token = getAccessToken(context)
        if (token.isEmpty()) {
            Log.w(TAG, "onReceive: no token available")
            return
        }

        Thread {
            declineCall(callId, token)
        }.start()
    }

    private fun declineCall(callId: String, token: String) {
        try {
            val client = OkHttpClient.Builder()
                .connectTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
                .readTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
                .writeTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
                .build()

            val url = "$API_BASE_URL/calls/$callId/end"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $token")
                .post(okhttp3.RequestBody.create(null, ByteArray(0)))
                .build()

            Log.d(TAG, "declineCall: sending POST $url")
            val response = client.newCall(request).execute()

            if (response.isSuccessful) {
                Log.d(TAG, "declineCall: success status=${response.code}")
            } else {
                Log.w(TAG, "declineCall: failed status=${response.code}")
            }
            response.close()
        } catch (e: Exception) {
            Log.e(TAG, "declineCall: error", e)
        }
    }

    private fun getAccessToken(context: Context): String {
        return try {
            val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            prefs.getString(TOKEN_KEY, "") ?: ""
        } catch (e: Exception) {
            Log.e(TAG, "getAccessToken: error", e)
            ""
        }
    }
}

