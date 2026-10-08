package com.example.billing_app

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

/**
 * Barcode scanners in "SPP" mode: a Bluetooth serial link. The scanner
 * sends each barcode followed by Enter (CR or LF). Also plays the short
 * beep of an accepted scan.
 */
class SppScanner {
    private val main = Handler(Looper.getMainLooper())
    private var events: EventChannel.EventSink? = null
    private var tone: ToneGenerator? = null
    private lateinit var context: Context

    @Volatile
    private var socket: BluetoothSocket? = null

    fun attach(context: Context, engine: FlutterEngine) {
        this.context = context.applicationContext
        val messenger = engine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "gestion_boutique/scanner").setMethodCallHandler { call, result ->
            when (call.method) {
                "bondedDevices" -> result.success(bonded())
                "connect" -> connect(call.argument<String>("address") ?: "", result)
                "disconnect" -> {
                    disconnect()
                    result.success(null)
                }
                "beep" -> {
                    beep()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, "gestion_boutique/scanner/events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    events = sink
                }

                override fun onCancel(arguments: Any?) {
                    events = null
                }
            })
    }

    private fun adapter(): BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    @SuppressLint("MissingPermission")
    private fun bonded(): List<Map<String, String>> = try {
        adapter()?.bondedDevices?.map {
            mapOf("name" to (it.name ?: it.address), "address" to it.address)
        } ?: emptyList()
    } catch (e: SecurityException) {
        emptyList()
    }

    @SuppressLint("MissingPermission")
    private fun connect(address: String, result: MethodChannel.Result) {
        disconnect()
        Thread {
            try {
                val adapter = adapter() ?: throw IllegalStateException("No Bluetooth")
                adapter.cancelDiscovery()
                val s = adapter.getRemoteDevice(address).createRfcommSocketToServiceRecord(SPP)
                s.connect()
                socket = s
                main.post { result.success(true) }
                read(s)
            } catch (e: Exception) {
                main.post { result.success(false) }
            }
        }.start()
    }

    /** Reads barcodes until the link breaks. */
    private fun read(s: BluetoothSocket) {
        val code = StringBuilder()
        fun flush() {
            if (code.isEmpty()) return
            val text = code.toString()
            code.setLength(0)
            main.post { events?.success(mapOf("code" to text)) }
        }
        try {
            val input = s.inputStream
            val bytes = ByteArray(256)
            while (true) {
                val count = input.read(bytes)
                if (count < 0) break
                for (i in 0 until count) {
                    val c = (bytes[i].toInt() and 0xff).toChar()
                    if (c == '\r' || c == '\n' || c == '\t') flush() else if (c >= ' ') code.append(c)
                }
                // Some scanners send no Enter: a short silence ends the barcode.
                if (code.isNotEmpty() && input.available() == 0) {
                    Thread.sleep(120)
                    if (input.available() == 0) flush()
                }
            }
        } catch (e: Exception) {
            // Link lost: reported below.
        }
        if (socket === s) {
            socket = null
            main.post { events?.success(mapOf("disconnected" to true)) }
        }
    }

    fun disconnect() {
        val s = socket
        socket = null
        try {
            s?.close()
        } catch (e: Exception) {
            // Already closed.
        }
    }

    private fun beep() {
        try {
            if (tone == null) tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 80)
            tone?.startTone(ToneGenerator.TONE_PROP_BEEP, 120)
        } catch (e: Exception) {
            // No sound available.
        }
    }

    companion object {
        /** The standard "serial port" Bluetooth service. */
        val SPP: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    }
}
