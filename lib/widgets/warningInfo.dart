import 'package:flutter/material.dart';
import 'package:garagem_app/main.dart';
import 'package:google_fonts/google_fonts.dart';

class WarningInfo extends StatelessWidget {
  final String type;
  final String text;
  final List<Widget> widgets;

  const WarningInfo({
    super.key,
    required this.type,
    required this.text,
    this.widgets = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: GlobalVars.appbarHeight),
        child: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(bottom: 0.5 * GlobalVars.gap),
                child: (type == "warning")
                    ? const Icon(Icons.warning_rounded,
                        size: 2 * GlobalVars.iconSize, color: Colors.white)
                    : (type == "nocam")
                        ? SizedBox(
                            height: 1.7 * GlobalVars.iconSize,
                            child: Image.asset('lib/assets/icons/cut_cam.png'))
                        : (type == "nohistory")
                            ? SizedBox(
                                height: 1.7 * GlobalVars.iconSize,
                                child: Image.asset(
                                    'lib/assets/icons/history_off.png'))
                            : const Text("")),
            Container(
              margin: const EdgeInsets.only(bottom: GlobalVars.gap),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                      textStyle: TxtStyles.heading2(
                          (type == "warning" || type == "nohistory")
                              ? AllCores.amarelo(255)
                              : (type == "nocam")
                                  ? AllCores.vermelho(255)
                                  : AllCores.background(0),
                          8))),
            ),
            ...widgets
          ],
        ));
  }
}
