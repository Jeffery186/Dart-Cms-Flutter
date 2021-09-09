import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// router widget
import 'package:dart_cms_flutter/router/pages.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';
// utils
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
// schema
import 'package:dart_cms_flutter/schema/get_cur_video_detaill.dart';

abstract class VideoItemInterFace {
  late String Id;
  late Widget child;
  late bool isPopRouter = false;
  Function? routerPopEnter;
  late Map<String, int> playFocus = {
    "row_id": 0,
    "col_id": 0,
  };

  Future openVideo(BuildContext context);
  bool showLoading(BuildContext context);
  bool hideLoading(BuildContext context);
  Widget build(BuildContext context);
}

// 公共封面组件
// ignore: must_be_immutable
class VideoItem extends StatelessWidget implements VideoItemInterFace {
  @override
  String Id;
  @override
  Widget child;
  @override
  Map<String, int> playFocus;
  @override
  bool isPopRouter;
  @override
  Function? routerPopEnter;

  VideoItem({
    Key? key,
    required this.Id,
    required this.child,
    this.isPopRouter = false,
    this.routerPopEnter,
    this.playFocus = const {
      "row_id": 0,
      "col_id": 0,
    },
  }) : super(key: key);

  @override
  bool hideLoading(BuildContext context) {
    Navigator.of(context).pop();
    return true;
  }

  @override
  bool showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 115.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 140,
              child: new Center(
                ///弹框大小
                child: new SizedBox(
                  width: 120.0,
                  height: 120.0,
                  child: new Container(
                    ///弹框背景和圆角
                    decoration: ShapeDecoration(
                      color: Color(0xffffffff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new CircularProgressIndicator(),
                        new Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                          ),
                          child: new Text(
                            "加载中",
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return false;
          },
        );
      },
    );
    return true;
  }

  @override
  Future openVideo(BuildContext context) async {
    VideoDetaill? fmtBody;
    showLoading(context);
    try {
      Response res = await HttpUtils().x_get(
        url: "/app/getDetillData/" + Id,
      );
      fmtBody = VideoDetaill.fromJson(res.body);
    } catch (err) {
      publicToast("发生错误");
    } finally {
      hideLoading(context);
    }
    // 确认下是否有播放源，如果没有，就直接弹出提示
    if (fmtBody!.value!.source!.length > 0) {
      // 传递，
      if (isPopRouter) {
        await routerPopEnter!();
        Get.back();
      }
      Get.toNamed(
        PageName.VIDEO_DETAILL,
        arguments: {
          "detaill": fmtBody.value,
          "playFocus": Map<String, int>.from(playFocus),
        },
      );
    } else {
      publicToast("该视频暂无播放源");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await openVideo(context);
      },
      child: child,
    );
  }
}

// 公共的封面 - 布局widget
// ignore: must_be_immutable
class PublicVideoCover extends StatelessWidget {
  String videoTitle;
  String videoImgUrl;
  PublicVideoCover({
    Key? key,
    required this.videoTitle,
    required this.videoImgUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Column(
        children: [
          Container(
            height: 180,
            child: FadeInImage(
              placeholder: AssetImage('images/movie-lazy.gif'),
              image: NetworkImage(videoImgUrl),
              imageErrorBuilder: (context, obj, trace) {
                return ImgState(
                  msg: "加载失败",
                  icon: Icons.broken_image,
                );
              },
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Container(
            alignment: Alignment.center,
            child: Text(
              videoTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
