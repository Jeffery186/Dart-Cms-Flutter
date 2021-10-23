// ignore_for_file: non_constant_identifier_names
abstract class VideoGroupInterFace<T> {
  String? name;
  List<T?>? list;
  Map<String, dynamic> toJson();
}

abstract class VideoGroupListChildInterFace {
  String? Id;
  String? videoTitle;
  String? director;
  String? videoImage;
  String? poster;
  String? performer;
  String? videoType;
  int? videoRate;
  String? updateTime;
  String? language;
  String? subRegion;
  String? relTime;
  String? introduce;
  String? remindTip;
  bool? popular;
  bool? allowReply;
  bool? openSwiper;
  bool? display;
  bool? scourceSort;
  Map<String, dynamic> toJson();
}
