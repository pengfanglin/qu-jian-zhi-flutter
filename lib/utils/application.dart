import 'package:flutter/material.dart';

class Application{
  //全局上下文
  static BuildContext context;
  //主题色
  static const Color themeColor=Color(0xFF409EFF);
  //是否是生产环境
  static final bool isPro=bool.fromEnvironment('dart.vm.product');
  //图片根路径
  static String staticUrl=isPro?'http://qbt.qubaotang.cn/':'http://192.168.0.110:8080/';
  ///全局上下文
  static String loadingImg='res/images/loading.gif';
  //底部导航栏
  static PageController bottomBarController;
}