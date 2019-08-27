import 'package:flutter/material.dart';

class Application{
  ///全局上下文
  static BuildContext context;
  //主题色
  static const Color themeColor=Color(0xFF409EFF);
  //图片根路径
  static const String STATIC_URL='http://qbt.qubaotang.cn/';
//  static const String STATIC_URL='http://192.168.0.110:8080/';
  ///全局上下文
  static String loadingImg='res/images/loading.gif';
  //底部导航栏
  static PageController bottomBarController;
}