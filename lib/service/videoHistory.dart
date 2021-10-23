// ignore_for_file: invalid_use_of_protected_member
import 'package:get/get.dart';
// utils
import 'package:dart_cms_flutter/utils/storage.dart';
// interface
import 'package:dart_cms_flutter/interface/videoDetaill.dart';

// 全局响应数据
class HistoryService extends GetxService {
  // 历史记录
  RxList<dynamic> hisList = [].obs;

  Future<HistoryService> init() async {
    List<Map<String, dynamic>> hisData =
        List.from(StorageUtil().getJSON("history") ?? []);
    hisList.addAll(hisData);
    return this;
  }

  Future<bool> add<T extends VideoDetaillInterFace>(
    T obj,
    String curPlayBtnName,
    Map<String, int> playFocus,
  ) async {
    // 插入一条新的
    String newKey = obj.Id!;
    // 检查是否存在
    bool isExist = hisList.any((el) => el["Id"] == newKey);
    // 是否超出限制50个存储配额, 并且当前历史记录中没有这个视频
    if (hisList.length >= 50 && !isExist) {
      hisList.removeLast();
    }
    // 当前的id是否已经存在
    if (isExist) {
      // 存在就删除，重新插入，变化位置，插入到最前
      hisList.removeWhere((el) => el["Id"] == newKey);
    }
    // 当前视频的数据 formant
    Map<String, dynamic> curVideoMap = _formantVideoDetaill(
      playFocus,
      curPlayBtnName,
      obj,
    );
    // 插入新的
    hisList.insert(0, curVideoMap);
    // 存入
    return StorageUtil().setJSON('history', hisList.value);
  }

  Future<bool> removeKey(String keyName) async {
    hisList.removeWhere((element) => true);
    return StorageUtil().remove(keyName);
  }

  Map<String, dynamic> _formantVideoDetaill<T extends VideoDetaillInterFace>(
    Map<String, int> playFocus,
    String curPlayBtnName,
    T obj,
  ) {
    return {
      "Id": obj.Id,
      "videoTitle": obj.videoTitle,
      "director": obj.director,
      "poster": obj.performer,
      "videoImage": obj.videoImage,
      "video_type": obj.videoType!.name,
      "video_rate": obj.videoRate,
      "update_time": obj.updateTime,
      "language": obj.language,
      "sub_region": obj.subRegion,
      "rel_time": obj.relTime,
      "introduce": obj.introduce,
      "remind_tip": obj.remindTip,
      "popular": obj.popular,
      "allow_reply": obj.allowReply,
      "display": obj.display,
      "scource_sort": obj.scourceSort,
      // player cur index
      "row_id": playFocus["row_id"],
      "col_id": playFocus["col_id"],
      // cur focus play btn name
      "coll_name": curPlayBtnName,
    };
  }
}
