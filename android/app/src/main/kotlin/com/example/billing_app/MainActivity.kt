package com.example.billing_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val scanner = SppScanner()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        scanner.attach(this, flutterEngine)
    }

    override fun onDestroy() {
        scanner.disconnect()
        super.onDestroy()
    }
}
