import 'package:flutter/material.dart';
import 'package:qjz/component/web_view.dart';
import 'package:qjz/utils/application.dart';

class Order extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: WebView(Application.STATIC_URL+'html/goods/1.html')
      )
    );
  }
}