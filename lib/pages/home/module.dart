// ignore_for_file: must_call_super
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// utils
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
// page view
import 'package:dart_cms_flutter/pages/home/appbar/index/module.dart';
import 'package:dart_cms_flutter/pages/home/appbar/article/module.dart';
import 'package:dart_cms_flutter/pages/home/appbar/type/module.dart';
import 'package:dart_cms_flutter/pages/home/appbar/user/module.dart';
// schema
import 'package:dart_cms_flutter/schema/app_load_point.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  DateTime? lastPopTime;
  int _curTabIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  late BuildContext topContext;

  Future<AppLoadPoint> pullAppPoint() async {
    Response res = await HttpUtils().xGet(url: "/app/appInitTipsInfo");
    AppLoadPoint fmtBody = AppLoadPoint.fromJson(res.body);
    return fmtBody;
  }

  Future<void> savePullAppPoint() async {
    await pullAppPoint().then((AppLoadPoint body) {
      if (body.code == 200 && body.value!.theSwitch!) {
        // 显示问候语
        _showUpdateDialog(body);
      }
    }).catchError((err) {
      publicToast("app提示信息获取失败");
    });
  }

  void _showUpdateDialog(AppLoadPoint fmtBody) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 15,
            right: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Icons.mail_outline),
              ),
              Text(
                // 标题
                "温馨提示",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          content: Container(
            height: 170,
            width: 200,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    child: ListView(
                      children: <Widget>[
                        Text(
                          fmtBody.value!.notice!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    savePullAppPoint();
  }

  @override
  Widget build(BuildContext context) {
    topContext = context;
    return WillPopScope(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          currentIndex: _curTabIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
            BottomNavigationBarItem(icon: Icon(Icons.article), label: "文章"),
            BottomNavigationBarItem(icon: Icon(Icons.view_list), label: "分类"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
          ],
          fixedColor: Colors.blue,
          onTap: (int idx) {
            //跳转到指定页面
            _pageController.jumpToPage(idx);
            setState(() {
              _curTabIndex = idx;
            });
          },
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            AppBarIndexView(),
            AppBarArticleView(),
            AppBarVideoTypeView(),
            AppBarUserSettingView(),
          ],
        ),
      ),
      onWillPop: () async {
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime!) > Duration(seconds: 2)) {
          // 存储当前按下back键的时间
          lastPopTime = DateTime.now();
          // toast
          publicToast("再按一次退出APP");
          return false;
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
