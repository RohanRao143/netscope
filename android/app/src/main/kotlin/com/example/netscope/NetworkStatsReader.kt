// android/app/src/main/kotlin/com/example/netscope/NetworkStatsReader.kt

package com.example.netscope

import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.ConnectivityManager
import android.os.Process
import java.util.Calendar

object NetworkStatsReader {

    fun hasUsageAccess(context: Context): Boolean {
        val appOps =
            context.getSystemService(Context.APP_OPS_SERVICE)
                    as AppOpsManager

        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )

        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun getSnapshot(context: Context): Map<String, Any> {
        val apps = getApplicationUsage(context)

        var rx = 0L
        var tx = 0L

        apps.forEach {
            rx += (it["rxBytes"] as Number).toLong()
            tx += (it["txBytes"] as Number).toLong()
        }

        return mapOf(
            "timestamp" to System.currentTimeMillis(),
            "totalRxBytes" to rx,
            "totalTxBytes" to tx,
            "apps" to apps
        )
    }

    fun getApplicationUsage(
        context: Context
    ): List<Map<String, Any>> {

        if (!hasUsageAccess(context)) {
            return emptyList()
        }

        val manager =
            context.getSystemService(
                Context.NETWORK_STATS_SERVICE
            ) as NetworkStatsManager

        val packageManager = context.packageManager

        val now = System.currentTimeMillis()

        val calendar = Calendar.getInstance()

        calendar.add(Calendar.DAY_OF_YEAR, -1)

        val start = calendar.timeInMillis

        val applications =
            packageManager.getInstalledApplications(
                android.content.pm.PackageManager.GET_META_DATA
            )

        val result = mutableListOf<Map<String, Any>>()

        for (application in applications) {

            if (application.uid < 0) {
                continue
            }

            if ((application.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                continue
            }

            var rxBytes = 0L
            var txBytes = 0L

            rxBytes += queryUid(
                manager,
                ConnectivityManager.TYPE_WIFI,
                application.uid,
                start,
                now
            )

            txBytes += queryUidTx(
                manager,
                ConnectivityManager.TYPE_WIFI,
                application.uid,
                start,
                now
            )

            rxBytes += queryUid(
                manager,
                ConnectivityManager.TYPE_MOBILE,
                application.uid,
                start,
                now
            )

            txBytes += queryUidTx(
                manager,
                ConnectivityManager.TYPE_MOBILE,
                application.uid,
                start,
                now
            )

            if (rxBytes == 0L && txBytes == 0L) {
                continue
            }

            val label = try {
                packageManager.getApplicationLabel(
                    application
                ).toString()
            } catch (_: Exception) {
                application.packageName
            }

            result.add(
                mapOf(
                    "packageName" to application.packageName,
                    "appName" to label,
                    "uid" to application.uid,
                    "rxBytes" to rxBytes,
                    "txBytes" to txBytes
                )
            )
        }

        return result.sortedByDescending {
            (it["rxBytes"] as Number).toLong() +
                    (it["txBytes"] as Number).toLong()
        }
    }

    private fun queryUid(
        manager: NetworkStatsManager,
        type: Int,
        uid: Int,
        start: Long,
        end: Long
    ): Long {

        return try {

            val template =
                if (type == ConnectivityManager.TYPE_WIFI) {
                    android.net.NetworkTemplate.buildTemplateWifiWildcard()
                } else {
                    android.net.NetworkTemplate.buildTemplateMobileWildcard()
                }

            val stats: NetworkStats =
                manager.queryDetailsForUid(
                    template,
                    start,
                    end,
                    uid
                )

            val bucket = NetworkStats.Bucket()

            var total = 0L

            while (stats.hasNextBucket()) {
                stats.getNextBucket(bucket)
                total += bucket.rxBytes
            }

            stats.close()

            total

        } catch (_: Exception) {
            0L
        }
    }

    private fun queryUidTx(
        manager: NetworkStatsManager,
        type: Int,
        uid: Int,
        start: Long,
        end: Long
    ): Long {

        return try {

            val template =
                if (type == ConnectivityManager.TYPE_WIFI) {
                    android.net.NetworkTemplate.buildTemplateWifiWildcard()
                } else {
                    android.net.NetworkTemplate.buildTemplateMobileWildcard()
                }

            val stats: NetworkStats =
                manager.queryDetailsForUid(
                    template,
                    start,
                    end,
                    uid
                )

            val bucket = NetworkStats.Bucket()

            var total = 0L

            while (stats.hasNextBucket()) {
                stats.getNextBucket(bucket)
                total += bucket.txBytes
            }

            stats.close()

            total

        } catch (_: Exception) {
            0L
        }
    }
}