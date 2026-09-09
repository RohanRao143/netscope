package com.alphaagentssuite.netscope

import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.net.ConnectivityManager
import android.os.Build
import android.os.Process
import android.app.usage.UsageStatsManager

object NetworkStatsReader {
    fun hasUsageAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        return appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName) == AppOpsManager.MODE_ALLOWED
    }

    fun getSnapshot(context: Context): Map<String, Any> {
        val apps = getApplicationUsage(context)
        var rx=0L; var tx=0L
        apps.forEach { rx += (it["rxBytes"] as Number).toLong(); tx += (it["txBytes"] as Number).toLong() }
        return mapOf("timestamp" to System.currentTimeMillis(),"totalRxBytes" to rx,"totalTxBytes" to tx,"apps" to apps)
    }

    fun getApplicationUsage(context: Context): List<Map<String, Any>> {
        if (!hasUsageAccess(context)) return emptyList()
        val manager=context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val pm=context.packageManager; val end=System.currentTimeMillis(); val start=end-24L*60L*60L*1000L
        val result=mutableListOf<Map<String,Any>>()
        for (app in pm.getInstalledApplications(android.content.pm.PackageManager.GET_META_DATA)) {
            if(app.uid<0 || app.packageName==context.packageName) continue
            val wifi=queryUid(manager,ConnectivityManager.TYPE_WIFI,app.uid,start,end)
            val mobile=queryUid(manager,ConnectivityManager.TYPE_MOBILE,app.uid,start,end)
            val rx=wifi.rx+mobile.rx; val tx=wifi.tx+mobile.tx
            if(rx==0L&&tx==0L) continue
            val name=try{pm.getApplicationLabel(app).toString()}catch(_:Exception){app.packageName}
            result.add(mapOf("packageName" to app.packageName,"appName" to name,"uid" to app.uid,"rxBytes" to rx,"txBytes" to tx))
        }
        return result.sortedByDescending{((it["rxBytes"] as Number).toLong()+(it["txBytes"] as Number).toLong())}
    }

    fun getAnalytics(context: Context): Map<String,Any> {
        if(!hasUsageAccess(context)) return emptyMap()
        val manager=context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val end=System.currentTimeMillis(); val start=end-24L*60L*60L*1000L
        var wifiRx=0L;var wifiTx=0L;var mobileRx=0L;var mobileTx=0L;var fgRx=0L;var fgTx=0L;var bgRx=0L;var bgTx=0L
        val pm=context.packageManager
        for(app in pm.getInstalledApplications(android.content.pm.PackageManager.GET_META_DATA)){
            if(app.uid<0||app.packageName==context.packageName) continue
            val w=queryUidDetailed(manager,ConnectivityManager.TYPE_WIFI,app.uid,start,end)
            val m=queryUidDetailed(manager,ConnectivityManager.TYPE_MOBILE,app.uid,start,end)
            wifiRx+=w.rx;wifiTx+=w.tx;mobileRx+=m.rx;mobileTx+=m.tx
            fgRx+=w.fgRx+m.fgRx;fgTx+=w.fgTx+m.fgTx;bgRx+=w.bgRx+m.bgRx;bgTx+=w.bgTx+m.bgTx
        }
        return mapOf("wifiRx" to wifiRx,"wifiTx" to wifiTx,"mobileRx" to mobileRx,"mobileTx" to mobileTx,"foregroundRx" to fgRx,"foregroundTx" to fgTx,"backgroundRx" to bgRx,"backgroundTx" to bgTx)
    }

    fun getApplicationUsageHistory(context: Context, packageName: String, range: String): List<Map<String,Any>> {
        if(!hasUsageAccess(context)) return emptyList()
        val app=context.packageManager.getApplicationInfo(packageName,0)
        val end=System.currentTimeMillis(); val days=when(range){"Weekly"->7L;"Monthly"->30L;else->1L}; val duration=days*24L*60L*60L*1000L; val start=end-duration
        val manager=context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val buckets=mutableListOf<BucketPoint>()
        buckets += queryBuckets(manager,ConnectivityManager.TYPE_WIFI,app.uid,start,end)
        buckets += queryBuckets(manager,ConnectivityManager.TYPE_MOBILE,app.uid,start,end)
        val grouped=buckets.groupBy{it.time/300000L}.map{(k,v)->mapOf("timestamp" to k*300000L,"bytes" to v.sumOf{it.rx+it.tx},"notifications" to 0)}.sortedBy{it["timestamp"] as Long}
        return grouped
    }

    private data class UsageResult(val rx:Long=0,val tx:Long=0)
    private data class Detailed(val rx:Long=0,val tx:Long=0,val fgRx:Long=0,val fgTx:Long=0,val bgRx:Long=0,val bgTx:Long=0,val mFgRx:Long=0,val mFgTx:Long=0,val mBgRx:Long=0,val mBgTx:Long=0)
    private data class BucketPoint(val time:Long,val rx:Long,val tx:Long)

    private fun queryUid(manager:NetworkStatsManager,type:Int,uid:Int,start:Long,end:Long)=try{
        val stats=if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.M)manager.queryDetailsForUid(type,null,start,end,uid) else return UsageResult()
        val b=NetworkStats.Bucket();var rx=0L;var tx=0L
        while(stats.hasNextBucket()){stats.getNextBucket(b);rx+=b.rxBytes;tx+=b.txBytes};stats.close();UsageResult(rx,tx)
    }catch(_:Exception){UsageResult()}

    private fun queryUidDetailed(manager:NetworkStatsManager,type:Int,uid:Int,start:Long,end:Long)=try{
        val stats=manager.queryDetailsForUid(type,null,start,end,uid);val b=NetworkStats.Bucket();var rx=0L;var tx=0L;var fgRx=0L;var fgTx=0L;var bgRx=0L;var bgTx=0L
        while(stats.hasNextBucket()){stats.getNextBucket(b);rx+=b.rxBytes;tx+=b.txBytes;when(b.state){NetworkStats.Bucket.STATE_FOREGROUND->{fgRx+=b.rxBytes;fgTx+=b.txBytes};NetworkStats.Bucket.STATE_DEFAULT->{bgRx+=b.rxBytes;bgTx+=b.txBytes}}};stats.close();Detailed(rx,tx,fgRx,fgTx,bgRx,bgTx)
    }catch(_:Exception){Detailed()}

    private fun queryBuckets(manager:NetworkStatsManager,type:Int,uid:Int,start:Long,end:Long):List<BucketPoint>{
        return try{val stats=manager.queryDetailsForUid(type,null,start,end,uid);val b=NetworkStats.Bucket();val out=mutableListOf<BucketPoint>();while(stats.hasNextBucket()){stats.getNextBucket(b);out.add(BucketPoint(b.startTimeStamp,b.rxBytes,b.txBytes))};stats.close();out}catch(_:Exception){emptyList()}
    }

    fun getHostStats(context:Context):List<Map<String,Any>>{
        val prefs=context.getSharedPreferences("netscope_hosts",Context.MODE_PRIVATE);return prefs.all.entries.map{mapOf("host" to it.key,"count" to (it.value as? Int ?:0))}.sortedByDescending{(it["count"] as Number).toInt()}.take(10)
    }
}
