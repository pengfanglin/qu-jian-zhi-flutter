import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qjz/page/home/home.dart' show TopSearch;
import 'package:qjz/page/home/home.dart' as test;

class TestHome extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => CustomViewState();

}

class CustomViewState extends State<TestHome> {

  bool isToTop = false;

  //滚动控制器
  ScrollController _controller;

  void _onPressed() {
    //回到ListView顶部
    _controller.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.offset > 1000) {
        setState(() {
          isToTop = true;
        });
      } else if (_controller.offset <= 500) {
        setState(() {
          isToTop = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text("CustomView AppBar Title")),
        body: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverAppBar(
              title: Text("视差滚动效果", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              floating: true,
              flexibleSpace:
              Image.network("http://img95.699pic.com/photo/50057/7197.jpg_wh300.jpg"
                  , fit: BoxFit.cover),
              expandedHeight: 200,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(title: Text('Item $index')),
                childCount: 100,
              ),
            )
          ],
        ),
        floatingActionButton: isToTop ? FloatingActionButton(
            onPressed: () => _onPressed(),
            child: Icon(Icons.arrow_upward)
        ) : null,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}