import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/model/garage_status.dart';
import 'package:garagem_app/mqtt.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  MQTTManager mqtt = MQTTManager();
  GarageStatus? _lastRow;

  Future<void> _updateLastRow() async {
    print("BOTA BER");
    GarageStatusDB().getLastRow().then((lastRow) =>
      setState(() {
        _lastRow = lastRow;
        print(lastRow);
      })
    );
  }

  @override
  void initState() {
    super.initState();
    mqtt.onGarageStatusUpdated = _updateLastRow;
    _updateLastRow(); // Obter a última linha inicialmente
  }

  @override
  Widget build(BuildContext context) {
    Size dimensions = MediaQuery.of(context).size;
    double widthGapped = dimensions.width - 3 * GlobalVars.gap;
    double half_widthGapped = (MediaQuery.of(context).size.width - 5 * GlobalVars.gap) * 0.5;
    double quarter_widthGapped = (MediaQuery.of(context).size.width - 5 * GlobalVars.gap) * 0.25;

    List<List<Widget>> bentoBox = [
      <Widget>[
        RoundRectColumned(
          width: widthGapped,
          height: widthGapped * 0.25,
          children: <Widget>[ Text("Reserved Garage", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8))) ]
        ),
      ],
      //
      //
      //
      <Widget>[
        RoundRectColumned(
          color: AllCores.laranja(25),
          width: widthGapped,
          height: null,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[ Text("Check Garage on Maps", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(AllCores.laranja(255), 6))) ]
        ),
      ],
      //
      //
      //
      <Widget>[
        RoundRectColumned(
          width: 3 * quarter_widthGapped,
          height: widthGapped * 0.25,
          children: <Widget>[ Text("Status", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8))), ]
        ),
        RoundRectColumned(
          color: AllCores.vermelho(50),
          width: quarter_widthGapped,
          height: widthGapped * 0.25,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[ Icon(Icons.close_rounded, size: 1.3 * GlobalVars.iconSize, color: Colors.white) ]
        ),
      ],
      //
      //
      //
      <Widget>[
        RoundRectColumned(
          onTap: () {
            mqtt.sendMessage("abre-te sésamo", Topics.publish[1]);
          },
          color: AllCores.verde(25),
          width: half_widthGapped,
          height: half_widthGapped,
          children: <Widget>[
            Expanded(child: Text("Open\nGarage", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.verde(255), 8)))),
            Container(
              alignment: Alignment.bottomRight,
              height: GlobalVars.iconSize,
              child: Image.asset('lib/assets/icons/lock_unlocked.png')
            )
          ]
        ),
        RoundRectColumned(
          color: AllCores.laranja(25),
          width: half_widthGapped,
          height: half_widthGapped,
          children: <Widget>[
            Expanded( child: Text("Check\nCamera", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8)))),
            Container(
              alignment: Alignment.bottomRight,
              height: GlobalVars.iconSize,
              child: Image.asset('lib/assets/icons/linked_cam.png')
            )
          ]
        ),
      ],
      //
      //
      //
      <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("has been reserved for", textAlign: TextAlign.center, style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(null, 0))),
              Text("5hours 30minutes", textAlign: TextAlign.center, style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8)))
            ]
          )
        )
      ]
    ];

    return Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(GlobalVars.appbarHeight),
            child: MyAppbar(name: "GARAGE\nDASHBOARD")),
        /* bottomNavigationBar: const Navbar(), */
        body: Container(
          margin:
              const EdgeInsets.fromLTRB(GlobalVars.gap, 0, GlobalVars.gap, 0),
          child: Stack(children: <Widget>[
            SingleChildScrollView(
                child: Column(
              children:
                (_lastRow != null)
                ? ( bentoBox.map((bentoRow) {
                  return Container(
                      margin: const EdgeInsets.only(bottom: GlobalVars.gap),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: bentoRow));
                }).toList() )
                : const <Widget>[
                  Text("Teste")
                ]
              /* Center(
                  child: Text(snapshot.data!,style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                ),
                ElevatedButton(
                  onPressed: () { mqtt.sendMessage("manel", Topics.publish[0]); },
                  child: const Text("teste mandar mqtt", style: TextStyle(color: Colors.black))
                ), */
            )),
            const Align(alignment: Alignment.bottomCenter, child: Navbar())
          ]
        )
      )
    );
  }
}
