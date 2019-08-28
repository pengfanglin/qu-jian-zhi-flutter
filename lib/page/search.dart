import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:qjz/component/widgets.dart';
import 'package:qjz/page/goods.dart';
import 'package:qjz/utils/api.dart';
import 'package:qjz/utils/application.dart';
import 'package:qjz/utils/toast_utils.dart';

EventBus eventBus;

class SearchValueEvent{
  String search;
  SearchValueEvent(this.search);
}

class SubmitEvent{
  String search;
  SubmitEvent(this.search);
}

class FocusEvent{
  bool haveFocus;
  FocusEvent(this.haveFocus);
}

class ChangeSearchValueEvent{
  String search;
  ChangeSearchValueEvent(this.search);
}

class Search extends StatefulWidget {
  createState() => SearchState();
}

class SearchState extends State<Search> {
  @override
  void initState() {
    super.initState();
    eventBus=EventBus();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopSearch(),
            Expanded(
              flex: 1,
              child: SearchBody(),
            )
          ],
        )));
  }
  @override
  void dispose() {
    super.dispose();
    eventBus.destroy();
  }
}
class TopSearch extends StatefulWidget{
  createState()=>TopSearchState();
}

class TopSearchState extends State<TopSearch> {
  String search="";
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    eventBus.on<ChangeSearchValueEvent>().listen((ChangeSearchValueEvent changeSearchValueEvent){
      setState(() {
        search=changeSearchValueEvent.search;
        print(search);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController.fromValue(TextEditingValue(
        text: search,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: search.length))));
    _focusNode.addListener((){
      eventBus.fire(FocusEvent(_focusNode.hasFocus));
    });
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      color: Application.themeColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back,color: Colors.white)
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                focusNode: _focusNode,
                autofocus: true,
                controller: controller,
                maxLines: 1,
                onChanged: (value) {
                  eventBus.fire(SearchValueEvent(value));
                  setState(() {
                    search=value;
                  });
                },
                onSubmitted: (value) {
                  eventBus.fire(SubmitEvent(value));
                },
                style: TextStyle(color: Colors.black54),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: search.length > 0?0:10,horizontal: 10),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: search.length > 0
                        ? GestureDetector(
                      onTap: () {
                        eventBus.fire(SearchValueEvent(""));
                        eventBus.fire(FocusEvent(true));
                        setState(() {
                          search="";
                        });
                      },
                      child: Icon(Icons.cancel, color: Colors.black26),
                    ): null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
              )
            )
          ),
          GestureDetector(
              onTap: () {
                eventBus.fire(SubmitEvent(search));
              },
              child: Icon(Icons.search,color: Colors.white)
          ),
        ],
      ),
    );
  }
}

///搜索记录
class SearchBody extends StatefulWidget {
  createState() => SearchBodyState();
}

