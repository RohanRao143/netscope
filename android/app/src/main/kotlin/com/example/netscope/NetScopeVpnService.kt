// android/app/src/main/kotlin/com/example/netscope/NetScopeVpnService.kt

package com.alphaagentssuite.netscope

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class NetScopeVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {

        /*
         * Intentionally not establishing a catch-all VPN tunnel here.
         *
         * A VpnService that adds 0.0.0.0/0 without implementing a complete
         * user-space IP/TCP/UDP forwarding stack will break the user's
         * Internet connection.
         *
         * NetScope therefore uses NetworkStatsManager for safe system-level
         * usage statistics.
         */

        stopSelf()

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        vpnInterface?.close()
        vpnInterface = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?) =
        super.onBind(intent)
}