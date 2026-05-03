package com.example.flutter_chat

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		sanitizeIntentIfNeeded(intent)
		super.onCreate(savedInstanceState)
	}

	override fun onNewIntent(intent: Intent) {
		sanitizeIntentIfNeeded(intent)
		super.onNewIntent(intent)
		setIntent(intent)
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
