// android/app/src/main/kotlin/com/example/netscope/NetworkEventStreamHandler.kt

package com.alphaagentssuite.netscope

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class NetworkEventStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {

    companion object {

        private var sink: EventChannel.EventSink? = null

        private val mainHandler =
            Handler(Looper.getMainLooper())

        fun emit(data: Map<String, Any>) {
            mainHandler.post {
                sink?.success(data)
            }
        }
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}