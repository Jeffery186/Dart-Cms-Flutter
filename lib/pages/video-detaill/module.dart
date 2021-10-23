import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:get/get.dart';
// utils
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/utils/config.dart';
// widget
import 'package:dart_cms_flutter/widget/myButton.dart';
// public components
import 'package:dart_cms_flutter/components/videoTypeGroup.dart';
import 'package:dart_cms_flutter/components/publicMeal.dart';
// skin
import 'package:dart_cms_flutter/fijkplayer_skin/fijkplayer_skin.dart';
// global controller
import 'package:dart_cms_flutter/service/videoHistory.dart';
import 'package:dart_cms_flutter/service/videoStore.dart';
// schema
import 'package:dart_cms_flutter/schema/get_cur_video_detaill.dart';
import 'package:dart_cms_flutter/schema/get_cur_nav_list.dart';

class PlayerShowConfig implements ShowConfigAbs {
  bool speedBtn = true;
  bool topBar = true;
  bool lockBtn = true;
  bool bottomPro = true;
  bool stateAuto = true;
}

class VideoDetaillPage extends StatefulWidget {
  VideoDetaillPage({Key? key}) : super(key: key);

  @override
  _VideoDetaillPageState createState() => _VideoDetaillPageState();
}

class _VideoDetaillPageState extends State<VideoDetaillPage> {
  VideoDetaillValue videoDetaill = Get.arguments["detaill"];

  // 全局控制器
  HistoryService historyService = Get.put(HistoryService());
  StoreService storeService = Get.put(StoreService());

  // 动态标题
  String curVideoShowTitle = "";
  // fijk
  final FijkPlayer player = FijkPlayer();
  ShowConfigAbs vSkinCfg = PlayerShowConfig();

  String curPlayUrl = "";

  Map<String, int> playFocus = Get.arguments["playFocus"] != null
      ? Get.arguments["playFocus"]
      : {
          "row_id": 0,
          "col_id": 0,
        };

  GetCurNavItemListValueTabList? likeMovieGroup;

  void fromLikeMovie() {
    List<Map<String, dynamic>> movieChild = [];
    videoDetaill.list!.likeMovie!.forEach((el) {
      movieChild.add({
        "_id": el!.Id,
        "videoTitle": el.videoTitle,
        "director": el.director,
        "videoImage": el.videoImage,
        "poster": el.poster,
        "performer": el.performer,
        "video_type": el.videoType,
        "video_rate": el.videoRate,
        "update_time": el.updateTime,
        "language": el.language,
        "sub_region": el.subRegion,
        "rel_time": el.relTime,
        "introduce": el.introduce,
        "remind_tip": el.remindTip,
        "popular": el.popular,
        "allow_reply": el.allowReply,
        "openSwiper": el.openSwiper,
        "display": el.display,
        "scource_sort": el.scourceSort,
      });
    });
    Map<String, dynamic> likeMovieMap = {
      "name": "猜你喜欢",
      "list": movieChild,
    };
    setState(() {
      likeMovieGroup = GetCurNavItemListValueTabList.fromJson(likeMovieMap);
    });
  }

  Future<void> initPlayer() async {
    // 皮肤里面的播放速度，每次进入播放页的时候重置为 1.0
    speed = 1.0;
    List<String> curSource = videoDetaill
        .source![playFocus["row_id"]!]!.list![playFocus["col_id"]!]!
        .split('\$');
    setState(() {
      // 存播放源
      curPlayUrl = curSource[1];
      // 存播放标题
      curVideoShowTitle =
          videoDetaill.videoInfo!.videoTitle! + ' - ' + curSource[0];
    });
    // 加入历史记录
    await historyService.add<VideoDetaillValueVideoInfo>(
      videoDetaill.videoInfo!,
      curSource[0],
      {
        "row_id": playFocus["row_id"]!,
        "col_id": playFocus["col_id"]!,
      },
    );
    // 设置播放源
    await player.setDataSource(curPlayUrl, autoPlay: true);
  }

  // 加入收藏
  Future<void> _joinLikeList() async {
    storeService
        .add<VideoDetaillValueVideoInfo>(videoDetaill.videoInfo!)
        .then((value) {
      publicToast("已为您加入收藏");
    }).catchError((err) {
      publicToast("发生错误");
    });
  }

