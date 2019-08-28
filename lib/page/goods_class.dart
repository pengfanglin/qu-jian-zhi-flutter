import 'package:flutter/material.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';

class GoodsClassRoot extends StatelessWidget {

  final _classId;

  GoodsClassRoot(this._classId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFEEEFFF),
        body: SafeArea(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TopTitle(),
            Expanded(
              flex: 1,
              child: GoodsClassBody(_classId),
            )
          ],
        )));
  }
}

class GoodsClassBody extends StatefulWidget {

  final _classId;
  GoodsClassBody(this._classId);

  @override
  createState() => GoodsClassBodyState(_classId);
}

class GoodsClassBodyState extends State<GoodsClassBody> {
  final _classId;
  double _itemHeight=40;
  ScrollController _controller=ScrollController();
  GoodsClassBodyState(this._classId);

  int clickIndex = 0;
  List<dynamic> leftGoodsClassList = List<dynamic>();
  List<dynamic> rightGoodsClassList = List<dynamic>();
  List<Widget> leftClassWidget = List<Widget>();
  List<Widget> rightClassWidget = List<Widget>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: Application.themeColor,
          constraints: BoxConstraints(maxWidth: 110),
          child: ListView(shrinkWrap: true,controller: _controller, children: leftClassWidget),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: GridView(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //每行5个
                  mainAxisSpacing: 10, //主轴方向间距
                  crossAxisSpacing: 10, //水平方向间距
                  childAspectRatio: 2 / 2.5),
              children: rightClassWidget,
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Api.post<List<dynamic>>('goods/goodsClassTree').then((goodsClassTree) {
      setState(() {
        for(int i=0;i<goodsClassTree.length;i++){
          if(_classId==goodsClassTree[i]['id']){
            clickIndex=i;
            break;
          }
        }
        leftGoodsClassList = goodsClassTree;
        buildLeftClassWidgetList();
        _controller.animateTo(clickIndex*_itemHeight, duration: Duration(seconds: 2), curve: Curves.ease);
        if (leftGoodsClassList.length > 0) {
          this.buildRightClassWidgetList(0);
        }
      });
    }, onError: (e) {
      ToastUtils.show(e);
    });
  }

  void buildLeftClassWidgetList() {
    leftClassWidget = List<Widget>();
    for (int i = 0; i < leftGoodsClassList.length; i++) {
      leftClassWidget.add(GestureDetector(
          onTap: () {
            setState(() {
              rightGoodsClassList = leftGoodsClassList[i]['goodsClassModels'];
              clickIndex = i;
              buildLeftClassWidgetList();
              buildRightClassWidgetList(i);
            });
          },
          child: Container(
            height:_itemHeight,
            decoration: clickIndex == i
                ? ShapeDecoration(color: Colors.white, shape: Border(left: BorderSide(color: Colors.red, width: 5)))
                : BoxDecoration(color: Application.themeColor),
            child: Center(
              child: Text(leftGoodsClassList[i]['name'],
                  softWrap: false, style: TextStyle(color: clickIndex == i ? Application.themeColor : Colors.white, fontSize: 20)),
            ),
          )));
    }
  }

  void buildRightClassWidgetList(index) {
    rightClassWidget = List<Widget>();
    rightGoodsClassList = (leftGoodsClassList[index]['goodsClassModels'] as List<dynamic>);
    rightGoodsClassList.forEach((goodsClass) {
      rightClassWidget.add(buildItem(goodsClass));
    });
  }

  Widget buildItem(dynamic goodsClass) {
    return GestureDetector(
      onTap: () {
        ToastUtils.show(goodsClass['name']);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Application.themeColor, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                    child: ImgCache(Application.staticUrl + goodsClass['img']),
                  )),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Center(
                  child: Text(goodsClass['name'], softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                ),
              )
            ])),
      ),
    );
  }
}

///顶部标题栏
class TopTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: Application.themeColor,
      child: Center(
        child: Container(child: Text('商品分类', style: TextStyle(color: Colors.white, fontSize: 20))),
      ),
    );
  }
}
