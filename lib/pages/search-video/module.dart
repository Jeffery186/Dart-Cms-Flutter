// ignore_for_file: must_be_immutable, non_constant_identifier_names, must_call_super
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// components
import 'package:dart_cms_flutter/components/videoItem.dart';
// widget
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';
import 'package:dart_cms_flutter/widget/myLoading.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
// utils
import 'package:dart_cms_flutter/utils/config.dart';
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/schema/get_video_search.dart';
// schema
import 'package:dart_cms_flutter/utils/get_x_request.dart';

// 搜索的封面
class SearchVideoCover extends StatelessWidget {
  String videoImage;
  SearchVideoCover(this.videoImage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 190,
      child: FadeInImage(
        placeholder: AssetImage('images/lazy.gif'),
        image: NetworkImage(videoImage),
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

// 单独视频按钮
class MyVideoBtn extends VideoItem {
  String Id;
  String btnText;
  Color color;
  MyVideoBtn({
    required this.Id,
    required this.btnText,
    this.color = Colors.blue,
  }) : super(Id: Id, child: Container());

  open(BuildContext context) {
    super.openVideo(context);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        backgroundColor: MaterialStateProperty.all(color),
      ),
      onPressed: () => open(context),
      child: Text(
        btnText,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class VideoSearchPage extends StatefulWidget {
  VideoSearchPage({Key? key}) : super(key: key);

  @override
  _VideoSearchPageState createState() => _VideoSearchPageState();
}

class _VideoSearchPageState extends State<VideoSearchPage>
    with AutomaticKeepAliveClientMixin {
  int stateCode = 2;
  String curSearchVal = "";
  int curPage = 0;
  int maxPage = 0;
  bool? isInit;
  bool isShowFloatBtn = false;
  List<getSearchDatasValueSearchResultList?> searchList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = ScrollController();
  FocusNode _commentFocus = FocusNode();
  bool? isFocus;

  Future<getSearchDatas> pullVideoSearch(int newPage) async {
    Response res = await HttpUtils().xGet(
      url: "/app/getSearchDatas",
      query: {
        "page": newPage.toString(),
        "name": curSearchVal,
      },
    );
    getSearchDatas fmtBody = getSearchDatas.fromJson(res.body);
    return fmtBody;
  }

  Future<void> savePullVideoSearch(int newPage, {Function? cb}) async {
    // 拉下所有的tabbar
    await pullVideoSearch(newPage).then((body) {
      if (mounted) {
        if (cb != null) {
          cb();
        }
        setState(() {
          stateCode =
              body.value!.searchResult!.list!.length > 0 || isInit == true
                  ? 1
                  : 2;
          if (stateCode == 1) {
            isInit = isInit ?? true;
          }
          if (body.value!.searchResult!.list!.length > 0) {
            curPage = newPage;
            maxPage = (body.value!.searchResult!.total! / 10).ceil();
            searchList.addAll(body.value!.searchResult!.list!);
          }
        });
      }
      // 拉下所有的
    }).catchError((err) {
      if (isInit == null) {
        if (mounted) {
          setState(() {
            stateCode = 3;
          });
        }
      } else {
        publicToast("加载失败");
      }
      print("发生错误， urlPath: /app/getSearchDatas");
    });
  }

  void _initScrollEvent() {
    _scrollController.addListener(() {
      if (_scrollController.offset < 1000 && isShowFloatBtn) {
        setState(() {
          isShowFloatBtn = false;
        });
      } else if (_scrollController.offset >= 1000 && isShowFloatBtn == false) {
        setState(() {
          isShowFloatBtn = true;
        });
      }
    });
  }

  Future<void> _refresh() async {
    _refreshController.refreshCompleted(resetFooterState: true);
    await savePullVideoSearch(1, cb: () {
      this.setState(() {
        curPage = 0;
        maxPage = 0;
        searchList = [];
      });
    });

    if (curPage >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Future<void> _loading() async {
    int nextPage = curPage + 1;
    await savePullVideoSearch(nextPage);
    if (curPage >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    _initScrollEvent();
  }

  @override
  void dispose() {
    _commentFocus.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // 生成appbar
  AppBar _buildPublicAppBar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      title: TextField(
        style: TextStyle(color: Colors.white),
        focusNode: _commentFocus,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        onChanged: (val) {
          setState(() {
            curSearchVal = val;
          });
        },
        onSubmitted: (val) async {
          setState(() {
            stateCode = 0;
          });
          _commentFocus.unfocus();
          // 执行搜索
          await _refresh();
        },
      ),
      actions: [
        MyIconButton(
          icon: Icon(Icons.search),
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            _commentFocus.unfocus();
            // 执行搜索
            await _refresh();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    // 焦点
    if (isFocus == null) {
      isFocus = true;
      FocusScope.of(context).requestFocus(_commentFocus);
    }
    if (stateCode == 0) {
      body = Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyLoading(message: "加载中"),
      );
    } else if (stateCode == 1) {
      body = Scaffold(
        appBar: _buildPublicAppBar(),
        floatingActionButton: isShowFloatBtn
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(.0,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease);
                },
                child: Icon(Icons.arrow_upward),
              )
            : null,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          footer: CustomFooter(
            builder: (context, mode) {
              Widget? body;
              if (mode == LoadStatus.idle) {
                body = Text("上拉加载");
              } else if (mode == LoadStatus.loading) {
                body = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(width: 20),
                    Text('内容加载中'),
                  ],
                );
              } else if (mode == LoadStatus.failed) {
                body = Text("加载失败！点击重试！");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("松手,加载更多！");
              } else if (mode == LoadStatus.noMore) {
                body = Text("没有更多数据了！");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          child: ListView.builder(
            itemBuilder: (BuildContext ctx, int idx) {
              getSearchDatasValueSearchResultList item = searchList[idx]!;
              String videoImgUrl = item.videoImage!.contains("http")
                  ? item.videoImage!
                  : hostUrl + item.videoImage!;
              return Padding(
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                  top: 5,
                ),
                child: Row(
                  children: <Widget>[
                    VideoItem(
                      Id: item.Id!,
                      // 当前搜索的封面
                      child: SearchVideoCover(videoImgUrl),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              item.videoTitle!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('类型： '),
                                Text(item.videoType!.name!),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('年代： '),
                                Text(item.relTime!),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('语言： '),
                                Text(item.language!),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('地区： '),
                                Text(item.subRegion!),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          MyVideoBtn(
                            Id: item.Id!,
                            btnText: "播放",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            // itemExtent: 100.0,
            itemCount: searchList.length,
            controller: _scrollController,
          ),
          onRefresh: _refresh,
          onLoading: _loading,
          controller: _refreshController,
        ),
      );
    } else if (stateCode == 2) {
      body = Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyState(
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            // 重新加载
            await _refresh();
          },
          icon: Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "暂无内容",
        ),
      );
    } else if (stateCode == 3) {
      body = Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyState(
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            // 重新加载
            await _refresh();
          },
          icon: Icon(
            Icons.pest_control,
            size: 100,
            color: Colors.red,
          ),
          text: "加载失败",
        ),
      );
    } else {
      body = Container();
    }
    return body;
  }

  @override
  bool get wantKeepAlive => true;
}
