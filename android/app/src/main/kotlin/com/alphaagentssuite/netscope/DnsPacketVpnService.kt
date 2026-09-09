package com.alphaagentssuite.netscope

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors

/** DNS-only inspection VPN. It deliberately routes only public DNS addresses so normal traffic is not captured or broken. */
class DnsPacketVpnService : VpnService() {
    private var tun: ParcelFileDescriptor? = null
    private val pool = Executors.newSingleThreadExecutor()
    private val dns = InetAddress.getByName("8.8.8.8")

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        tun = Builder()
            .setSession("NetScope DNS inspection")
            .addAddress("10.8.0.2", 32)
            .addRoute("8.8.8.8", 32)
            .addRoute("1.1.1.1", 32)
            .addDnsServer("8.8.8.8")
            .establish()

        val fd = tun ?: return START_NOT_STICKY
        pool.execute { inspect(fd) }
        return START_STICKY
    }

    private fun inspect(fd: ParcelFileDescriptor) {
        val input = FileInputStream(fd.fileDescriptor)
        val output = FileOutputStream(fd.fileDescriptor)
        val buf = ByteArray(32767)

        try {
            while (!Thread.currentThread().isInterrupted) {
                val n = input.read(buf)
                if (n <= 0) continue

                val packet = buf.copyOf(n)
                val parsed = parseDns(packet) ?: continue

                val host = parsed.host
                val prefs = getSharedPreferences("netscope_hosts", MODE_PRIVATE)
                prefs.edit().putInt(host, prefs.getInt(host, 0) + 1).apply()

                PacketEventStreamHandler.emit(
                    mapOf(
                        "timestamp" to System.currentTimeMillis(),
                        "protocol" to "DNS",
                        "direction" to "Outbound",
                        "source" to parsed.source,
                        "destination" to parsed.destination,
                        "bytes" to parsed.payload.size,
                        "host" to host,
                        "summary" to "DNS lookup observed for $host"
                    )
                )

                val response = forward(parsed.payload, parsed.sourcePort)
                if (response != null) {
                    val ip = buildResponse(packet, response, parsed.sourcePort, parsed.destinationPort)
                    output.write(ip)
                    output.flush()
                }
            }
        } catch (_: Exception) {
        }
    }

    data class Parsed(
        val source: String,
        val destination: String,
        val sourcePort: Int,
        val destinationPort: Int,
        val payload: ByteArray,
        val host: String
    )

    private fun parseDns(p: ByteArray): Parsed? {
        if (p.size < 28) return null
        val b = ByteBuffer.wrap(p).order(ByteOrder.BIG_ENDIAN)
        val v = (b.get(0).toInt() ushr 4)
        if (v != 4) return null

        val ihl = (b.get(0).toInt() and 15) * 4
        val proto = b.get(9).toInt() and 255
        if (proto != 17 || p.size < ihl + 8) return null

        val src = InetAddress.getByAddress(p.copyOfRange(12, 16)).hostAddress
        val dst = InetAddress.getByAddress(p.copyOfRange(16, 20)).hostAddress
        val sp = ((p[ihl].toInt() and 255) shl 8) + (p[ihl + 1].toInt() and 255)
        val dp = ((p[ihl + 2].toInt() and 255) shl 8) + (p[ihl + 3].toInt() and 255)
        if (dp != 53) return null

        val payload = p.copyOfRange(ihl + 8, p.size)
        val host = parseQname(payload) ?: return null
        return Parsed(src, dst, sp, dp, payload, host)
    }

    private fun parseQname(d: ByteArray): String? {
        if (d.size < 13) return null
        var i = 12
        val labels = mutableListOf<String>()
        while (i < d.size) {
            val len = d[i].toInt() and 255
            if (len == 0) break
            if (len > 63 || i + 1 + len > d.size) return null
            labels.add(String(d, i + 1, len, Charsets.US_ASCII))
            i += len + 1
        }
        return if (labels.isEmpty()) null else labels.joinToString(".")
    }

    private fun forward(payload: ByteArray, port: Int): ByteArray? = try {
        val s = DatagramSocket()
        protect(s)
        s.soTimeout = 2000
        s.send(DatagramPacket(payload, payload.size, dns, 53))
        val out = ByteArray(4096)
        val dp = DatagramPacket(out, out.size)
        s.receive(dp)
        s.close()
        out.copyOf(dp.length)
    } catch (_: Exception) {
        null
    }

    private fun buildResponse(
        request: ByteArray,
        response: ByteArray,
        sourcePort: Int,
        destPort: Int
    ): ByteArray {
        val ihl = (request[0].toInt() and 15) * 4
        val out = ByteArray(ihl + 8 + response.size)

        request.copyInto(out, 0, 0, ihl)
        request.copyInto(out, 12, 16, 20)
        request.copyInto(out, 16, 12, 16)

        out[ihl] = ((destPort ushr 8) and 255).toByte()
        out[ihl + 1] = (destPort and 255).toByte()
        out[ihl + 2] = ((sourcePort ushr 8) and 255).toByte()
        out[ihl + 3] = (sourcePort and 255).toByte()

        val total = out.size
        out[2] = (total ushr 8).toByte()
        out[3] = total.toByte()

        out[ihl + 4] = (((response.size + 8) ushr 8) and 255).toByte()
        out[ihl + 5] = (response.size + 8).toByte()
        out[ihl + 6] = 0
        out[ihl + 7] = 0

        response.copyInto(out, ihl + 8)

        out[10] = 0
        out[11] = 0
        val ipcs = checksum(out, 0, ihl)
        out[10] = (ipcs ushr 8).toByte()
        out[11] = ipcs.toByte()

        val udpcs = udpChecksum(out, ihl)
        out[ihl + 6] = (udpcs ushr 8).toByte()
        out[ihl + 7] = udpcs.toByte()

        return out
    }

    private fun checksum(d: ByteArray, start: Int, len: Int): Int {
        var sum = 0L
        var i = start
        while (i < start + len) {
            val hi = d[i].toInt() and 255
            val lo = if (i + 1 < start + len) d[i + 1].toInt() and 255 else 0
            sum += ((hi shl 8) or lo)
            while (sum > 0xffff) sum = (sum and 0xffff) + (sum ushr 16)
            i += 2
        }
        return sum.inv().toInt() and 0xffff
    }

    private fun udpChecksum(d: ByteArray, off: Int): Int {
        val pseudo = ByteArray(12 + d.size - off - 8)
        d.copyInto(pseudo, 0, 12, 20)
        pseudo[9] = 17
        val udpLen = d.size - off
        pseudo[10] = (udpLen ushr 8).toByte()
        pseudo[11] = udpLen.toByte()
        d.copyInto(pseudo, 12, off, d.size)
        pseudo[12 + 6] = 0
        pseudo[12 + 7] = 0
        return checksum(pseudo, 0, pseudo.size)
    }

    override fun onDestroy() {
        try {
            tun?.close()
        } catch (_: Exception) {
        }
        tun = null
        pool.shutdownNow()
        super.onDestroy()
    }
}
