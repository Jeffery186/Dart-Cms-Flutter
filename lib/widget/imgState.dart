import 'package:flutter/material.dart';

class ImgState extends StatelessWidget {
  final String msg;
  final IconData icon;
  ImgState({
    required this.msg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(245, 245, 245, 1),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black26),
            SizedBox(height: 3),
            Text(msg, style: TextStyle(color: Colors.black26))
          ],
        ),
      ),
    );
  }
}
