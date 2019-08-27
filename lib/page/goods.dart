import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:qjz/component/top.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/page/shop_car.dart';
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';

EventBus eventBus;

class Goods extends StatefulWidget {
  final int id;

  Goods(this.id);

  createState() => GoodsState();
}

class GoodsState extends State<Goods> {
  Map goods;
  double _htmlHeight = 300;
  static const String HANDLER_NAME = 'InAppWebView';
  InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();
    eventBus = new EventBus();
    goods = {
      'id': 0,
      'bannerImages': ['res/images/loading.gif'],
      'name': '加载中',
      'infoUrl': '',
      'img': 'res/images/loading.gif',
      'nowPrice': '0~0',
      'totalSales': 0,
      'totalStar': 15.0,
      'stock': 0,
      'star1': 5.0,
      'star2': 5.0,
      'star3': 5.0,
      'goodsSpecifications': [],
      'specifications': []
    };
    Api.post<dynamic>('goods/goodsDetail', params: {"id": widget.id}).then((data) {
      goods = data;
      setState(() {});
    }, onError: (e) {
      ToastUtils.show(e.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.destroy();
    _controller?.removeJavaScriptHandler(HANDLER_NAME);
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFEEEFFF),
        body: SafeArea(
            child: Container(
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Top(
              title: "商品详情",
              right: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return ShopCar();
                      },
                    ));
                  },
                  child: Icon(Icons.shopping_cart, color: Colors.white, size: 25))),
          Expanded(flex: 1, child: ListView(shrinkWrap: true, children: <Widget>[banner(), goodsInfo(), urlInfo()])),
          bottom()
        ]))));
  }

  Widget banner() {
    List<String> bannerImages = goods['bannerImages'].toString().split(',');
    return Container(
      height: 300,
      child: Swiper(
          itemBuilder: (context, index) {
            return ImgCache(goods['id'] == 0 ? '' : Application.STATIC_URL + bannerImages[index]);
          },
          itemCount: bannerImages.length,
          pagination: SwiperPagination(builder: DotSwiperPaginationBuilder(color: Colors.white, activeColor: Colors.red)),
          scrollDirection: Axis.horizontal,
          autoplay: true,
          autoplayDelay: 2000),
    );
  }

  Widget goodsInfo() {
    return Column(children: <Widget>[
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Center(
            child: Text(goods['name'], softWrap: false, style: TextStyle(fontSize: 16)),
          )),
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('￥' + goods['nowPrice'], softWrap: false, style: TextStyle(color: Colors.red)),
            Text(goods['totalSales'].toString() + '购买', softWrap: false, style: TextStyle(color: Colors.black54))
          ],
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(
              children: <Widget>[Icon(Icons.check_circle, color: Colors.red, size: 20), Text('快捷支付', style: TextStyle(color: Colors.black54))],
            ),
            Row(
              children: <Widget>[Icon(Icons.check_circle, color: Colors.red, size: 20), Text('运费险', style: TextStyle(color: Colors.black54))],
            ),
            Row(children: <Widget>[Icon(Icons.check_circle, color: Colors.red, size: 20), Text('七天无理由退货', style: TextStyle(color: Colors.black54))])
          ])),
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 5),
        height: 100,
        child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(child: Text((goods['totalStar'] / 3).toString(), style: TextStyle(color: Colors.red, fontSize: 25))),
          ),
          Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[star('宝贝评分', goods['star1']), star('物流速度', goods['star2']), star('平台服务', goods['star3'])]))
        ]),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(5)),
              child: Center(child: Text('查看评价', style: TextStyle(color: Colors.green, fontSize: 20)))))
    ]);
  }

  Widget star(text, star) {
    List<Widget> stars = List<Widget>();
    for (int i = 1; i <= 5; i++) {
      if (i <= star) {
        stars.add(Icon(Icons.star, color: Colors.red, size: 20));
      } else if (i > star && i <= 5) {
        stars.add(Icon(Icons.star_half, color: Colors.red, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.red, size: 20));
      }
    }
    return Row(
      children: <Widget>[
        Text(text, style: TextStyle(color: Colors.red, fontSize: 16)),
        Row(
          children: stars,
        )
      ],
    );
  }

  Widget bottom() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.headset_mic, color: Colors.grey, size: 25), Text('客服', style: TextStyle(color: Colors.black54))],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.star, color: Colors.grey, size: 25), Text('收藏', style: TextStyle(color: Colors.black54))],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  color: Color(0xFF409EFF), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
              child: Center(
                child: Text('加入购物车', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
              decoration: BoxDecoration(
                  color: Color(0xFFE6A23C), borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
              child: Center(
                child: Text('立即购买', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget urlInfo() {
    return goods['infoUrl'] == ''
        ? null
        : Container(
            height: _htmlHeight,
            child: InAppWebView(
                initialUrl: Application.STATIC_URL + goods['infoUrl'],
                onWebViewCreated: (InAppWebViewController controller) {
                  _controller = controller;
                  _setJSHandler(_controller); // 设置js方法回掉, 拿到高度
                },
                onLoadError: (InAppWebViewController controller, String url, int code, String message) {
                  print(code.toString() + ' ' + message);
                },
                onLoadStop: (InAppWebViewController controller, String url) {
                  // 页面加载完成后注入js方法, 获取页面总高度
                  controller.injectScriptCode("""
                  window.flutter_inappbrowser.callHandler('InAppWebView', document.body.scrollHeight).then(function(result) {});
                """);
                }));
  }

  void _setJSHandler(InAppWebViewController controller) {
    JavaScriptHandlerCallback callback = (List<dynamic> arguments) async {
      if (arguments.length > 0) {
        double height = double.parse(arguments[0].toString());
        if (height > 0) {
          setState(() {
            print(height);
            _htmlHeight = height;
          });
        }
      }
    };
    controller.addJavaScriptHandler(HANDLER_NAME, callback);
  }
}
