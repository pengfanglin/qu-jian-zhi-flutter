import 'package:flutter/material.dart';
import 'package:qjz/utils/application.dart';

class Top extends StatelessWidget {
  final String title;
  final Widget right;

  Top({this.title, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Application.themeColor,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 25)),
            Expanded(
              flex: 1,
              child: Center(
                  child: title == null
                      ? Text('')
                      : Text(title, softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 18,decoration: TextDecoration.none))),
            ),
            right == null ? Container() : right
          ],
        ));
  }
}
