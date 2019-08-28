import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/page/goods.dart';
import 'package:qjz/page/search.dart' show Search;
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';

import '../goods_class.dart' show GoodsClassRoot;

class Home extends StatefulWidget {
  createState()=>HomeState();
}

class HomeState extends State<Home> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TopSearch(),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[Banner(), GoodsClass(), HotSales(), HotGoods()],
                  ),
                )
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;
}

///热卖图片
class HotSales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 60, child: Image.asset('res/images/hot_sales.png'));
  }
}

///搜索框
class TopSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      color: Application.themeColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return Search();
            }));
          },
          child: Container(
              padding: EdgeInsets.only(left: 10),
              height: 40,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[Icon(Icons.search, color: Colors.black26), Text('请输入商品名称', style: TextStyle(color: Colors.black38, fontSize: 14))],
              )),
        ),
      ),
    );
  }
}

///轮播图
class Banner extends StatefulWidget {
  createState() => BannerState();
}

class BannerState extends State<Banner> {
  Swiper swiper = Swiper(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Image.asset('res/images/loading.gif');
      });

  @override
  void initState() {
    super.initState();
    Api.post<List<dynamic>>('others/homeBannerList').then((bannerList) {
      setState(() {
        swiper = Swiper(
            itemBuilder: (context, index) {
              return ImgCache(Application.staticUrl + bannerList[index]['img']);
            },
            itemCount: bannerList.length,
            pagination: SwiperPagination(builder: DotSwiperPaginationBuilder(color: Colors.white, activeColor: Colors.red)),
            scrollDirection: Axis.horizontal,
            autoplay: true,
            autoplayDelay: 2000,
            onTap: (index){
              if(bannerList[index]['type']=='COMMON'){
                ToastUtils.webView(Application.staticUrl+bannerList[index]['url'],title: '测试标题');
              }else if(bannerList[index]['type']=='GOODS'){
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Goods(bannerList[index]['businessId']);
                      },
                    )
                );
              }else if(bannerList[index]['type']=='CHAIN'){
                ToastUtils.webView(bannerList[index]['url'],title: '测试标题');
              }
            });
      });
    }, onError: (e) {
      ToastUtils.show(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200.0,
      child: swiper,
    );
  }
}

///商品分类
class GoodsClass extends StatefulWidget {
  createState() => GoodsClassState();
}

class GoodsClassState extends State<GoodsClass> {
  List<Widget> list = List<Widget>();

  @override
  void initState() {
    super.initState();
    list = List<Widget>();
    Map data={
      'type':'assert',
      'id':0,
      'name':'加载中。。。',
      'img':'res/images/icon/all_class.png'
    };
    list.add(buildItem(data));
    data={
      'type':'assert',
      'id':0,
      'name':'加载中。。。',
      'img':'res/images/loading.gif'
    };
    for (int i = 0; i < 9; i++) {
      list.add(buildItem(data));
    }
    Api.post<List<dynamic>>('goods/homeGoodsClassList').then((goodsClassList) {
      setState(() {
        list = List<Widget>();
        Map data={
          'type':'assert',
          'id':0,
          'name':'全部分类',
          'img':'res/images/icon/all_class.png'
        };
        list.add(buildItem(data));
        goodsClassList.forEach((goodsClass){
          goodsClass['type']='network';
          list.add(buildItem(goodsClass));
        });
      });
    }, onError: (e) {
      ToastUtils.show(e);
    });
  }

  Widget buildItem(goodsClass){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return GoodsClassRoot(goodsClass['id']);
        }));
      },
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: CircleAvatar(
                backgroundColor: Application.themeColor,
                radius: 30,
                backgroundImage: goodsClass['type']=='assert'?AssetImage(goodsClass['img']):NetworkImage(Application.staticUrl + goodsClass['img'])
            ),
          ),
          Text(goodsClass['name'],style: TextStyle(color: Colors.black54),softWrap: false)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      color: const Color(0xFFEEEFFF),
      child: GridView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, //每行5个
          mainAxisSpacing: 5, //主轴方向间距
          crossAxisSpacing: 10, //水平方向间距
          childAspectRatio: 1 / 1.25
        ),
        children: list,
      ),
    );
  }
}

///热卖商品
class HotGoods extends StatefulWidget {
  createState() => HotGoodsState();
}

class HotGoodsState extends State<HotGoods> {
  List<Widget> list;

  @override
  void initState() {
    super.initState();
    list = List<Widget>();
    for (int i = 0; i < 6; i++) {
      list.add(buildItem({"goodsId": -1, "name": "加载中。。。。。", "imgType": 'asset', "img": "res/images/loading.gif", "minPrice": "0", "totalSales": 0}));
    }
    Api.post<List<dynamic>>('goods/homeHotGoodsList').then((goodsList) {
      setState(() {
        list = List<Widget>();
        goodsList.forEach((goods) {
          goods['imgType'] = 'network';
          list.add(buildItem(goods));
        });
      });
    }, onError: (e) {
      ToastUtils.show(e);
    });
  }

  Widget buildItem(dynamic goods) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Goods(goods['id']);
              },
            )
        );
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: Colors.white,
              child: Column(children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      child: goods['imgType'] == 'asset'
                          ? Image.asset(
                              goods['img'],
                              fit: BoxFit.fill,
                            )
                          : ImgCache(Application.staticUrl + goods['img']),
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Center(
                    child: Text(goods['name'], softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text('￥${goods['minPrice']}',
                            softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.red)),
                        flex: 1,
                      ),
                      Expanded(
                        child: Text('${goods['totalSales']}人付款',
                            softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.black54)),
                        flex: 1,
                      ),
                    ],
                  ),
                )
              ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: const Color(0xFFEEEFFF),
      child: GridView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, crossAxisSpacing: 10, childAspectRatio: 2 / 2.8),
        children: list,
      ),
    );
  }
}
