import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/page/search.dart' show Search;
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';


class Test1Home extends StatefulWidget {
  createState()=>HomeState();
}

class HomeState extends State<Test1Home> with AutomaticKeepAliveClientMixin{

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
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            controller: _controller,
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                flexibleSpace:ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    TopSearch(),
                    Banner(),
                    Slogan()
                  ],
                ),
                expandedHeight: 200,
              ),
              PostTypeTab()
            ],
          )
        )
    );
  }

  @override
  bool get wantKeepAlive => false;
}

///搜索框
class TopSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return Search();
            }));
          },
          child: Container(
              height: 40,
              color: Colors.white,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('上海', style: TextStyle(color: Colors.black, fontSize: 30,fontWeight: FontWeight.w700)),
                          Icon(Icons.arrow_drop_down, color: Colors.black,size: 30)
                        ]
                    ),
                    Icon(Icons.search, color: Colors.black,size: 30)
                  ]
              )),
        )
    );
  }
}

///轮播图
class Banner extends StatefulWidget {
  createState() => BannerState();
}

class BannerState extends State<Banner> {
  static List<String> _defaultBanners=['res/images/banner/1.png','res/images/banner/2.png','res/images/banner/3.png'];
  Swiper swiper = Swiper(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Image.asset(_defaultBanners[index]);
      });

  @override
  void initState() {
    super.initState();
    Api.post<List<dynamic>>('app/others/homeBannerList').then((bannerList) {
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
              if(bannerList[index]['type']=='SHOW'){
                ToastUtils.webView(Application.staticUrl+bannerList[index]['url'],title: '测试标题');
              }else if(bannerList[index]['type']=='IN_CHAIN'){
                ToastUtils.webView(Application.staticUrl+bannerList[index]['url']);
              }else if(bannerList[index]['type']=='OUT_SIDE_CHAIN'){
                ToastUtils.webView(bannerList[index]['url']);
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 160.0,
      child: swiper,
    );
  }
}

///标语
class Slogan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  width: 160,
                  height: 72,
                  child: Image.asset('res/images/home/slogan_left.png')
              ),
              Container(
                  width: 160,
                  height: 72,
                  child: Image.asset('res/images/home/slogan_right.png')
              )
            ]
        )
    );
  }
}

class PostTypeTab extends StatefulWidget{
  createState() => PostTypeTabState();
}

class PostTypeTabState extends State<PostTypeTab> with SingleTickerProviderStateMixin{
  int _page=1;
  List<Widget> _postList = List<Widget>();
  List _apiData = List();
  TabController _tabController;
  ScrollController _postListController;

  @override
  void initState() {
    super.initState();
    _tabController=TabController(initialIndex:0,length: 3,vsync: this);
    _tabController.addListener((){
      if(_tabController.indexIsChanging){
        if(mounted){
          setState(() {
            _page=1;
            _getPostData();
          });
        }
      }
    });
    _postListController= ScrollController();
    _postListController.addListener(() {
      if (_postListController.position.pixels == _postListController.position.maxScrollExtent) {
        _page++;
        _getPostData();
      }
    });
    _getPostData();
  }
  @override
  Widget build(BuildContext context) {
    return _buildPostList();
  }

  void _getPostData() {
    String type;
    switch(_tabController.index){
      case 0:
        type='PART';
        break;
      case 1:
        type='FULL';
        break;
      case 2:
        type='INTERNSHIP';
        break;
      default:
        type=null;
        break;
    }
    Api.post<dynamic>('app/post/homePostList', params: {
      'page': _page,
      'type':type
    }).then((postList) {
      if(_page==1){
        _apiData.clear();
      }
      _apiData.addAll(postList);
      this.refresh();
    }, onError: (e) {
      ToastUtils.show(e.toString());
    });
  }

  void refresh() {
    setState(() {
      _postList = List<Widget>();
      for (int index = 0; index < _apiData.length; index++) {
        _postList.add(_buildPostItem(index, _apiData[index]));
      }
    });
  }

  Widget _buildPostItem(index, data) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return null;
              },
            )
        );
      },
      child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal:10,vertical: 3),
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          height: 120,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(data['name'], overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.black,fontSize: 18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(data['price'].toString(),overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.orange,fontSize: 18)),
                      Text('元/'+data['unitShow'], softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87,fontSize: 10)),
                    ],
                  )
                ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(data['address'],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.black54)),
                  Text(data['distance']==0?'':(data['distance']/1000).toString()+'km', softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54)),
                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Chip(
                  label: Text(
                    data['area'],
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFEEEFFF),
                ),
                Chip(
                  label: Text(
                    data['clearShow'],
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFEEEFFF),
                ),
                Chip(
                  label: Text(
                    data['category'],
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFEEEFFF),
                ),
              ],
            )
          ])
      ),
    );
  }

  Widget _buildPostList(){
    TextStyle _select=TextStyle(fontSize: 22,fontWeight:FontWeight.w800);
    TextStyle _unSelect=TextStyle(fontSize: 18,fontWeight: FontWeight.normal);
    return RefreshIndicator(
      color: Application.themeColor,
      onRefresh: () {
        return Future.delayed(Duration(milliseconds: 100), () {
          _page = 1;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal:10),
            width: 230,
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(child: Text('兼职',style: _tabController.index==0?_select:_unSelect)),
                Tab(child: Text('全职',style: _tabController.index==1?_select:_unSelect)),
                Tab(child: Text('实习',style: _tabController.index==2?_select:_unSelect))
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.orange,
              unselectedLabelColor: Colors.black54,
              indicatorWeight:4.0,
              indicatorSize:TabBarIndicatorSize.label,
              labelPadding: EdgeInsets.symmetric(horizontal: 0),
            ),
          ),
          Container(
            padding:EdgeInsets.symmetric(horizontal:20,vertical: 10) ,
            child: _buildFilter(),
          ),
          Container(
              color: Color(0xFFEEEFFF),
              child: ListView(shrinkWrap: true,physics: AlwaysScrollableScrollPhysics(), controller: _postListController, children: _postList)
          )
        ],
      ),
    );

  }

  Widget _buildFilter(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildFilterItem(0, '排序'),
        _buildFilterItem(0, '职位'),
        _buildFilterItem(0, '区域'),
        _buildFilterItem(0, '学历')
      ],
    );
  }

  Widget _buildFilterItem(int index,String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.w600)),
        Icon(Icons.arrow_drop_down,color: Colors.black45,size:18 )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _postListController.dispose();
  }
}