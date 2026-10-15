package com.example.mobile_frontend

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val channelName = "gerdhero/report_file"
    private var pendingResult: MethodChannel.Result? = null
    private val createDocumentRequest = 1901

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "savePdf") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.argument<ByteArray>("bytes")
                val fileName = call.argument<String>("fileName") ?: "GERDHero_Laporan.pdf"
                if (bytes == null) {
                    result.error("INVALID_DATA", "Data PDF tidak tersedia.", null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/pdf"
                    putExtra(Intent.EXTRA_TITLE, fileName)
                }
                startActivityForResult(intent, createDocumentRequest)
                pendingBytes = bytes
            }
    }

    private var pendingBytes: ByteArray? = null

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != createDocumentRequest) return
        val result = pendingResult
        pendingResult = null
        val bytes = pendingBytes
        pendingBytes = null
        if (result == null) return
        if (resultCode != RESULT_OK || data?.data == null || bytes == null) {
            result.success(false)
            return
        }
        try {
            contentResolver.openOutputStream(data.data!!)?.use { it.write(bytes) }
                ?: throw IOException("Tidak dapat membuka lokasi penyimpanan.")
            result.success(true)
        } catch (error: IOException) {
            result.error("SAVE_FAILED", error.message, null)
        }
    }
}
