import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/widget/imgState.dart';

// 历史记录，收藏 封面
// ignore: must_be_immutable
class HistoryVideoCover extends StatelessWidget {
  late String videoTitle;
  late String videoImage;
  late String coll_name;
  late String video_type;
  HistoryVideoCover(
    this.videoTitle,
    this.videoImage,
    this.coll_name,
    this.video_type, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            offset: Offset(0, 0),
            blurRadius: 3.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            offset: Offset(0, 0),
            blurRadius: 3.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            offset: Offset(0, 0),
            blurRadius: 3.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            offset: Offset(0, 0),
            blurRadius: 3.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              height: 80,
              width: 120,
              child: FadeInImage(
                placeholder: AssetImage('images/movie-lazy.gif'),
                image: NetworkImage(videoImage),
                imageErrorBuilder: (ctx, obj, trace) {
                  return ImgState(
                    msg: "加载失败",
                    icon: Icons.broken_image,
                  );
                },
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 80,
                alignment: Alignment.topLeft,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        videoTitle + ' ' + coll_name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('类型： ' + video_type),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
