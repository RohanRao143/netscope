// android/app/src/main/kotlin/com/example/netscope/MainActivity.kt

package com.example.netscope

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL = "netscope/network"
        private const val EVENT_CHANNEL = "netscope/network_events"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "isSupported" -> {
                    result.success(true)
                }

                "hasUsageAccess" -> {
                    result.success(NetworkStatsReader.hasUsageAccess(this))
                }

                "requestUsageAccess" -> {
                    try {
                        val intent = Intent(
                            Settings.ACTION_USAGE_ACCESS_SETTINGS
                        )
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error(
                            "SETTINGS_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "openAppUsageSettings" -> {
                    try {
                        val intent = Intent(
                            Settings.ACTION_USAGE_ACCESS_SETTINGS
                        )
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error(
                            "SETTINGS_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "getAppUsage" -> {
                    Thread {
                        try {
                            val apps =
                                NetworkStatsReader.getApplicationUsage(this)

                            runOnUiThread {
                                result.success(apps)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "NETWORK_STATS_ERROR",
                                    e.message,
                                    null
                                )
                            }
                        }
                    }.start()
                }

                "getCurrentUsage" -> {
                    Thread {
                        try {
                            val snapshot =
                                NetworkStatsReader.getSnapshot(this)

                            runOnUiThread {
                                result.success(snapshot)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "NETWORK_STATS_ERROR",
                                    e.message,
                                    null
                                )
                            }
                        }
                    }.start()
                }

                "startMonitoring" -> {
                    NetworkMonitorService.start(this)
                    result.success(null)
                }

                "stopMonitoring" -> {
                    NetworkMonitorService.stop(this)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(
            NetworkEventStreamHandler(this)
        )
    }
}