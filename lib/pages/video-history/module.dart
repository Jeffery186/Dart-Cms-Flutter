import 'package:flutter/material.dart';
import 'package:get/get.dart';
// glabel controller
import 'package:dart_cms_flutter/service/videoHistory.dart';
// widget
import 'package:dart_cms_flutter/utils/toast.dart';
import 'package:dart_cms_flutter/widget/myState.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';
import 'package:dart_cms_flutter/widget/historyCover.dart';
// components
import 'package:dart_cms_flutter/components/videoItem.dart';

class VideoHistoryPage extends StatelessWidget {
  const VideoHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistoryService historyService = Get.put(HistoryService());
    // 读取全局控制器中的历史记录
    List<Widget> _buildStoreVideoList() {
      return historyService.hisList.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: VideoItem(
            Id: item["Id"],
            playFocus: {
              "row_id": item["row_id"],
              "col_id": item["col_id"],
            },
            // 历史记录的封面，收藏的封面
            child: HistoryVideoCover(
              item["videoTitle"],
              item["videoImage"],
              item["coll_name"],
              item["video_type"],
            ),
          ),
        );
      }).toList();
    }

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text("历史记录"),
          actions: [
            MyIconButton(
              icon: Icon(Icons.restore_from_trash),
              cb: () {
                historyService.removeKey("history").then((res) {
                  publicToast("删除成功");
                  historyService.hisList = [].obs;
                }).catchError((err) {
                  print(err);
                  publicToast("删除失败");
                });
              },
            ),
          ],
        ),
        body: historyService.hisList.length > 0
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
