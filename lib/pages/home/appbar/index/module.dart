// ignore_for_file: non_constant_identifier_names, must_be_immutable, must_call_super
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/components/videoItem.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
// widget
import 'package:dart_cms_flutter/router/pages.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/myLoading.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';
// utils
import 'package:dart_cms_flutter/utils/config.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
import 'package:dart_cms_flutter/utils/toast.dart';
// components
import 'package:dart_cms_flutter/components/publicMeal.dart';
import 'package:dart_cms_flutter/components/videoTypeGroup.dart';
// schema
import 'package:dart_cms_flutter/schema/get_cur_nav_list.dart';
// controller
import 'package:dart_cms_flutter/pages/home/appbar/index/controller.dart';
// interface
import 'package:dart_cms_flutter/interface/videoGroup.dart';

class AppBarIndexView extends GetView<AppbarIndexViewStore> {
  @override
  Widget build(BuildContext context) {
    AppbarIndexViewStore controller = Get.put(AppbarIndexViewStore());
    // 生成appbar
    AppBar _buildPublicAppBar({
      required bool isShowTabBar,
      required double height,
    }) {
      return AppBar(
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 跳转到搜索
                  print('跳转到搜索');
                  Get.toNamed(PageName.VIDEO_SEARCH);
                },
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
            ),
            MyIconButton(
              icon: Icon(Icons.search),
              cb: () {
                print('跳转到搜索');
                Get.toNamed(PageName.VIDEO_SEARCH);
              },
            ),
          ],
        ),
        bottom: isShowTabBar
            ? TabBar(
                isScrollable: true,
                controller: controller.tabController,
                tabs: controller.tabBarList
                    .map((el) => Tab(text: el.name))
                    .toList(),
              )
            : null,
      );
    }

    return controller.obx(
      (state) => Scaffold(
        appBar: _buildPublicAppBar(height: 100, isShowTabBar: true),
        body: TabBarView(
          controller: controller.tabController,
          children: controller.tabBarList
              .asMap()
              .keys
              .map((int idx) =>
                  HomeAppBarTabView(controller.tabBarList[idx]!.Id!, idx))
              .toList(),
        ),
      ),
      onLoading: Scaffold(
        appBar: _buildPublicAppBar(height: 50, isShowTabBar: true),
        body: MyLoading(
          message: "正在加载",
        ),
      ),
      onEmpty: Scaffold(
        appBar: _buildPublicAppBar(height: 50, isShowTabBar: true),
        body: MyState(
          icon: Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "暂无数据",
          cb: () async {
            await controller.savePullHomeTypeList();
          },
        ),
      ),
      onError: (state) => Scaffold(
        appBar: _buildPublicAppBar(height: 50, isShowTabBar: true),
        body: MyState(
          icon: Icon(
            Icons.pest_control,
            size: 100,
            color: Colors.red,
          ),
          text: "点击重试",
          cb: () async {
            await controller.savePullHomeTypeList();
          },
        ),
      ),
    );
  }
}

class HomeAppBarTabView extends StatefulWidget {
  final int tabIdx;
  final String Id;
  bool? isInit;
  HomeAppBarTabView(this.Id, this.tabIdx, {Key? key}) : super(key: key);

  @override
  _HomeAppBarTabViewState createState() => _HomeAppBarTabViewState(Id, tabIdx);
}

