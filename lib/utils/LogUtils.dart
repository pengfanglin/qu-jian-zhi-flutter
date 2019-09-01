import 'package:flutter/services.dart';

class LogUtils {

  LogUtils._();

  static const perform = const MethodChannel("androidLogChannel");

  static void v(String message,{String tag}) {
    perform.invokeMethod('logV', {'tag': tag, 'msg': message});
  }

  static void d(String message,{String tag}) {
    perform.invokeMethod('logD', {'tag': tag, 'msg': message});
  }

  static void i(String message,{String tag}) {
    perform.invokeMethod('logI', {'tag': tag, 'msg': message});
  }

  static void w(String message,{String tag}) {
    perform.invokeMethod('logW', {'tag': tag, 'msg': message});
  }

  static void e(String message,{String tag}) {
    perform.invokeMethod('logE', {'tag': tag, 'msg': message});
  }
}