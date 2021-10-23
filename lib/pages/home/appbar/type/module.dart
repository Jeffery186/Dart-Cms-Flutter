// ignore_for_file: non_constant_identifier_names, must_be_immutable, must_call_super
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// widget
import 'package:dart_cms_flutter/router/pages.dart';
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/widget/myLoading.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
import 'package:dart_cms_flutter/widget/openLoading.dart';
// components
import 'package:dart_cms_flutter/components/videoItem.dart';
// utls
import 'package:dart_cms_flutter/utils/config.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
// schema
import 'package:dart_cms_flutter/schema/get_all_video_types.dart';
// interface
import 'package:dart_cms_flutter/interface/videoGroup.dart';

// formantJson
class SortFrom {
  String Id;
  String name;
  Function? cb;
  SortFrom({required this.Id, required this.name, cb});
}

class TypeColButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isActive;
  final int borRadiusNum;
  Function? cb;
  TypeColButton({
    Key? key,
    required this.text,
    required this.color,
    required this.isActive,
    required this.borRadiusNum,
    this.cb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            child: Text(
              text,
              style: TextStyle(color: isActive ? Colors.white : Colors.black),
            ),
          ),
        ),
        onTap: () {
          if (cb != null) {
            cb!();
          }
        },
      ),
    );
  }
}

class AppBarVideoTypeView extends StatefulWidget {
  AppBarVideoTypeView({Key? key}) : super(key: key);

  @override
  _AppBarVideoTypeViewState createState() => _AppBarVideoTypeViewState();
}

