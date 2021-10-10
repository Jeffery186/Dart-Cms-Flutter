import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:get/get.dart';
// components
import 'package:dart_cms_flutter/components/videoItem.dart';
// utils
import 'package:dart_cms_flutter/utils/cache.dart';
import 'package:dart_cms_flutter/utils/config.dart';
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
// page
import 'package:dart_cms_flutter/router/pages.dart';
// global controller
import 'package:dart_cms_flutter/service/videoHistory.dart';
// widget
import 'package:dart_cms_flutter/widget/openLoading.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
// schema
import 'package:dart_cms_flutter/schema/get_app_update.dart';

class AppBarUserSettingView extends StatelessWidget {
  const AppBarUserSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // 头部
            Header(),
            // menu菜单
            Menu(),
          ],
        ),
      ),
    );
  }
}

class RowBtn extends StatelessWidget {
  final String text;
  final Icon icon;
  final Widget? right;
  final Function? cb;
  final double heigth;
  const RowBtn({
    Key? key,
    required this.text,
    required this.icon,
    this.right,
    this.cb,
    this.heigth = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> child = [
      Container(
        width: 40,
        child: icon,
        alignment: Alignment.center,
      ),
      Expanded(child: Text(text)),
    ];
    if (right != null) {
      child.add(right!);
    }
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (cb != null) {
            cb!();
          }
        },
        child: Container(
          height: heigth,
          child: Row(
            children: child,
          ),
        ),
      ),
    );
  }
}

// row 子项
// ignore: must_be_immutable
class HistoryRowItem extends StatelessWidget {
  String videoImage;
  String videoTitle;
  String coll_name;
  HistoryRowItem({
    Key? key,
    required this.videoImage,
    required this.videoTitle,
    required this.coll_name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 80,
          width: 120,
          child: FadeInImage(
            placeholder: AssetImage('images/movie-lazy.gif'),
            image: NetworkImage(videoImage),
            imageErrorBuilder: (ctx, obj, trace) {
              return ImgState(
                msg: "加载失败",
                icon: Icons.broken_image,
              );
            },
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 25,
          width: 120,
          alignment: Alignment.center,
          child: Text(
            videoTitle + " " + coll_name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistoryService historyService = Get.put(HistoryService());

    Widget _buildHistoryChild() {
      if (historyService.hisList.length > 0) {
        // ignore: invalid_use_of_protected_member
        List<Widget> childList = historyService.hisList.value.map((item) {
          String videoImgUrl = item["videoImage"].contains("http")
              ? item["videoImage"]
              : hostUrl + item["videoImage"];
          return Padding(
            padding: EdgeInsets.only(left: 3, right: 3),
            child: VideoItem(
              Id: item["Id"],
              playFocus: {
                "row_id": item["row_id"],
                "col_id": item["col_id"],
              },
              // 历史记录的每一项
              child: HistoryRowItem(
                videoImage: videoImgUrl,
                videoTitle: item["videoTitle"],
                coll_name: item["coll_name"],
              ),
            ),
          );
        }).toList();
        return Container(
          alignment: Alignment.bottomLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: childList,
            ),
          ),
        );
      } else {
        return Container(
          height: 80,
          child: Center(
            child: Text("暂无历史记录 ╮(╯▽╰)╭"),
          ),
        );
      }
    }

    return Container(
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
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 20),
            // 头像
            ClipOval(
              child: Container(
                color: Colors.black12,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 历史记录
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0.0, 0.0),
                      blurRadius: 10,
                      spreadRadius: 8,
                    ),
                  ],
                  color: Colors.white,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 12,
                    right: 12,
                    bottom: 15,
                  ),
                  child: Column(
                    children: [
                      RowBtn(
                        text: "历史记录",
                        icon: Icon(Icons.history),
                        right: Text("更多"),
                        cb: () => Get.toNamed(PageName.VIDEO_HISTORY),
                      ),
                      Divider(height: 1),
                      SizedBox(height: 10),
                      // 历史记录
                      Obx(() => _buildHistoryChild()),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _cacheSize = '0';

  // 计算缓存大小
  Future<void> _getCacheSize() async {
    String futrueCache = await loadCache();
    setState(() {
      _cacheSize = futrueCache;
    });
  }

  // 删除缓存
  Future<void> _clearCache() async {
    clearCache(cb: () {
      _getCacheSize();
      publicToast('缓存清除成功');
    });
  }

  // 初始化
  Future<void> _initData() async {
    await _getCacheSize();
  }

  // 获取升级信息
  Future<void> _authUpdateInfo(context) async {
    showLoading(context);
    await HttpUtils().x_get(url: '/app/appAuthUpgrade', query: {
      'appKey': appUniqueKey,
    }).whenComplete(() {
      hideLoading(context);
    }).then((res) {
      AppAuthUpgrade fmtBody = AppAuthUpgrade.fromJson(res.body);
      // 显示下弹框，版本是否升级，以及升级信息
      _showUpdateDialog(context, fmtBody);
    }).catchError((err) {
      publicToast("升级信息获取失败！");
    });
  }

  void _showUpdateDialog(BuildContext context, AppAuthUpgrade fmtBody) {
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
                "检测升级",
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
                          fmtBody.value!.upgrade!
                              ? fmtBody.value!.dialog!
                              : "当前版本已是最新",
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // 关闭按钮
                Container(
                  alignment: Alignment.center,
                  child: MyButton(
                    title: "关闭",
                    cb: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(height: 10),
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
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0.0, 0.0),
              blurRadius: 10,
              spreadRadius: 8,
            ),
          ],
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              RowBtn(
                text: "我的收藏",
                heigth: 50,
                icon: Icon(Icons.star, color: Colors.yellow[900]),
                cb: () => Get.toNamed(PageName.VIDEO_STORE),
              ),
              Divider(height: 1),
              RowBtn(
                text: "清除缓存",
                heigth: 50,
                right: Text(_cacheSize),
                icon: Icon(Icons.cached, color: Colors.green[900]),
                cb: _clearCache,
              ),
              Divider(height: 1),
              RowBtn(
                text: "分享App",
                heigth: 50,
                icon: Icon(Icons.share, color: Colors.blue[900]),
                cb: () => ShareExtend.share(appName + ' ' + hostUrl, "text"),
              ),
              Divider(height: 1),
              RowBtn(
                text: "免责申明",
                heigth: 50,
                icon: Icon(Icons.feedback, color: Colors.red[900]),
                cb: () => Get.toNamed(PageName.USER_DECLARE),
              ),
              Divider(height: 1),
              RowBtn(
                text: "检查更新",
                heigth: 50,
                icon: Icon(Icons.phone_android, color: Colors.pink[900]),
                cb: () => _authUpdateInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
