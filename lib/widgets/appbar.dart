import 'package:flutter/material.dart';

class MyAppbar extends StatefulWidget{
  final String name;
  const MyAppbar({super.key, required this.name});

  @override
  State<MyAppbar> createState() => _MyAppbarState();
}

class _MyAppbarState extends State<MyAppbar>{
  late String name;

  @override
  void initState() {
    super.initState();
    name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(name)
        ],
      )
    );
  }
}