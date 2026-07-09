package com.example.mathcalcu

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mathcalcu/installer"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val apkPath = call.argument<String>("apkPath")
                if (apkPath == null) {
                    result.error("NO_PATH", "apkPath argument is required", null)
                    return@setMethodCallHandler
                }
                installApk(apkPath) { err ->
                    if (err == null) result.success(null)
                    else result.error("INSTALL_ERROR", err, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun installApk(apkPath: String, callback: (String?) -> Unit) {
        try {
            val apkFile = File(apkPath)
            if (!apkFile.exists()) {
                callback("APK file not found at $apkPath")
                return
            }

            val packageInstaller = context.packageManager.packageInstaller
            val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)

            val sessionId = packageInstaller.createSession(params)
            val session = packageInstaller.openSession(sessionId)

            try {
                val inputStream: InputStream = FileInputStream(apkFile)
                val outputStream = session.openWrite("MathCalcu", 0, apkFile.length())

                try {
                    val buffer = ByteArray(65536)
                    var bytesRead: Int
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                    }
                    session.fsync(outputStream)
                } finally {
                    inputStream.close()
                    outputStream.close()
                }

                val pendingIntent = Intent(context, MainActivity::class.java).let {
                    it.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    PendingIntent.getActivity(context, 0, it,
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                }

                session.commit(pendingIntent.intentSender)
                callback(null)
            } finally {
                session.close()
            }
        } catch (e: Exception) {
            callback(e.message ?: "Unknown install error")
        }
    }
}