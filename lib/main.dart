import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// page
import 'package:dart_cms_flutter/router/pages.dart';
// utils
import 'package:dart_cms_flutter/utils/get_x_request.dart';
import 'package:dart_cms_flutter/utils/config.dart';
import 'package:dart_cms_flutter/utils/storage.dart';
// global controller
import 'package:dart_cms_flutter/service/videoHistory.dart';
import 'package:dart_cms_flutter/service/videoStore.dart';

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    imageCache.maximumSize = 10000;
    imageCache.maximumSizeBytes = 2097152000;
    return imageCache;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true;
  if (kReleaseMode) {
    CustomImageCache();
  }
  await initStore();
  runApp(MyApp());
}

Future<void> initStore() async {
  // request
  HttpUtils().init(baseUrl: hostUrl);
  // store utils
  await StorageUtil().init();
  // global controller video histroty
  await Get.putAsync(() => HistoryService().init());
  // global controller localhost store video
  await Get.putAsync(() => StoreService().init());
  print("全局注入");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // designSize: Size(375, 812),
      builder: () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: PageName.HOME,
        getPages: PageRoutes.routes,
      ),
    );
  }
}
