// android/app/src/main/kotlin/com/example/netscope/MainActivity.kt

package com.alphaagentssuite.netscope

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
        private const val PACKET_EVENT_CHANNEL = "netscope/packet_events"
        private const val VPN_REQUEST = 8841
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST && resultCode == RESULT_OK) {
            startService(Intent(this, DnsPacketVpnService::class.java))
            getSharedPreferences("netscope_packet", MODE_PRIVATE).edit().putBoolean("active", true).apply()
        }
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
                "getAnalytics" -> {
                    Thread { try { val value=NetworkStatsReader.getAnalytics(this); runOnUiThread { result.success(value) } } catch(e:Exception) { runOnUiThread { result.error("ANALYTICS_ERROR",e.message,null) } } }.start()
                }
                "getAppUsageHistory" -> {
                    val packageName=call.argument<String>("packageName") ?: ""
                    val range=call.argument<String>("range") ?: "Daily"
                    Thread { try { val value=NetworkStatsReader.getApplicationUsageHistory(this,packageName,range); runOnUiThread { result.success(value) } } catch(e:Exception) { runOnUiThread { result.error("HISTORY_ERROR",e.message,null) } } }.start()
                }
                "getHostStats" -> result.success(NetworkStatsReader.getHostStats(this))
                "getUsageNotificationCount" -> { val pkg=call.argument<String>("packageName") ?: ""; val days=call.argument<Int>("days") ?: 30; result.success(UsageAlertManager.count(this,pkg,days)) }
                "setAutoStart" -> { val enabled=call.argument<Boolean>("enabled") ?: true; getSharedPreferences("netscope_settings",MODE_PRIVATE).edit().putBoolean("auto_start",enabled).apply(); result.success(null) }
                "getAutoStart" -> result.success(getSharedPreferences("netscope_settings",MODE_PRIVATE).getBoolean("auto_start",true))
                "startPacketInspection" -> {
                    val prepare = android.net.VpnService.prepare(this)
                    if (prepare != null) { startActivityForResult(prepare, VPN_REQUEST); result.success("permission_required") }
                    else { startService(Intent(this, DnsPacketVpnService::class.java)); result.success("started") }
                }
                "stopPacketInspection" -> { stopService(Intent(this, DnsPacketVpnService::class.java)); getSharedPreferences("netscope_packet",MODE_PRIVATE).edit().putBoolean("active",false).apply(); result.success(null) }
                "isPacketInspectionActive" -> result.success(getSharedPreferences("netscope_packet",MODE_PRIVATE).getBoolean("active",false))

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(
            NetworkEventStreamHandler(this)
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PACKET_EVENT_CHANNEL)
            .setStreamHandler(PacketEventStreamHandler())
    }
}