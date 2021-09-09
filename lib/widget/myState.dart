import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/widget/myButton.dart';

typedef ButtonCb = void Function();

class MyState extends StatelessWidget {
  final ButtonCb? cb;
  final Icon icon;
  final String text;
  const MyState(
      {Key? key, required this.cb, required this.icon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          MyButton(
            title: text,
            cb: cb,
          ),
        ],
      ),
    );
  }
}
