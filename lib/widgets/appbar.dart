import 'package:flutter/material.dart';
import 'package:garagem_app/main.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(GlobalVars.gap, 0, GlobalVars.gap, GlobalVars.gap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                name,
                textAlign: TextAlign.left,
                style: GoogleFonts.orbitron(
                  textStyle: TxtStyles.heading1(AllCores.laranja(255), 14)
                ),
              )
            ],
          )
        )
      ]
    );
  }
}