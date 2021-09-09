import 'package:dart_cms_flutter/schema/get_article_detaill.dart';
import 'package:dart_cms_flutter/utils/get_x_request.dart';
import 'package:get/get.dart';

class ArticleDetaillViewStore extends GetxController with StateMixin {
  RxString aid = "".obs;
  GetCurArticleDetill? artInfo;

  Future<GetCurArticleDetill> pullCurArticleDetaill(String aid) async {
    Response res = await HttpUtils().x_get(url: "/app/getArtDetill/" + aid);
    GetCurArticleDetill fmtBody = GetCurArticleDetill.fromJson(res.body);
    return fmtBody;
  }

  Future<void> savePullCurArticleDetaill(String aid) async {
    change("加载中", status: RxStatus.loading());
    // 拉下所有的tabbar
    await pullCurArticleDetaill(aid).then((GetCurArticleDetill body) {
      artInfo = body;
      // 拉下所有的
      change("成功", status: RxStatus.success());
    }).catchError((err) {
      change("失败", status: RxStatus.error());
      print("发生错误， urlPath: /app/getArtDetill");
    });
  }

  @override
  void onInit() {
    super.onInit();
    aid.value = Get.arguments["id"];
    savePullCurArticleDetaill(aid.value);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
