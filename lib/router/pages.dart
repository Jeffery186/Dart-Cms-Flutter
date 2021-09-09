import 'package:get/get.dart';
// page widget
import 'package:dart_cms_flutter/pages/home/module.dart';
import 'package:dart_cms_flutter/pages/video-detaill/module.dart';
import 'package:dart_cms_flutter/pages/article-detaill/module.dart';
import 'package:dart_cms_flutter/pages/search-video/module.dart';
import 'package:dart_cms_flutter/pages/user-declare/module.dart';
import 'package:dart_cms_flutter/pages/video-store/module.dart';
import 'package:dart_cms_flutter/pages/video-history/module.dart';
// controller
import 'package:dart_cms_flutter/pages/article-detaill/controller.dart';

abstract class PageName {
  // 首页
  static const HOME = '/';
  // 视频详情页
  static const VIDEO_DETAILL = '/video-detaill';
  // 文章详情页
  static const ARTICLE_DETAILL = '/article-detaill';
  // 视频搜索页
  static const VIDEO_SEARCH = '/video-search';
  // 许可协议 - 免责申明
  static const USER_DECLARE = '/user-declare';
  // 视频收藏
  static const VIDEO_STORE = '/video-store';
  // 视频历史记录
  static const VIDEO_HISTORY = '/video-history';
}

class PageRoutes {
  static const INIT_PAGE = PageName.HOME;
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: PageName.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      name: PageName.VIDEO_SEARCH,
      page: () => VideoSearchPage(),
    ),
    GetPage(
      name: PageName.VIDEO_DETAILL,
      page: () => VideoDetaillPage(),
    ),
    GetPage(
      name: PageName.ARTICLE_DETAILL,
      page: () => ArticleDetaillPage(),
      binding: BindingsBuilder.put(() => ArticleDetaillViewStore()),
    ),
    GetPage(
      name: PageName.USER_DECLARE,
      page: () => UserDeclarePage(),
    ),
    GetPage(
      name: PageName.VIDEO_STORE,
      page: () => VideoStorePage(),
    ),
    GetPage(
      name: PageName.VIDEO_HISTORY,
      page: () => VideoHistoryPage(),
    ),
  ];
}
