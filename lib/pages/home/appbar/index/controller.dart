import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/schema/get_appbar_type.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
import 'package:get/get.dart';

class AppbarIndexViewStore extends GetxController
    with SingleGetTickerProviderMixin, StateMixin {
  late TabController tabController;
  RxList tabBarList = [].obs;

  Future<GetTypeList> pullHomeTypeList() async {
    Response res = await HttpUtils().x_get(url: "/app/getTypeList");
    GetTypeList fmtBody = GetTypeList.fromJson(res.body);
    return fmtBody;
  }

  Future<void> savePullHomeTypeList() async {
    change("加载中", status: RxStatus.loading());
    // 初始化tabController
    tabController = TabController(vsync: this, length: 0);
    // 拉下所有的tabbar
    await pullHomeTypeList().then((GetTypeList body) {
      // 先清空，后设置新的
      tabBarList.removeWhere((element) => true);
      tabBarList.addAll(body.value!);
      // 设置新的tabbar
      tabController = TabController(vsync: this, length: tabBarList.length);
      // 拉下所有的
      change(
        "成功",
        status: body.value!.length > 0 ? RxStatus.success() : RxStatus.empty(),
      );
    }).catchError((err) {
      change("失败", status: RxStatus.error());
      print("发生错误， urlPath: /app/getTypeList");
    });
  }

  @override
  void onInit() {
    super.onInit();
    savePullHomeTypeList();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
