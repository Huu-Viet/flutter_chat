package com.example.flutter_chat

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	companion object {
		private const val TAG = "MainActivity"
		private const val CHANNEL = "com.example.flutter_chat/call"
	}

	private var callAcceptData: Map<String, String>? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		sanitizeIntentIfNeeded(intent)
		extractCallDataIfPresent(intent)
		super.onCreate(savedInstanceState)
	}

	override fun onNewIntent(intent: Intent) {
		sanitizeIntentIfNeeded(intent)
		extractCallDataIfPresent(intent)
		super.onNewIntent(intent)
		setIntent(intent)
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		
		// Set up method channel for call events
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getAcceptedCallData" -> {
						val data = callAcceptData
						callAcceptData = null // Clear after reading
						result.success(data)
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun extractCallDataIfPresent(intent: Intent?) {
		if (intent == null) return
		
		val callId = intent.getStringExtra("callId")
		val action = intent.getStringExtra("action")
		
		if (action == "accept_call" && !callId.isNullOrEmpty()) {
			Log.d(TAG, "extractCallDataIfPresent: accepted call, callId=$callId")
			callAcceptData = mapOf(
				"callId" to callId,
				"action" to "accept_call"
			)
		}
	}

	private fun sanitizeIntentIfNeeded(intent: Intent?) {
		if (intent == null) {
			return
		}

		if (intent.action != Intent.ACTION_VIEW) {
			intent.data = null
		}
	}
}
