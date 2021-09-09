import 'package:flutter/material.dart';
import 'package:dart_cms_flutter/widget/userClause.dart';

class UserDeclarePage extends StatelessWidget {
  const UserDeclarePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('免责申明'),
      ),
      body: UserClause(),
    );
  }
}