class _AppBarVideoTypeViewState extends State<AppBarVideoTypeView>
    with AutomaticKeepAliveClientMixin {
  bool? isInit;
  int stateCode = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<AllTypesDatasValueCurQueryListList?>? curQueryList = [];
  AllTypesDatasValueAllTypeItem? allTypeItem;
  AllTypesDatasValueCurQueryList? curQueryListModule;

  ScrollController _scrollController = ScrollController();
  bool isShowFloatBtn = false;

  int maxPage = 0;

  // params query
  Map<String, String> params = {
    'cid': '',
    'pid': '',
    'rel_time': '',
    'sub_region': '',
    'language': '',
    'page': '1',
    'sort': '_id'
  };
  List<SortFrom> sortList = [
    SortFrom(Id: '_id', name: '时间'),
    SortFrom(Id: 'rate', name: '人气'),
  ];

  // 加工query参数
  Map<String, String> _getQuery(int newPage) {
    Map<String, String> newParams = {};
    params.forEach((key, value) {
      newParams[key] = value;
      if (key == 'page') {
        newParams[key] = newPage.toString();
      }
    });
    return newParams;
  }

  Future<AllTypesDatas> _pullData(int newPage) async {
    Response res = await HttpUtils().xGet(
      url: "/app/getTypesDatas",
      query: _getQuery(newPage),
    );
    AllTypesDatas fmtBody = AllTypesDatas.fromJson(res.body);
    return fmtBody;
  }

  Future<void> _savePullData(int newPage, {Function? cb}) async {
    await _pullData(newPage).then((body) {
      if (mounted) {
        if (cb != null) {
          cb(true);
        }
        setState(() {
          stateCode =
              body.value!.curQueryList!.list!.length > 0 || isInit == true
                  ? 1
                  : 2;
          if (stateCode == 1) {
            isInit = isInit ?? true;
          }
          // 有数据就往上 加
          if (body.value!.curQueryList!.list!.length > 0) {
            int curPage = body.value!.curQueryList!.page!;
            maxPage = (body.value!.curQueryList!.total! / 36).ceil();
            params['page'] = curPage.toString();
            //
            curQueryList!.addAll(body.value!.curQueryList!.list!);
            allTypeItem = body.value!.allTypeItem;
            curQueryListModule = body.value!.curQueryList;
          }
        });
      }
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
      print("发生错误， urlPath: /app/getTypesDatas");
    });
  }

  Future<void> _refresh() async {
    _refreshController.refreshCompleted(resetFooterState: true);
    await _savePullData(1, cb: (bool isSuccess) {
      this.setState(() {
        params['page'] = '1';
        maxPage = 0;
        curQueryList = [];
      });
    });

    int curPageUpdateVal = int.parse(params['page']!);
    if (curPageUpdateVal >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Future<void> _loading() async {
    int curPage = int.parse(params['page']!);
    int nextPage = curPage + 1;
    await _savePullData(nextPage);
    int curPageUpdateVal = int.parse(params['page']!);
    if (curPageUpdateVal >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
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

  @override
  void initState() {
    super.initState();
    _savePullData(1);
    _initScrollEvent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  Widget _buildLayoutCol<E extends VideoGroupListChildInterFace>(
      {List<E?>? videoGroupList}) {
    final int topLen = videoGroupList!.length;
    final int rowItemLen = 3;
    List<Widget> child = [];
    for (var i = 0; i < topLen; i += rowItemLen) {
      int ml = i + rowItemLen;
      List<Widget> curChild = [];
      for (var j = i; j < ml; j++) {
        Widget curItem;
        if (j < topLen) {
          String videoImgUrl = videoGroupList[j]!.videoImage!.contains("http")
              ? videoGroupList[j]!.videoImage!
              : hostUrl + videoGroupList[j]!.videoImage!;
          curItem = Expanded(
            flex: 1,
            child: VideoItem(
              Id: videoGroupList[j]!.Id!,
              // 公共封面
              child: PublicVideoCover(
                videoTitle: videoGroupList[j]!.videoTitle!,
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
    return Column(
      children: child,
    );
  }

  // 生成分类行中的各种细分类按钮
  List<Widget> _createTypeLine(
      List arr, String paramKey, BuildContext context) {
    return arr.map((item) {
      return Padding(
        padding: EdgeInsets.only(right: 4),
        child: TypeColButton(
          text: item.name,
          borRadiusNum: 0,
          cb: () async {
            // 设置当前params参数
            setState(() {
              params[paramKey] = item.Id;
            });
            showLoading(context);
            await _refresh();
            hideLoading(context);
          },
          isActive: params[paramKey] == item.Id,
          color: params[paramKey] == item.Id ? Colors.blue : Colors.white12,
        ),
      );
    }).toList();
  }

  // 生成 分类行
  Widget _createTypesBox(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(allTypeItem!.nav!.label!),
              Text('：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(
                        allTypeItem!.nav!.list!, 'pid', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(allTypeItem!.type!.label!),
              Text('：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(
                        allTypeItem!.type!.list!, 'cid', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(allTypeItem!.region!.label!),
              Text('：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(
                        allTypeItem!.region!.list!, 'sub_region', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(allTypeItem!.years!.label!),
              Text('：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(
                        allTypeItem!.years!.list!, 'rel_time', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(allTypeItem!.language!.label!),
              Text('：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(
                        allTypeItem!.language!.list!, 'language', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text('排序：'),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(sortList, 'sort', context),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  AppBar _buildPulicAppBar() {
    return AppBar(
      title: Container(
        alignment: Alignment.bottomLeft,
        child: Text("视频分类"),
      ),
      actions: [
        MyIconButton(
          icon: Icon(Icons.search),
          cb: () {
            print('跳转到搜索');
            Get.toNamed(PageName.VIDEO_SEARCH);
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    // 0加载中 1加载成功 2空结果 3 失败
    if (stateCode == 0) {
      body = Scaffold(
        appBar: _buildPulicAppBar(),
        body: MyLoading(message: "加载中"),
      );
    } else if (stateCode == 1) {
      body = Scaffold(
        appBar: _buildPulicAppBar(),
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
              if (idx == 0) {
                return _createTypesBox(context);
              }
              if (idx == 1) {
                return curQueryList!.length > 0
                    ? _buildLayoutCol(videoGroupList: curQueryList)
                    : Container(
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.new_releases, size: 100),
                              SizedBox(height: 5),
                              Text("暂无数据 o(╯□╰)o"),
                            ],
                          ),
                        ),
                      );
              }
              return Container();
            },
            // itemExtent: 100.0,
            itemCount: 2,
            controller: _scrollController,
          ),
          onRefresh: _refresh,
          onLoading: _loading,
          controller: _refreshController,
        ),
      );
    } else if (stateCode == 2) {
      body = Scaffold(
        appBar: _buildPulicAppBar(),
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
        appBar: _buildPulicAppBar(),
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
