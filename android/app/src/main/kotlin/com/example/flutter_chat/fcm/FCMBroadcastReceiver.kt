package com.example.flutter_chat.fcm

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.content.Context
import android.content.Intent
import android.util.Log
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

/**
 * FCMBroadcastReceiver handles Firebase Cloud Messaging when app is not running.
 * 
 * When app is not started, Firebase Messaging Service starts this receiver
 * to handle call:end events immediately without waiting for full app initialization.
 * 
 * Flow: BroadcastReceiver → OkHttp → POST /calls/end
 */
class FCMBroadcastReceiver : FirebaseMessagingService() {
    companion object {
        private const val TAG = "FCMBroadcastReceiver"
        private const val API_BASE_URL = "https://api.squad.id.vn"
        private const val PREF_NAME = "FlutterSharedPreferences"
        private const val TOKEN_KEY = "flutter.auth_token"
        private const val TIMEOUT_SECONDS = 10L
    }

    override fun onMessageReceived(message: RemoteMessage) {
        dumpPrefs(applicationContext)
        Log.d(TAG, "FCM received: ${message.data}")

        val data = message.data

        val type = (
                data["type"]
                    ?: data["notification_type"]
                    ?: data["CALL_CANCELLED"]
                    ?: ""
                ).toString().lowercase().trim()

        Log.d(TAG, "FCM type: $type")

        // Check if incoming call
        if (isIncomingCallEvent(type)) {
            Log.d(TAG, "incoming call event detected")
            handleIncomingCall(applicationContext, data)
            return
        }

        // Check if call end event
        if (isCallEndEvent(type)) {
            Log.d(TAG, "call end event detected")
            val callId = (
                    data["callId"]
                        ?: data["call_id"]
                        ?: ""
                    ).trim()

            if (callId.isEmpty()) {
                Log.w(TAG, "missing callId")
                return
            }

            val token = getAccessToken(applicationContext)
            if (token.isEmpty()) {
                Log.w(TAG, "missing token")
                return
            }

            Thread {
                endCall(callId, token)
            }.start()
        }
    }

    /**
     * Handle incoming call: show call UI via CustomCallService
     */
    private fun handleIncomingCall(context: Context, data: Map<String, String>) {
        val callId = (data["callId"] ?: data["call_id"] ?: "").toString().trim()
        if (callId.isEmpty()) {
            Log.w(TAG, "handleIncomingCall: missing callId")
            return
        }

        Log.d(TAG, "handleIncomingCall: showing call UI for callId=$callId")
        
        // Show call UI via CustomCallService
        showIncomingCallUI(context, callId, data)
    }

    /**
     * Show incoming call UI using Intent
     */
    private fun showIncomingCallUI(context: Context, callId: String, data: Map<String, String>) {
        try {
            Log.d(TAG, "showIncomingCallUI: launching CustomCallService for callId=$callId")
            
            val intent = android.content.Intent(
                context,
                CustomCallService::class.java
            ).apply {
                action = "com.example.flutter_chat.INCOMING_CALL"
                putExtra("callId", callId)
                putExtra("callerName", data["callerName"] ?: data["caller_name"] ?: "Incoming Call")
                putExtra("callerAvatar", data["callerAvatar"] ?: data["caller_avatar"] ?: "")
            }

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }

            Log.d(TAG, "showIncomingCallUI: service started for callId=$callId")
        } catch (e: Exception) {
            Log.e(TAG, "showIncomingCallUI: error", e)
        }
    }

    private fun handleFCMMessage(context: Context, intent: Intent) {
        val extras = intent.extras ?: run {
            Log.w(TAG, "handleFCMMessage: no extras found")
            return
        }

        val data = extractDataMap(extras)
        Log.d(TAG, "handleFCMMessage: data=$data")

        // Check if this is a call:end or call:ended event
        val type = (data["type"] ?: data["CALL_CANCELLED"] ?: "").toString()
        if (!isCallEndEvent(type)) {
            Log.d(TAG, "handleFCMMessage: not a call end event, type=$type")
            return
        }

        val callId = (data["callId"] ?: data["call_id"] ?: "").toString().trim()
        if (callId.isEmpty()) {
            Log.w(TAG, "handleFCMMessage: missing callId in payload")
            return
        }

        val token = getAccessToken(context)
        if (token.isEmpty()) {
            Log.w(TAG, "handleFCMMessage: no access token available, cannot send end call request")
            return
        }

        // Send POST /calls/:callId/end asynchronously
        Thread {
            try {
                endCall(callId, token)
            } catch (e: Exception) {
                Log.e(TAG, "handleFCMMessage: error ending call", e)
            }
        }.start()
    }

    /**
     * Extract all data from Intent extras into a Map<String, String>
     */
    private fun extractDataMap(extras: android.os.Bundle): Map<String, String> {
        val data = mutableMapOf<String, String>()
        for (key in extras.keySet()) {
            val value = extras.get(key)
            if (value != null) {
                data[key] = value.toString()
            }
        }
        return data
    }

    private fun dumpPrefs(context: Context) {
        try {
            Log.d(TAG, "dumpPrefs start")

            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            Log.d(TAG, "prefs size=${prefs.all.size}")

            for ((k, v) in prefs.all) {
                Log.d(TAG, "PREF: $k = $v")
            }

            Log.d(TAG, "dumpPrefs end")
        } catch (e: Exception) {
            Log.e(TAG, "dumpPrefs error", e)
        }
    }

    /**
     * Check if notification type indicates an incoming call event
     */
    private fun isIncomingCallEvent(type: String): Boolean {
        return type in listOf(
            "call_incoming",
            "incoming_call",
            "call:incoming",
            "incoming",
            "ringing",
            "call:ringing"
        )
    }

    /**
     * Check if notification type indicates a call end event
     */
    private fun isCallEndEvent(type: String): Boolean {
        return type in listOf(
            "call_end",
            "call_ended",
            "call:end",
            "call:ended",
            "CALL_CANCELLED",
            "end"
        )
    }

    /**
     * Get access token from SharedPreferences
     */
    private fun getAccessToken(context: Context): String {
        return try {
            val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            prefs.getString(TOKEN_KEY, "") ?: ""
        } catch (e: Exception) {
            Log.e(TAG, "getAccessToken: error reading token", e)
            ""
        }
    }

    /**
     * Send POST /calls/:callId/end with OkHttp
     */
    private fun endCall(callId: String, token: String) {
        val client = OkHttpClient.Builder()
            .connectTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .readTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .writeTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .build()

        try {
            val url = "$API_BASE_URL/calls/$callId/end"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $token")
                .post(okhttp3.RequestBody.create(null, ByteArray(0))) // Empty body
                .build()

            Log.d(TAG, "endCall: sending POST $url")
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                Log.d(TAG, "endCall: success status=${response.code}")
            } else {
                Log.w(TAG, "endCall: failed status=${response.code} message=${response.message}")
            }
            response.close()
        } catch (e: Exception) {
            Log.e(TAG, "endCall: error", e)
        } finally {
            client.dispatcher.executorService.shutdown()
        }
    }
}
