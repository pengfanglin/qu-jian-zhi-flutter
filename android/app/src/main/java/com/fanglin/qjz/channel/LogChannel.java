package com.fanglin.qjz.channel;

import android.util.Log;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class LogChannel {
  
    //这里必选要跟Flutter平台名称对应上，否则无法接收消息
    private static final String LOG_CHANNEL_NAME = "androidLogChannel";

    public static void registerLogger(BinaryMessenger messenger) {
        new MethodChannel(messenger, LOG_CHANNEL_NAME).setMethodCallHandler((methodCall, result) -> {
            String tag = methodCall.argument("tag");
            String message = methodCall.argument("msg");
            switch (methodCall.method) {
                case "logV":
                    Log.v(tag, message);
                    break;
                case "logI":
                    Log.i(tag, message);
                    break;
                case "logW":
                    Log.w(tag, message);
                    break;
                case "logE":
                    Log.e(tag, message);
                    break;
                default:
                    Log.d(tag, message);
                    break;
            }
        });
    }
}