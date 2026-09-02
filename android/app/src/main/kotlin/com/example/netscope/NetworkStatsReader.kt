package com.alphaagentssuite.netscope

import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Process

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

        var totalRxBytes = 0L
        var totalTxBytes = 0L

        for (app in apps) {
            totalRxBytes +=
                (app["rxBytes"] as Number).toLong()

            totalTxBytes +=
                (app["txBytes"] as Number).toLong()
        }

        return mapOf(
            "timestamp" to System.currentTimeMillis(),
            "totalRxBytes" to totalRxBytes,
            "totalTxBytes" to totalTxBytes,
            "apps" to apps
        )
    }

    fun getApplicationUsage(
        context: Context
    ): List<Map<String, Any>> {

        if (!hasUsageAccess(context)) {
            return emptyList()
        }

        val networkStatsManager =
            context.getSystemService(
                Context.NETWORK_STATS_SERVICE
            ) as NetworkStatsManager

        val packageManager = context.packageManager

        val endTime = System.currentTimeMillis()

        /*
         * Keep the same 24-hour monitoring window used by the
         * original implementation.
         */
        val startTime =
            endTime - (24L * 60L * 60L * 1000L)

        val applications =
            packageManager.getInstalledApplications(
                android.content.pm.PackageManager.GET_META_DATA
            )

        val result =
            mutableListOf<Map<String, Any>>()

        for (application in applications) {

            val uid = application.uid

            if (uid < 0) {
                continue
            }

            /*
             * Skip the NetScope application itself.
             */
            if (application.packageName ==
                context.packageName
            ) {
                continue
            }

            /*
             * queryDetailsForUid() is available for
             * application-specific usage statistics.
             *
             * We query Wi-Fi and mobile separately.
             */
            val wifi =
                queryUid(
                    networkStatsManager,
                    ConnectivityManager.TYPE_WIFI,
                    uid,
                    startTime,
                    endTime
                )

            val mobile =
                queryUid(
                    networkStatsManager,
                    ConnectivityManager.TYPE_MOBILE,
                    uid,
                    startTime,
                    endTime
                )

            val rxBytes =
                wifi.rxBytes + mobile.rxBytes

            val txBytes =
                wifi.txBytes + mobile.txBytes

            if (rxBytes == 0L && txBytes == 0L) {
                continue
            }

            val appName =
                try {
                    packageManager
                        .getApplicationLabel(application)
                        .toString()
                } catch (_: Exception) {
                    application.packageName
                }

            result.add(
                mapOf(
                    "packageName" to application.packageName,
                    "appName" to appName,
                    "uid" to uid,
                    "rxBytes" to rxBytes,
                    "txBytes" to txBytes
                )
            )
        }

        return result.sortedByDescending { app ->

            val rx =
                (app["rxBytes"] as Number).toLong()

            val tx =
                (app["txBytes"] as Number).toLong()

            rx + tx
        }
    }

    private data class UsageResult(
        val rxBytes: Long = 0L,
        val txBytes: Long = 0L
    )

    private fun queryUid(
        manager: NetworkStatsManager,
        networkType: Int,
        uid: Int,
        startTime: Long,
        endTime: Long
    ): UsageResult {

        return try {

            /*
             * IMPORTANT:
             *
             * Do not use NetworkTemplate here.
             *
             * NetworkStatsManager.queryDetailsForUid()
             * expects the network type as an Int on the
             * Android API used by this project.
             */

            val stats =
                if (Build.VERSION.SDK_INT >=
                    Build.VERSION_CODES.M
                ) {
                    manager.queryDetailsForUid(
                        networkType,
                        null,
                        startTime,
                        endTime,
                        uid
                    )
                } else {
                    return UsageResult()
                }

            val bucket =
                NetworkStats.Bucket()

            var rxBytes = 0L
            var txBytes = 0L

            while (stats.hasNextBucket()) {

                stats.getNextBucket(bucket)

                rxBytes += bucket.rxBytes
                txBytes += bucket.txBytes
            }

            stats.close()

            UsageResult(
                rxBytes = rxBytes,
                txBytes = txBytes
            )

        } catch (_: SecurityException) {
            UsageResult()

        } catch (_: Exception) {
            UsageResult()
        }
    }
}