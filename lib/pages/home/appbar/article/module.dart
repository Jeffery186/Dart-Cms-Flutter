import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// tools wiget
import 'package:dart_cms_flutter/utils/get_x_request.dart';
import 'package:dart_cms_flutter/router/pages.dart';
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/myLoading.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
// schema
import 'package:dart_cms_flutter/schema/get_article_list.dart';

class AppBarArticleView extends StatefulWidget {
  AppBarArticleView({Key? key}) : super(key: key);

  @override
  _AppBarArticleViewState createState() => _AppBarArticleViewState();
}

class _AppBarArticleViewState extends State<AppBarArticleView>
    with AutomaticKeepAliveClientMixin {
  int curPage = 0;
  int maxPage = 0;
  bool isShowFloatBtn = false;
  bool? isInit;
  // 0加载中 1加载成功 2空结果 3 失败
  int stateCode = 0;
  List<GetAllArtItemListValueList?> artList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = ScrollController();

  Future<GetAllArtItemList> pullArticleList(int newPage) async {
    Response res = await HttpUtils().x_get(
      url: "/app/getAllArtItemList",
      query: {
        "page": newPage.toString(),
      },
    );
    GetAllArtItemList fmtBody = GetAllArtItemList.fromJson(res.body);
    return fmtBody;
  }

  Future<void> savePullArticleList(int newPage, {Function? cb}) async {
    // 拉下所有的tabbar
    await pullArticleList(newPage).then((GetAllArtItemList body) {
      // 满足init条件，有数据，并且不是空数据，
      if (mounted) {
        if (cb != null) {
          cb();
        }
        setState(() {
          stateCode = body.value!.list!.length > 0 || isInit == true ? 1 : 2;
          if (stateCode == 1) {
            isInit = isInit ?? true;
          }
          if (body.value!.list!.length > 0) {
            curPage = newPage;
            maxPage = (body.value!.total! / 10).ceil();
            artList.addAll(body.value!.list!);
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
      print("发生错误， urlPath: /app/getAllArtItemList");
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
    await savePullArticleList(1, cb: () {
      setState(() {
        curPage = 0;
        maxPage = 0;
        artList = [];
      });
    });
    if (curPage >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Future<void> _loading() async {
    int newPage = curPage + 1;
    await savePullArticleList(newPage);
    if (curPage >= maxPage) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    savePullArticleList(1);
    _initScrollEvent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  AppBar _buildPulicAppBar() {
    return AppBar(
      title: Container(
        alignment: Alignment.bottomLeft,
        child: Text("文章列表"),
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
  // ignore: must_call_super
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
              GetAllArtItemListValueList item = artList[idx]!;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black12, width: 1),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      Map<String, String> query = {"id": item.Id!};
                      Get.toNamed(PageName.ARTICLE_DETAILL, arguments: query);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 60,
                          child: FadeInImage(
                            placeholder: AssetImage('images/movie-lazy.gif'),
                            image: NetworkImage(item.articleImage!),
                            imageErrorBuilder: (ctx, obj, trace) {
                              return ImgState(
                                msg: "加载失败",
                                icon: Icons.broken_image,
                              );
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            child: Text(
                              item.articleTitle!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            // itemExtent: 100.0,
            itemCount: artList.length,
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