  // 唤起分享
  Future<void> _shareCurVideo() async {
    ShareExtend.share(
        "${videoDetaill.videoInfo!.videoTitle} $appName $hostUrl", "text");
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fromLikeMovie();
    initPlayer();
  }

  // 小字
  Widget _buildTextTip(String text) {
    return Text(
      text.isNotEmpty ? text : '暂无',
      style: TextStyle(
        color: Colors.black45,
      ),
    );
  }

  // 竖线
  Widget _buldVerLine() {
    return Padding(
      padding: EdgeInsets.all(7),
      child: VerticalDivider(
        color: Colors.black45,
        width: 1,
      ),
    );
  }

  // 自定义按钮 inkwell 更多
  Widget _buildInkWellSubscript({
    required String tagName,
    required Function cb,
  }) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: () => cb(),
          child: Padding(
            padding: EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
            child: Text(tagName),
          ),
        ),
      ),
    );
  }

  // 自定义按钮 inkwell , 收藏 分享
  Widget _buildInkWellButton({
    required String tagName,
    required IconData icon,
    required Function cb,
  }) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          borderRadius: new BorderRadius.circular(15),
          onTap: () => cb(),
          child: Container(
            child: Padding(
              padding: EdgeInsets.only(left: 17, right: 17, top: 5, bottom: 5),
              child: Column(
                children: <Widget>[
                  Icon(icon, color: Colors.black87),
                  Text(tagName, style: TextStyle(color: Colors.black87))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 标题 头部
  Widget _buildVideoInfoTitle(BuildContext context) {
    return Container(
      height: 50,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  videoDetaill.videoInfo!.videoTitle!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              _buildInkWellSubscript(
                tagName: "更多",
                cb: () {
                  // 打开底部弹出详细信息
                  _showVideoInfoModule(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 分类信息 头部
  Widget _buildVideoTypeCrumb() {
    return Container(
      height: 30,
      color: Colors.white,
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          children: <Widget>[
            // 发布时间
            _buildTextTip(videoDetaill.videoInfo!.relTime!),
            _buldVerLine(),
            // 分类
            _buildTextTip(videoDetaill.videoInfo!.videoType!.name!),
            _buldVerLine(),
            // 评分
            _buildTextTip(videoDetaill.videoInfo!.videoRate.toString() + ' 分'),
            _buldVerLine(),
            // 语言
            _buildTextTip(videoDetaill.videoInfo!.language!),
            _buldVerLine(),
            // 发布地区
            _buildTextTip(videoDetaill.videoInfo!.subRegion!),
          ],
        ),
      ),
    );
  }

  // 收藏 分享 等
  Widget _buildMenuBtnGroups() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildInkWellButton(
              icon: Icons.star,
              cb: _joinLikeList,
              tagName: "收藏",
            ),
            _buildInkWellButton(
              icon: Icons.share,
              cb: _shareCurVideo,
              tagName: "分享",
            ),
          ],
        ),
      ),
    );
  }

  // 播放源按钮
  List<Widget> _createPlayBtns(
    List playList,
    String sourceName,
    EdgeInsetsGeometry padding,
    int rowId,
  ) {
    return playList.asMap().keys.map((int coldId) {
      return Padding(
        padding: padding,
        child: MyButton(
          title: playList[coldId].split('\$')[0],
          color: playFocus["row_id"] == rowId && playFocus["col_id"] == coldId
              ? Colors.blue
              : Colors.orange[700],
          cb: () async {
            List<String> curSource = playList[coldId].split('\$');
            setState(() {
              // 存当前源所在的项
              playFocus["row_id"] = rowId;
              playFocus["col_id"] = coldId;
              // 存播放源
              curPlayUrl = curSource[1];
              // 存播放标题
              curVideoShowTitle =
                  videoDetaill.videoInfo!.videoTitle! + ' - ' + curSource[0];
            });
            // 设置历史
            await historyService.add<VideoDetaillValueVideoInfo>(
              videoDetaill.videoInfo!,
              curSource[0],
              {
                "row_id": rowId,
                "col_id": coldId,
              },
            );
            // 设置播放源
            await player.reset();
            await player.setDataSource(curPlayUrl, autoPlay: true);
          },
        ),
      );
    }).toList();
  }

  // 播放源按钮行
  List<Widget> _createPlayBox(BuildContext context) {
    return videoDetaill.source!.asMap().keys.map((int rowId) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // 源标题
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // 每一组源的名称
                        videoDetaill.source![rowId]!.name!,
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ),
                  // 源更多
                  _buildInkWellSubscript(
                    tagName: "更多",
                    cb: () {
                      // 显示当前行的播放列表
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext sheetCtx) {
                          return Container(
                            height: 500,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 0,
                                  runSpacing: 0,
                                  children: _createPlayBtns(
                                    videoDetaill.source![rowId]!.list!,
                                    videoDetaill.source![rowId]!.name!,
                                    EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                    ),
                                    rowId,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _createPlayBtns(
                    videoDetaill.source![rowId]!.list!,
                    videoDetaill.source![rowId]!.name!,
                    EdgeInsets.all(5),
                    rowId,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // 播放源Box
  Widget _buildPlayerSource(BuildContext context) {
    return Column(
      children: <Widget>[
        // 当前卡片标题
        Container(
          height: 50,
          color: Colors.white,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              '播放列表',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Divider(height: 1),
        // 源列表
        Container(
          child: Column(
            children: videoDetaill.source!.length > 0
                ? _createPlayBox(context)
                : [
                    Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Text(
                            '暂无播放源 o(╯□╰)o',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ),
                      ),
                    )
                  ],
          ),
        ),
      ],
    );
  }

  // 视频播放器
  Widget _buildVideoPlayer(context) {
    return FijkView(
      height: 260,
      color: Colors.black,
      fit: FijkFit.cover,
      player: player,
      panelBuilder: (
        FijkPlayer player,
        FijkData data,
        BuildContext context,
        Size viewSize,
        Rect texturePos,
      ) {
        /// 使用自定义的布局
        return CustomFijkPanel(
          player: player,
          viewSize: viewSize,
          texturePos: texturePos,
          pageContent: context,
          playerTitle: videoDetaill.videoInfo!.videoTitle!,
          showConfig: vSkinCfg,
          curPlayUrl: curPlayUrl,
        );
      },
    );
  }

  // 底部弹窗 - 视频信息
  void _showVideoInfoModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      videoDetaill.videoInfo!.videoTitle!,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                // 年代，语言，分类，地区，评分
                _buildVideoTypeCrumb(),
                // 演员表
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: Colors.black12,
                      ),
                      bottom: BorderSide(
                        width: 1,
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              '导演： ${videoDetaill.videoInfo!.director!.isEmpty ? "暂无" : videoDetaill.videoInfo!.director}',
                              style: TextStyle(color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(
                              '主演： ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                      videoDetaill.videoInfo!.performer != null
                                          ? videoDetaill.videoInfo!.performer!
                                              .split(',')
                                              .join('  ')
                                          : "暂无")),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 简介
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('简介'),
                        ),
                        SizedBox(height: 8),
                        Container(
                          child: Text(
                            videoDetaill.videoInfo!.introduce!,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 视频信息
  Widget _buildVideoInfo(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // 恰饭
            PublicMealComponents<VideoDetaillValueMealList>(
              mealList: videoDetaill.mealList!,
              isRadius: false,
            ),
            // 头部 标题 更多
            _buildVideoInfoTitle(context),
            // 分类标签 评分，年代，语言，地区，分类
            _buildVideoTypeCrumb(),
            SizedBox(height: 5),
            // 收藏，分享 等等
            _buildMenuBtnGroups(),
            SizedBox(height: 5),
            // 播放源
            _buildPlayerSource(context),
            SizedBox(height: 5),
            // 视频推荐
            VideoTypeGroupComponents<GetCurNavItemListValueTabList>(
              videoGroup: likeMovieGroup!,
              bgColor: Colors.white,
              isPopRouter: true,
              routerPopEnter: () async {
                await player.stop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 上半部 视频播放器
          _buildVideoPlayer(context),
          // 下半部视频信息，剧集等
          _buildVideoInfo(context),
        ],
      ),
    );
  }
}
