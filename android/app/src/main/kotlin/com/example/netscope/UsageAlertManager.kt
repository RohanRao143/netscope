package com.alphaagentssuite.netscope

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object UsageAlertManager {
    private const val CHANNEL="netscope_usage_alerts"
    private const val THRESHOLD=100L*1024L*1024L
    fun check(context:Context, apps:List<Map<String,Any>>){
        val prefs=context.getSharedPreferences("netscope_alerts",Context.MODE_PRIVATE)
        val day=java.text.SimpleDateFormat("yyyyMMdd",java.util.Locale.US).format(java.util.Date())
        val manager=context.getSystemService(NotificationManager::class.java)
        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O) manager.createNotificationChannel(NotificationChannel(CHANNEL,"Usage alerts",NotificationManager.IMPORTANCE_DEFAULT))
        apps.forEach{app->
            val pkg=app["packageName"]?.toString()?:return@forEach
            val total=(app["rxBytes"] as Number).toLong()+(app["txBytes"] as Number).toLong()
            val bucket=total/THRESHOLD
            val key="$day:$pkg"
            val sent=prefs.getInt(key,0)
            if(bucket>sent){
                val count=bucket.toInt()
                prefs.edit().putInt(key,count).apply()
                val intent=Intent(context,MainActivity::class.java)
                val pi=PendingIntent.getActivity(context,app["uid"] as Int,intent,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                manager.notify(kotlin.math.abs(app["uid"] as Int)+4000, android.app.Notification.Builder(context,CHANNEL).setSmallIcon(android.R.drawable.stat_sys_download).setContentTitle("NetScope usage alert").setContentText("${app["appName"]} has reached ${bucket*100} MB of recorded usage today.").setContentIntent(pi).setAutoCancel(true).build())
            }
        }
    }
    fun count(context:Context, packageName:String, days:Int):Int{
        val prefs=context.getSharedPreferences("netscope_alerts",Context.MODE_PRIVATE);var total=0
        for(i in 0 until days){val date=java.text.SimpleDateFormat("yyyyMMdd",java.util.Locale.US).format(java.util.Date(System.currentTimeMillis()-i*86400000L));total+=prefs.getInt("$date:$packageName",0)}
        return total
    }
}
