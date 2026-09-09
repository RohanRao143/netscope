package com.alphaagentssuite.netscope
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
class PacketEventStreamHandler: EventChannel.StreamHandler {
 companion object { private var sink:EventChannel.EventSink?=null; private val h=Handler(Looper.getMainLooper()); fun emit(v:Map<String,Any?>){h.post{sink?.success(v)}} }
 override fun onListen(a:Any?,e:EventChannel.EventSink?){sink=e}
 override fun onCancel(a:Any?){sink=null}
}
