import 'package:flutter/material.dart';
import 'package:qjz/utils/application.dart';
import 'page/find.dart' show Find;
import 'page/home.dart' show Home;
import 'page/my.dart' show My;
import 'page/order.dart' show Order;
import 'page/shop_car.dart' show ShopCar;
import 'page/search.dart' show Search;

void main() {
  runApp(MaterialApp(
    title: '趣兼职',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Application.themeColor
    ),
    home: TableMenu()
  ));
}

class TableMenu extends StatefulWidget {
  createState() => TableMenuState();
}

class TableMenuState extends State<TableMenu> {
  List<Widget> _pages;
  int _currentIndex;
  PageController _controller;
  List<String> _menuImages = ['home', 'shop_car', 'order', 'find', 'my'];
  List<String> _menuTitles = ['首页', '购物车', '订单', '发现', '我的'];

  @override
  void initState() {
    super.initState();
    _currentIndex=0;
    _controller=PageController(initialPage: 0);
    _pages=List<Widget>()..add(Home())..add(ShopCar())..add(Order())..add(Find())..add(My());
    Application.bottomBarController=_controller;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Application.context=context;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: buildMenus(),
        currentIndex: _currentIndex,
        onTap: (index) {
          _controller.jumpToPage(index);
        },
        backgroundColor: Color(0xFFEEEFFF),
        type: BottomNavigationBarType.fixed
      ),
      body: PageView.builder(
          controller: _controller,
          onPageChanged: _pageChange,
          itemCount: _pages.length,
          itemBuilder: (context, index) => _pages[index])
    );
  }

  void _pageChange(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<BottomNavigationBarItem> buildMenus() {
    List<BottomNavigationBarItem> menuItems = List<BottomNavigationBarItem>();
    for (int i = 0; i < _menuImages.length; i++) {
      menuItems.add(BottomNavigationBarItem(
        icon: Image.asset('res/images/icon/${_menuImages[i]}.png', width: 30, height: 30),
        activeIcon: Image.asset('res/images/icon/${_menuImages[i]}_hover.png', width: 30, height: 30),
        title: Text(_menuTitles[i]),
      ));
    }
    return menuItems;
  }
}
