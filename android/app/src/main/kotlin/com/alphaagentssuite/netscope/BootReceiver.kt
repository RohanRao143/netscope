package com.alphaagentssuite.netscope
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
class BootReceiver: BroadcastReceiver(){ override fun onReceive(context:Context,intent:Intent?){ if(intent?.action!=Intent.ACTION_BOOT_COMPLETED&&intent?.action!=Intent.ACTION_MY_PACKAGE_REPLACED)return; val p=context.getSharedPreferences("netscope_settings",Context.MODE_PRIVATE);if(!p.getBoolean("auto_start",true))return;try{val i=Intent(context,NetworkMonitorService::class.java);if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O)context.startForegroundService(i)else context.startService(i)}catch(_:Exception){}}}
