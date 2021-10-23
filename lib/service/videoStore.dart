// ignore_for_file: invalid_use_of_protected_member
import 'package:get/get.dart';
// utils
import 'package:dart_cms_flutter/utils/storage.dart';
// interface
import 'package:dart_cms_flutter/interface/videoDetaill.dart';

// 全局响应数据
class StoreService extends GetxService {
  // 历史记录
  RxList<dynamic> storeList = [].obs;

  Future<StoreService> init() async {
    List<Map<String, dynamic>> storeData =
        List.from(StorageUtil().getJSON("store") ?? []);
    storeList.addAll(storeData);
    return this;
  }

  Future<bool> add<T extends VideoDetaillInterFace>(
    T obj,
  ) async {
    // 插入一条新的
    String newKey = obj.Id!;
    // 检查是否存在
    bool isExist = storeList.any((el) => el["Id"] == newKey);
    // 是否超出限制50个存储配额, 并且当前历史记录中没有这个视频
    if (storeList.length >= 50 && !isExist) {
      storeList.removeLast();
    }
    // 当前的id是否已经存在
    if (isExist) {
      // 存在就删除，重新插入，变化位置，插入到最前
      storeList.removeWhere((el) => el["Id"] == newKey);
    }
    // 当前视频的数据 formant
    Map<String, dynamic> curVideoMap = _formantVideoDetaill(
      obj,
    );
    // 插入新的
    storeList.insert(0, curVideoMap);
    // 存入
    return StorageUtil().setJSON('store', storeList.value);
  }

  Future<bool> removeKey(String keyName) async {
    storeList.removeWhere((element) => true);
    return StorageUtil().remove(keyName);
  }

  Map<String, dynamic> _formantVideoDetaill<T extends VideoDetaillInterFace>(
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
    };
  }
}
