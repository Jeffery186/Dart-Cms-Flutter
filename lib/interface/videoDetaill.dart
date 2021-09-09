abstract class VideoDetaillInterFace<S> {
  String? Id;
  String? videoTitle;
  String? director;
  String? videoImage;
  String? poster;
  String? performer;
  S? videoType;
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
}

abstract class VideoDetaillValueSourceInterFace {
  String? Id;
  int? index;
  String? name;
  String? zName;
  String? type;
  List<String?>? list;
  String? vid;
}
