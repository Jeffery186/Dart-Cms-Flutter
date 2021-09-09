import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/interface/mealItem.dart';
import 'package:dart_cms_flutter/utils/config.dart' show hostUrl;
import 'package:dart_cms_flutter/utils/openBrowser.dart' show launchUrl;
import 'package:dart_cms_flutter/widget/imgState.dart';

class PublicMealComponents<T extends MealInterFace> extends StatefulWidget {
  final List<T?>? mealList;
  final bool isRadius;
  PublicMealComponents({Key? key, required this.mealList, this.isRadius = true})
      : super(key: key);

  @override
  _PublicMealComponentsState createState() => _PublicMealComponentsState();
}

class _PublicMealComponentsState extends State<PublicMealComponents> {
  List<GestureDetector> _meals = [];

  List<GestureDetector> _buildMealChilds() {
    return widget.mealList!.map((cur) {
      // 恰饭图片地址
      String curMealImgUrl =
          cur!.path!.contains("http") ? cur.path! : hostUrl + cur.path!;
      // 恰饭链接
      String curMealLink = cur.link!;
      return GestureDetector(
        onTap: () {
          // 打开浏览器地址
          launchUrl(curMealLink);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 4),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isRadius ? 8 : 0),
              color: Color.fromRGBO(245, 245, 245, 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isRadius ? 8 : 0),
              child: FadeInImage(
                placeholder: AssetImage('images/banner-lazy.gif'),
                image: NetworkImage(curMealImgUrl),
                imageErrorBuilder: (context, obj, trace) {
                  return ImgState(
                    msg: "加载失败",
                    icon: Icons.broken_image,
                  );
                },
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _meals = _buildMealChilds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _meals,
    );
  }
}
