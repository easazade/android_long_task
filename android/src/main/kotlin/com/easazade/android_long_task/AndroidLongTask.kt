package com.easazade.android_long_task

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

const val CHANNEL_ID = "service_notification"

class AndroidLongTask(private val activity: FlutterActivity, private val binaryMessenger: BinaryMessenger) {
  private val CHANNEL_NAME = "FSE_APP_CHANNEL_NAME"
  private val START_SERVICE = "START_SERVICE"
  private val STOP_SERVICE = "STOP_SERVICE"
  private val RUN_DART_FUNCTION = "RUN_DART_FUNCTION"
  private val SET_SERVICE_DATA = "SET_SERVICE_DATA"
  private val GET_SERVICE_DATA = "GET_SERVICE_DATA"
  private val NOTIFY_UPDATE = "NOTIFY_UPDATE"
  lateinit var channel: MethodChannel
  private lateinit var serviceIntent: Intent
  var appService: AppService? = null
  var initialServiceData: JSONObject? = null
  var serviceConnection: ServiceConnection? = null
  var onServiceStarted: (() -> Unit)? = null

  init {
    activity.lifecycle.addObserver(object : DefaultLifecycleObserver {
      override fun onDestroy(owner: LifecycleOwner) {
        serviceConnection?.let { activity.unbindService(it) }
      }
    })
    createNotificationChannel()
    configure()
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(CHANNEL_ID, "Messages", NotificationManager.IMPORTANCE_LOW)
      val manager = activity.getSystemService(NotificationManager::class.java)
      manager.createNotificationChannel(channel)
    }
  }

  private fun configure() {
    serviceIntent = Intent(activity, AppService::class.java)
    val isRunning = isServiceRunning(AppService::class.java)
    Log.d("DART/NATIVE", "################ isServiceRunning -> $isRunning")
    if (isRunning) {
      startAndBindService()
    }
    channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler { call, result ->
      Log.d("DART/NATIVE", "native received a method call")
      when (call.method) {
        SET_SERVICE_DATA -> {
          Log.d("DART/NATIVE", "setting service data")
          setServiceData(call.arguments as String)
          result.success("set data successfully")
        }
        GET_SERVICE_DATA -> {
          Log.d("DART/NATIVE", "getting service data")
          if (isServiceRunning(AppService::class.java))
            result.success(appService?.serviceData?.toString())
          else
            result.success(initialServiceData.toString())
        }
        START_SERVICE -> {
          Log.d("DART/NATIVE", "starting service")
          startAndBindService()
          onServiceStarted = {
            result.success("service started successfully")
          }
        }
        STOP_SERVICE -> {
          Log.d("DART/NATIVE", "stopping service")
          appService?.stopDartService()
          if (appService != null)
            serviceConnection?.let { activity.unbindService(it) }
          appService = null
          result.success("service stopped")
        }
        RUN_DART_FUNCTION -> {
          Log.d("DART/NATIVE", "running dart code")
          Log.d("DART/NATIVE", call.arguments as String)
          if (appService != null) {
            appService!!.runDartFunction()
            appService!!.setMethodExecutionResultListener { jObject ->
              result.success(jObject.toString())
            }
          } else {
            result.error("SERVICE_NOT_STARTED", "can't execute dart code before starting service", "")
          }
        }
      }
    }
  }

  private fun setServiceData(jsonString: String) {
    try {
      val jObject = JSONObject(jsonString)
      Log.d("DART/NATIVE", "json data is -> $jsonString")
      initialServiceData = jObject
    } catch (e: Throwable) {
      e.printStackTrace()
    }
  }

  private fun startAndBindService() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      activity.startForegroundService(serviceIntent)
    } else {
      activity.startService(serviceIntent)
    }
    Log.d("DART/NATIVE", "binding service")
    serviceConnection = createServiceConnection()
    activity.bindService(serviceIntent, serviceConnection!!, Context.BIND_AUTO_CREATE)
    Log.d("DART/NATIVE", "ended binding service")
  }

  private fun createServiceConnection(): ServiceConnection {
    return object : ServiceConnection {
      override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        appService = (service as AppService.LocalBinder).getInstance()
        if (initialServiceData != null)
          appService?.setData(initialServiceData)
        onServiceStarted?.invoke()
        appService?.setServiceDataObserver { jsonObject ->
          channel.invokeMethod(NOTIFY_UPDATE, jsonObject.toString())
        }
      }

      override fun onServiceDisconnected(name: ComponentName?) {
        appService = null
      }
    }
  }

  private fun isServiceRunning(serviceClass: Class<*>): Boolean {
    val manager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    for (service in manager.getRunningServices(Int.MAX_VALUE)) {
      if (serviceClass.name == service.service.className) {
        return true
      }
    }
    return false
  }

}