class SearchBodyState extends State<SearchBody> with SingleTickerProviderStateMixin{
  List<Widget> _historyList = List<Widget>();
  List<Widget> _hotList = List<Widget>();
  List<Widget> _nameList = List<Widget>();
  List<Widget> _goodsList = List<Widget>();
  List _apiData = List();
  TabController tabController;
  ScrollController _controller = ScrollController();
  int page = 1;
  String search="";
  bool submit=false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        page++;
        _getGoodsData();
      }
    });
    tabController=TabController(initialIndex:0,length: 3,vsync: this);
    tabController.addListener((){
      if(tabController.indexIsChanging){
        if(mounted){
          setState(() {
            page=1;
            _getGoodsData();
          });
        }
      }
    });
    if(search==""){
      getSearchData();
    }else{
      getAutoCompletionData();
    }
    eventBus.on<SearchValueEvent>().listen((SearchValueEvent searchValueEvent){
      search=searchValueEvent.search;
      if(search==""){
        getSearchData();
      }else{
        getAutoCompletionData();
      }
    });
    eventBus.on<SubmitEvent>().listen((SubmitEvent submitEvent){
      FocusScope.of(context).requestFocus(FocusNode());
      search=submitEvent.search;
      submit=true;
      _getGoodsData();
    });

    eventBus.on<FocusEvent>().listen((FocusEvent focusEvent){
      setState(() {
        submit=!focusEvent.haveFocus;
        if(submit){
          page=1;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    tabController.dispose();
  }

  void _getGoodsData() {
    String order;
    switch(tabController.index){
      case 0:
        order="price";
        break;
      case 1:
        order="sales";
        break;
      case 2:
        order="assessment";
        break;
      default:
        order="price";
        break;
    }
    Api.post<dynamic>('goods/searchGoodsList', params: {
      "page": page,
      "goodsName":search,
      "order":order
    }).then((data) {
      if(page==1){
        _apiData.clear();
      }
      _apiData.addAll(data['data']);
      this.refresh();
    }, onError: (e) {
      ToastUtils.show(e.toString());
    });
  }

  void refresh() {
    setState(() {
      _goodsList = List<Widget>();
      for (int index = 0; index < _apiData.length; index++) {
        _goodsList.add(buildGoodsItem(index, _apiData[index]));
      }
    });
  }

  Widget buildGoodsItem(index, data) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Goods(data['id']);
              },
            )
        );
      },
      child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          height: 120,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Expanded(
                flex: 1,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: ImgCache(Application.staticUrl + data['img'])),
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(data['name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                Text('库存:'+data['stock'], softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('￥' + data['nowPrice'].toString(),
                                          softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red)),
                                      Text(data['totalSales']+'人购买',
                                          softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87))
                                    ]
                                )
                              ]
                          )
                      )
                    ]
                ))
          ])
      ),
    );
  }

  void getSearchData(){
    Api.post<List<dynamic>>('user/userSearchHistoryList').then((searchHistoryList) {
      if(mounted){
        setState(() {
          _historyList = List<Widget>();
          searchHistoryList.forEach((searchHistory) {
            _historyList.add(GestureDetector(
              onTap: () {
                searchHistoryClick(searchHistory['content']);
              },
              child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Application.themeColor, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(searchHistory['content'],
                      softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54, fontSize: 16))),
            ));
          });
        });
      }
    }, onError: (e) {
      ToastUtils.show(e);
    });
    Api.post<List<dynamic>>('user/hostSearchList').then((hotSearchList) {
      if(mounted){
        setState(() {
          _hotList = List<Widget>();
          hotSearchList.forEach((hotSearch) {
            _hotList.add(GestureDetector(
              onTap: () {
                searchHistoryClick(hotSearch['content']);
              },
              child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Application.themeColor, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    hotSearch['content'],
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  )),
            ));
          });
        });
      }
    }, onError: (e) {
      ToastUtils.show(e);
    });
  }

  void getAutoCompletionData(){
    Api.post<List<dynamic>>('goods/goodsNameAutoCompletion',params: {"goodsName":search}).then((data){
      if(mounted){
        setState(() {
          _nameList=List<Widget>();
          data.forEach((goodsName){
            _nameList.add(
              GestureDetector(
                onTap: (){
                  eventBus.fire(SubmitEvent(goodsName));
                  eventBus.fire(ChangeSearchValueEvent(goodsName));
                  page=1;
                },
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    child: Text(goodsName,style:TextStyle(color: Colors.black87,fontSize: 16),softWrap: false,overflow: TextOverflow.ellipsis),
                ),
              )
            );
          });
        });
      }
    });
  }

  void searchHistoryClick(content) {
    eventBus.fire(ChangeSearchValueEvent(content));
    eventBus.fire(SubmitEvent(content));
    page=1;
  }

  Widget buildSearch(){
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              '搜索记录',
              style: TextStyle(color: Colors.black),
            )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Wrap(spacing: 20, runSpacing: 10, children: _historyList),
        ),
        Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: Text('热门搜索')),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Wrap(spacing: 20, runSpacing: 10, children: _hotList),
        )
      ],
    );
  }

  Widget buildAutoCompletion(){
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
      shrinkWrap: true,
      children: _nameList,
    );
  }

  Widget buildGoodsList(){

    return RefreshIndicator(
      color: Application.themeColor,
      onRefresh: () {
        return Future.delayed(Duration(milliseconds: 200), () {
          page = 1;
          _getGoodsData();
        });
      },
      child: Column(
        children: <Widget>[
          TabBar(
            controller: tabController,
            tabs: <Widget>[
              Tab(child: Text('价格')),
              Tab(child: Text('销量')),
              Tab(child: Text('评价'))
            ],
            labelColor: Colors.red,
            indicatorColor: Application.themeColor,
            unselectedLabelColor: Colors.black87,
          ),
          Expanded(
            flex: 1,
            child: Container(
                color: Color(0xFFEEEFFF),
                child: ListView(shrinkWrap: true, controller: _controller, children: _goodsList)
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(submit);
    return submit?buildGoodsList():search==""?buildSearch():buildAutoCompletion();
  }
}
