// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/components/videoItem.dart';
// utils
import 'package:dart_cms_flutter/utils/config.dart';
// interface
import 'package:dart_cms_flutter/interface/videoGroup.dart';

class VideoTypeGroupComponents<S extends VideoGroupInterFace>
    extends StatefulWidget {
  S videoGroup;
  final int rowItemLen;
  final bool isShowTitle;
  final Color bgColor;
  final bool isPopRouter;
  Function? routerPopEnter;
  VideoTypeGroupComponents({
    Key? key,
    required this.videoGroup,
    this.rowItemLen = 3,
    this.isShowTitle = true,
    this.bgColor = const Color(0xfffafafa),
    this.isPopRouter = false,
    this.routerPopEnter,
  }) : super(key: key);

  @override
  _VideoTypeGroupComponentsState createState() =>
      _VideoTypeGroupComponentsState();
}

class _VideoTypeGroupComponentsState extends State<VideoTypeGroupComponents> {
  int get rowItemLen => widget.rowItemLen;
  bool get isShowTitle => widget.isShowTitle;
  Color get bgColor => widget.bgColor;
  bool get isPopRouter => widget.isPopRouter;

  Widget _buildGroupChild(BuildContext context) {
    final int topLen = widget.videoGroup.list!.length;
    List<Widget> child = [];
    // 标题
    if (isShowTitle) {
      child.add(
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.videocam),
              SizedBox(width: 3),
              Text(
                // 板块标题
                widget.videoGroup.name!,
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    for (var i = 0; i < topLen; i += rowItemLen) {
      int ml = i + rowItemLen;
      List<Widget> curChild = [];
      for (var j = i; j < ml; j++) {
        Widget curItem;
        if (j < topLen) {
          String videoImgUrl =
              widget.videoGroup.list![j]!.videoImage!.contains("http")
                  ? widget.videoGroup.list![j]!.videoImage!
                  : hostUrl + widget.videoGroup.list![j]!.videoImage!;
          curItem = Expanded(
            flex: 1,
            child: VideoItem(
              Id: widget.videoGroup.list![j]!.Id,
              isPopRouter: isPopRouter,
              routerPopEnter: widget.routerPopEnter,
              // 公用的封面
              child: PublicVideoCover(
                videoTitle: widget.videoGroup.list![j]!.videoTitle,
                videoImgUrl: videoImgUrl,
              ),
            ),
          );
        } else {
          curItem = Expanded(child: Container(height: 1), flex: 1);
        }
        curChild.add(curItem);
      }
      child.add(
        Padding(
          padding: EdgeInsets.only(left: 2, right: 2),
          child: Row(
            children: curChild,
          ),
        ),
      );
    }
    return Container(
      color: bgColor,
      child: Column(
        children: child,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildGroupChild(context);
  }
}