class _HomeAppBarTabViewState extends State<HomeAppBarTabView>
    with AutomaticKeepAliveClientMixin {
  final int tabIdx;
  final String Id;
  bool? isInit;
  // 0加载中 1加载成功 2空结果 3 失败
  int stateCode = 0;
  // data schema
  GetCurNavItemListValue? curNavData;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _HomeAppBarTabViewState(this.Id, this.tabIdx);

  Future<GetCurNavItemList> pullCurNavData() async {
    Response res = await HttpUtils().xGet(
      url: "/app/getCurNavItemList/" + Id,
    );
    GetCurNavItemList fmtBody = GetCurNavItemList.fromJson(res.body);
    return fmtBody;
  }

  Future<void> _refresh() async {
    await pullCurNavData().whenComplete(() {
      _refreshController.refreshCompleted();
    }).then((body) {
      if (mounted) {
        setState(() {
          curNavData = body.value;
          // 每一个分类下是否有数据，如果有就控制显示
          bool isExistChild = false;
          body.value!.tabList!.forEach((element) {
            if (element!.list!.length > 0) {
              isExistChild = true;
            }
          });
          stateCode = (body.value!.tabList!.length > 0 && isExistChild) ||
                  isInit == true
              ? 1
              : 2;
          if (stateCode == 1) {
            isInit = isInit ?? true;
          }
        });
      }
    }).catchError((err) {
      print(err);
      if (isInit == null) {
        if (mounted) {
          setState(() {
            stateCode = 3;
          });
        }
      } else {
        publicToast("加载错误");
      }
      print("发生错误， urlPath: /app/getCurNavItemList/" + Id);
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (stateCode == 0) {
      return MyLoading(
        message: "正在加载",
      );
    } else if (stateCode == 1) {
      return SmartRefresher(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              // 轮播图
              SwiperController(itemList: curNavData!.swiperList!),
              // 恰饭
              PublicMealComponents<GetCurNavItemListValueMealList>(
                  mealList: curNavData!.mealList!),
              // 导航组
              TypeGroup<GetCurNavItemListValueTabList>(
                  navItem: curNavData!.tabList!),
            ],
          ),
        ),
        onRefresh: _refresh,
        controller: _refreshController,
      );
    } else if (stateCode == 2) {
      return MyState(
        icon: Icon(
          Icons.new_releases,
          size: 100,
          color: Colors.red,
        ),
        text: "暂无数据",
        cb: () async {
          setState(() {
            stateCode = 0;
          });
          await _refresh();
        },
      );
    } else if (stateCode == 3) {
      return MyState(
        icon: Icon(
          Icons.pest_control,
          size: 100,
          color: Colors.red,
        ),
        text: "点击重试",
        cb: () async {
          setState(() {
            stateCode = 0;
          });
          await _refresh();
        },
      );
    } else {
      return Container();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class TypeGroup<T extends VideoGroupInterFace> extends StatelessWidget {
  List<T?>? navItem;
  TypeGroup({Key? key, this.navItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> child = navItem!.map((e) {
      return e!.list!.length > 0
          ? Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: VideoTypeGroupComponents(videoGroup: e),
            )
          : Container();
    }).toList();
    return Container(
      child: Column(
        children: child,
      ),
    );
  }
}

class SwiperController extends StatefulWidget {
  List<GetCurNavItemListValueSwiperList?>? itemList;
  SwiperController({Key? key, required this.itemList}) : super(key: key);

  @override
  _SwiperControllerState createState() => _SwiperControllerState();
}

class _SwiperControllerState extends State<SwiperController> {
  @override
  Widget build(BuildContext context) {
    return widget.itemList!.length > 0
        ? Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Color(0xfffafafa),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Swiper(
                autoplay: true,
                itemBuilder: (BuildContext context, int index) {
                  String posterUrl =
                      widget.itemList![index]!.poster!.contains("http")
                          ? widget.itemList![index]!.poster!
                          : hostUrl + widget.itemList![index]!.poster!;
                  return VideoItem(
                    Id: widget.itemList![index]!.Id!,
                    child: SwiperItemCover(posterUrl),
                  );
                },
                itemCount: widget.itemList!.length,
                pagination: SwiperPagination(),
                viewportFraction: 0.8,
                scale: 0.9,
              ),
            ),
          )
        : Container();
  }
}

class SwiperItemCover extends StatelessWidget {
  String posterUrl;
  SwiperItemCover(this.posterUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FadeInImage(
        placeholder: AssetImage('images/movie-lazy.gif'),
        image: NetworkImage(posterUrl),
        imageErrorBuilder: (context, obj, trace) {
          return ImgState(
            msg: "加载失败",
            icon: Icons.broken_image,
          );
        },
        fit: BoxFit.cover,
      ),
    );
  }
}
