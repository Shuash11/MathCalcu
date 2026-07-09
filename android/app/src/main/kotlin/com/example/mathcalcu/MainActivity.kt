package com.example.mathcalcu

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mathcalcu/installer"
    private val ACTION_INSTALL_RESULT = "com.mathcalcu.INSTALL_RESULT"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath")
                    if (apkPath == null) {
                        result.error("NO_PATH", "apkPath argument is required", null)
                        return@setMethodCallHandler
                    }
                    installApk(apkPath) { err ->
                        if (err == null) result.success(null)
                        else result.error("INSTALL_ERROR", err, null)
                    }
                }
                "openInstallSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                        intent.data = Uri.parse("package:${context.packageName}")
                        context.startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
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
                val inputStream = FileInputStream(apkFile)
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

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    Intent(ACTION_INSTALL_RESULT),
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
                )

                val receiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context, intent: Intent) {
                        val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, -1)
                        val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: ""
                        when (status) {
                            PackageInstaller.STATUS_SUCCESS -> {
                                callback(null)
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                                val confirmIntent = intent.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)
                                if (confirmIntent != null) {
                                    context.startActivity(confirmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                                }
                            }
                            PackageInstaller.STATUS_FAILURE_ABORTED -> {
                                callback("Install cancelled")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_FAILURE_BLOCKED -> {
                                callback("Install blocked by device policy")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_FAILURE_CONFLICT -> {
                                callback("App signature mismatch — cannot update")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_FAILURE_INCOMPATIBLE -> {
                                callback("App incompatible with device")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_FAILURE_INVALID -> {
                                callback("APK file is invalid or corrupt")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            PackageInstaller.STATUS_FAILURE_STORAGE -> {
                                callback("Insufficient storage space")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                            else -> {
                                callback(if (message.isNotEmpty()) message else "Install failed (code: $status)")
                                try { context.unregisterReceiver(this) } catch (_: Exception) {}
                            }
                        }
                    }
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    context.registerReceiver(receiver, IntentFilter(ACTION_INSTALL_RESULT), Context.RECEIVER_EXPORTED)
                } else {
                    context.registerReceiver(receiver, IntentFilter(ACTION_INSTALL_RESULT))
                }

                session.commit(pendingIntent.intentSender)
            } finally {
                session.close()
            }
        } catch (e: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !packageManager.canRequestPackageInstalls()) {
                callback("NEED_PERMISSION")
            } else {
                callback(e.message ?: "Security exception during install")
            }
        } catch (e: Exception) {
            callback(e.message ?: "Unknown install error")
        }
    }
}
