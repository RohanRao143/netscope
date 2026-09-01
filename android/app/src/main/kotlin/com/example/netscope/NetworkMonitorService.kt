// android/app/src/main/kotlin/com/example/netscope/NetworkMonitorService.kt

package com.example.netscope

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class NetworkMonitorService : Service() {

    companion object {

        private const val CHANNEL_ID =
            "netscope_network_monitor"

        private const val NOTIFICATION_ID = 1001

        fun start(context: Context) {
            val intent =
                Intent(context, NetworkMonitorService::class.java)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(
                Intent(context, NetworkMonitorService::class.java)
            )
        }
    }

    private var job: Job? = null

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()

        startForeground(
            NOTIFICATION_ID,
            createNotification()
        )

        job = CoroutineScope(Dispatchers.IO).launch {

            while (isActive) {

                val snapshot =
                    NetworkStatsReader.getSnapshot(this@NetworkMonitorService)

                NetworkEventStreamHandler.emit(snapshot)

                delay(5000)
            }
        }
    }

    override fun onDestroy() {
        job?.cancel()
        job = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {

        if (Build.VERSION.SDK_INT <
            Build.VERSION_CODES.O
        ) {
            return
        }

        val manager =
            getSystemService(
                NotificationManager::class.java
            )

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Network monitoring",
            NotificationManager.IMPORTANCE_LOW
        )

        manager.createNotificationChannel(channel)
    }

    private fun createNotification(): Notification {

        val intent = Intent(
            this,
            MainActivity::class.java
        )

        val pendingIntent =
            PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE
            )

        return if (Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.O
        ) {

            Notification.Builder(
                this,
                CHANNEL_ID
            )
                .setContentTitle("NetScope")
                .setContentText(
                    "Network usage monitoring is active"
                )
                .setSmallIcon(
                    android.R.drawable.stat_sys_download
                )
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()

        } else {

            Notification.Builder(this)
                .setContentTitle("NetScope")
                .setContentText(
                    "Network usage monitoring is active"
                )
                .setSmallIcon(
                    android.R.drawable.stat_sys_download
                )
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }
}