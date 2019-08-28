import 'package:flutter/material.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/page/goods.dart';
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';

class Message extends StatefulWidget {
  createState() => MessageState();
}

class MessageState extends State<Message> with AutomaticKeepAliveClientMixin {
  bool _topRightClick = false;
  List<Widget> _list = List<Widget>();
  Set<int> _carIds = Set<int>();
  List _apiData = List();
  ScrollController _controller = ScrollController();
  int page = 1;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: <Widget>[
            top(),
            Expanded(
                child: Container(
              color: Color(0xFFEEEFFF),
              child: shopCarList(),
            )),
            bottom()
          ],
        )));
  }

  @override
  bool get wantKeepAlive => true;

  Widget top() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: Application.themeColor,
      child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text('购物车', style: TextStyle(color: Colors.white, fontSize: 18)),
        GestureDetector(
          onTap: () {
            setState(() {
              _topRightClick = !_topRightClick;
            });
          },
          child: Image.asset('res/images/icon/' + (_topRightClick ? 'complete.png' : 'operation.png'), width: 25, height: 25),
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        page++;
        _getData();
      }
    });
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _getData() {
    Api.post<dynamic>('user/shopCarList', params: {"page": page}).then((data) {
      _apiData.addAll(data['data']);
      this.refresh();
    }, onError: (e) {
      ToastUtils.show(e.toString());
    });
  }

  Widget shopCarList() {
    return RefreshIndicator(
      color: Application.themeColor,
      onRefresh: () {
        return Future.delayed(Duration(milliseconds: 200), () {
          page = 1;
          _apiData.clear();
          _getData();
        });
      },
      child: ListView(shrinkWrap: true, controller: _controller, children: _list),
    );
  }

  Widget buildItem(index, data) {
    int _carId = data['id'];
    return Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: 120,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_carIds.contains(_carId)) {
                    _carIds.remove(_carId);
                  } else {
                    _carIds.add(_carId);
                  }
                  this.refresh();
                });
              },
              child: _carIds.contains(_carId)
                  ? Icon(Icons.check_circle, color: Application.themeColor)
                  : Icon(Icons.radio_button_unchecked, color: Colors.black26),
            ),
          ),
          Expanded(
              flex: 1,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                GestureDetector(
                    child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: ImgCache(Application.staticUrl + data['img'])),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Goods(data['goodsId']);
                          },
                        )
                    );
                  },
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(data['goodsName'], maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text(data['specificationName'], softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                            Text('￥' + data['specificationPrice'].toString(),
                                softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red)),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  Container(
                                      width: 20,
                                      height: 20,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (data['number'] > 0) {
                                            data['number']--;
                                            this.refresh();
                                          }
                                        },
                                        child: Center(
                                          child: Text('-', softWrap: false, style: TextStyle(fontSize: 18, color: Colors.black54)),
                                        ),
                                      )),
                                  Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      width: 40,
                                      height: 20,
                                      child: Center(
                                        child:
                                            Text(data['number'].toString(), softWrap: false, style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      ),
                                      decoration: ShapeDecoration(
                                          shape: Border(
                                              left: BorderSide(color: Colors.black54, width: 1),
                                              right: BorderSide(color: Colors.black54, width: 1)))),
                                  Container(
                                      width: 20,
                                      height: 20,
                                      child: GestureDetector(
                                          onTap: () {
                                            if (data['number'] < 999) {
                                              data['number']++;
                                              this.refresh();
                                            }
                                          },
                                          child: Center(
                                            child: Text('+', softWrap: false, style: TextStyle(fontSize: 16, color: Colors.black54)),
                                          )))
                                ]))
                          ])
                        ]))
              ]))
        ]));
  }

  void refresh() {
    setState(() {
      _list = List<Widget>();
      for (int index = 0; index < _apiData.length; index++) {
        _list.add(buildItem(index, _apiData[index]));
      }
    });
  }

  Widget bottom() {
    return Container(
      height: 50,
      decoration: ShapeDecoration(shape: Border(top: BorderSide(color: Colors.black26, width: 1))),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                if (_carIds.length == _apiData.length) {
                  _carIds.clear();
                  this.refresh();
                } else {
                  this._apiData.forEach((data) {
                    _carIds.add(data['id']);
                  });
                  this.refresh();
                }
              });
            },
            child: Row(
              children: <Widget>[
                _carIds.length == _apiData.length
                    ? Icon(Icons.check_circle, color: Application.themeColor)
                    : Icon(Icons.radio_button_unchecked, color: Colors.black26),
                Text('全选', style: TextStyle(color: Colors.black38))
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Text('合计:'),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text('￥' + allPrice(), style: TextStyle(color: Colors.red)),
              ),
              GestureDetector(
                onTap: () {
                  if (_carIds.length == 0) {
                    ToastUtils.show('您还没有选择宝贝奥');
                    return;
                  }
                  if (_topRightClick) {
                    ToastUtils.dialog('删除宝贝', "确定要删除宝贝么？删除后无法恢复!").then((value) {
                      if (value) {
                        Api.post('user/deleteShopCarByIds', params: {"ids": _carIds.join(',')}).then((data) {
                          ToastUtils.show("删除成功");
                          List<dynamic> temp = List<dynamic>();
                          _apiData.forEach((data) {
                            if (!_carIds.contains(data['id'])) {
                              temp.add(data);
                            }
                          });
                          _carIds.clear();
                          _apiData = temp;
                          this.refresh();
                        });
                      }
                    });
                  } else {
                    ToastUtils.show("下单功能未开放");
                  }
                },
                child: _topRightClick
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                        child: Text('删除(' + _carIds.length.toString() + ')', style: TextStyle(color: Colors.white)),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Application.themeColor, borderRadius: BorderRadius.circular(20)),
                        child: Text('结算(' + _carIds.length.toString() + ')', style: TextStyle(color: Colors.white)),
                      ),
              )
            ],
          )
        ],
      ),
    );
  }

  String allPrice() {
    double price = 0;
    _apiData.forEach((data) {
      if (_carIds.contains(data['id'])) {
        price += data['specificationPrice'] * data['number'];
      }
    });
    String stringPrice = price.toString();
    int index = stringPrice.indexOf('.');
    return stringPrice.substring(index, stringPrice.length).length > 2 ? stringPrice.substring(0, index + 2) : stringPrice;
  }
}
