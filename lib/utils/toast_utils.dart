import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qjz/component/web_view.dart';
import 'package:qjz/utils/application.dart';

class ToastUtils {
  static void show(String message, {int duration, BuildContext context}) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                    color: Color(0xFF666666),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 13, color: Colors.white, decoration: TextDecoration.none),
                    )))),
      );
    });
    Overlay.of(context == null ? Application.context : context).insert(entry);
    Future.delayed(Duration(seconds: duration ?? 2)).then((value) {
      // 移除层可以通过调用OverlayEntry的remove方法。
      entry.remove();
    });
  }

  ///对话框
  static Future<bool> dialog(String title, String content) {
    return showDialog<bool>(
        context: Application.context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Colors.black87),
            ),
            content: Text(content),
            actions: <Widget>[
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black12), right: BorderSide(color: Colors.black12))),
                      child: Center(
                        child: Text('取消', style: TextStyle(fontSize: 16, color: Color(0xFF409EFF), decoration: TextDecoration.none)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
                          child: Center(
                            child: Text('确定', style: TextStyle(fontSize: 16, color: Color(0xFF409EFF), decoration: TextDecoration.none)),
                          )),
                    )),
              ])
            ],
          );
        });
  }

  static webView(String url, {String title}) {
    Navigator.of(Application.context).push(MaterialPageRoute(
      builder: (context) {
        return WebView(url, title: title);
      },
    ));
  }
}
