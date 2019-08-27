import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_inappbrowser/flutter_inappbrowser.dart";
import 'package:qjz/utils/application.dart';

class WebView extends StatefulWidget{
  final String  url;
  final String title;
  final bool full;

  WebView(this.url,{this.title,this.full=false});

  @override
  State<StatefulWidget> createState()=>MyWebViewState();
}
class MyWebViewState extends State<WebView>{
  // 标记是否是加载中
  bool loading = true;
  InAppWebViewController webView;
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _url=widget.url;
    List<Widget> titleContent = [];

    if (!widget.full&&progress<1) {
      // 如果还在加载中，就在标题栏上显示一个圆形进度条
      titleContent.add(CupertinoActivityIndicator());
    }
    if(!widget.full&&widget.title!=null){
      titleContent.add(Text(widget.title,style: TextStyle(color: Colors.white)));
    }
    return Scaffold(
      appBar: widget.full?null:AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                if(Navigator.of(context).canPop()){
                  Navigator.of(context).pop();
                }
              },
              child: Icon(Icons.arrow_back,color: Colors.white,size: 25),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: titleContent
              )
            ),
            GestureDetector(
              onTap: (){
                webView.reload();
              },
              child: Icon(Icons.refresh,color: Colors.white,size: 25)
            )
          ]
        ),
        backgroundColor: Application.themeColor,
        iconTheme: IconThemeData(color: Colors.white)
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrl: _url,
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      _url = url;
                    });
                  },
                  onProgressChanged: (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress/100;
                    });
                  },
                ),
              ),
            )
          ].where((Object o) => o != null).toList(),
        ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}