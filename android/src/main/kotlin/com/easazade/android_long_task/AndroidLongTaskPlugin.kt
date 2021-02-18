package com.easazade.android_long_task

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger

/** AndroidLongTaskPlugin */
class AndroidLongTaskPlugin : FlutterPlugin, ActivityAwareAdapter() {
  private var activity: FlutterActivity? = null
  private var androidLongTask: AndroidLongTask? = null
  private var binaryMessenger: BinaryMessenger? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("DART/NATIVE", "onDetachedFromEngine")
    androidLongTask?.channel?.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d("DART/NATIVE", "onAttachedToActivity")
    activity = binding.activity as FlutterActivity
    androidLongTask = AndroidLongTask(activity!!, binaryMessenger!!)
  }
}
