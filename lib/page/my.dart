import 'package:flutter/material.dart';

class My extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Center(
        child: Text('我的',style: TextStyle(color: Colors.white))
      )
    );
  }
}