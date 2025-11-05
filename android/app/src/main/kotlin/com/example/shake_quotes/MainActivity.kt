package com.example.shake_quotes

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt


class MainActivity : FlutterActivity(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var linearAccelerationSensor: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null
    private var lastShakeTime: Long = 0L
    private val SHAKE_THRESHOLD = 2.7f
    private val SHAKE_DEBOUNCE_TIME = 800L
    private var isListening = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        linearAccelerationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "shake_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startShakeDetection()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stopShakeDetection()
                }
            }
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "shake_methods"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startShakeDetection" -> {
                    startShakeDetection()
                    result.success(true)
                }

                "stopShakeDetection" -> {
                    stopShakeDetection()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startShakeDetection() {
        if (!isListening && linearAccelerationSensor != null) {
            sensorManager.registerListener(
                this,
                linearAccelerationSensor,
                SensorManager.SENSOR_DELAY_GAME
            )
            isListening = true
        }
    }

    private fun stopShakeDetection() {
        if (isListening) {
            sensorManager.unregisterListener(this)
            isListening = false
        }
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_LINEAR_ACCELERATION) {
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            val magnitude = sqrt((x * x + y * y + z * z).toDouble()).toFloat()

            if (magnitude > SHAKE_THRESHOLD) {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastShakeTime > SHAKE_DEBOUNCE_TIME) {
                    lastShakeTime = currentTime
                    eventSink?.success("shake_detected")
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (eventSink != null) {
            startShakeDetection()
        }
    }

    override fun onPause() {
        super.onPause()
        stopShakeDetection()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopShakeDetection()
    }
}
