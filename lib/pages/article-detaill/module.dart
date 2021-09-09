import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
// widget
import 'package:dart_cms_flutter/components/publicMeal.dart';
import 'package:dart_cms_flutter/widget/myLoading.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
// controller
import 'package:dart_cms_flutter/pages/article-detaill/controller.dart';
// schema
import 'package:dart_cms_flutter/schema/get_article_detaill.dart';

class ArticleDetaillPage extends GetView<ArticleDetaillViewStore> {
  @override
  Widget build(BuildContext context) {
    AppBar _buildPublicAppBar() {
      return AppBar(
        title: Text("文章详情"),
      );
    }

    return controller.obx(
      (state) => Scaffold(
        appBar: _buildPublicAppBar(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(height: 10),
                // 标题
                Container(
                  child: Text(
                    controller
                        .artInfo!.value!.articleResult!.cur!.articleTitle!,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 10),
                // 类型，时间
                Row(
                  children: <Widget>[
                    Text(
                        '类型：${controller.artInfo!.value!.articleResult!.cur!.articleType}'),
                    Text(' / '),
                    Text(
                        '时间：${controller.artInfo!.value!.articleResult!.cur!.updateTime}')
                  ],
                ),
                // 恰饭
                PublicMealComponents<GetCurArticleDetillValueMealList>(
                    mealList: controller.artInfo!.value!.mealList!),
                // 正文
                Html(
                    data:
                        controller.artInfo!.value!.articleResult!.cur!.content),
              ],
            ),
          ),
        ),
      ),
      onLoading: Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyLoading(message: "正在加载"),
      ),
      onError: (state) => Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyState(
          cb: () async {
            await controller
                .savePullCurArticleDetaill(controller.aid.toString());
          },
          icon: Icon(
            Icons.pest_control,
            size: 100,
            color: Colors.red,
          ),
          text: "加载错误",
        ),
      ),
    );
  }
}
