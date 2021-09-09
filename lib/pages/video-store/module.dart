import 'package:flutter/material.dart';
import 'package:get/get.dart';
// utils
import 'package:dart_cms_flutter/utils/toast.dart';
// widget
import 'package:dart_cms_flutter/widget/myState.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/historyCover.dart';
// components
import 'package:dart_cms_flutter/components/videoItem.dart';
// global controller
import 'package:dart_cms_flutter/service/videoStore.dart';

class VideoStorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreService storeService = Get.put(StoreService());

    // 读取全局控制器中的历史记录
    List<Widget> _buildStoreVideoList() {
      return storeService.storeList.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: VideoItem(
            Id: item["Id"],
            // 历史记录的封面，收藏的封面
            child: HistoryVideoCover(
              item["videoTitle"],
              item["videoImage"],
              "",
              item["video_type"],
            ),
          ),
        );
      }).toList();
    }

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text("视频收藏"),
          actions: [
            MyIconButton(
              icon: Icon(Icons.restore_from_trash),
              cb: () {
                storeService.removeKey("store").then((res) {
                  publicToast("删除成功");
                  storeService.storeList = [].obs;
                }).catchError((err) {
                  publicToast("删除失败");
                });
              },
            ),
          ],
        ),
        body: storeService.storeList.length > 0
            ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Column(
                    children: _buildStoreVideoList(),
                  ),
                ),
              )
            : MyState(
                cb: () {
                  publicToast("暂无内容");
                },
                icon: Icon(
                  Icons.new_releases,
                  size: 100,
                  color: Colors.red,
                ),
                text: "暂无内容",
              ),
      ),
    );
  }
}
