import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/model/garage_status.dart';
import 'package:garagem_app/mqtt.dart';
import 'package:garagem_app/navigation_helper.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/garageMiniInfo.dart';
import 'package:garagem_app/widgets/warningInfo.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with RouteAware{
  MQTTManager mqtt = MQTTManager();
  GarageStatus? _lastRow;
  Timer? _timerReserved;
  DateTime _reservedTime = DateTime.now().toUtc();
  String _reservedString = "";
  bool _isVisible = true;
  bool _landingTOCameraInicializado = false;

  @override
  void initState() {
    super.initState();
    mqtt.onGarageStatusUpdated = _updateLastRow;
    mqtt.onSuccessCamera = (String payload) {
      if(_landingTOCameraInicializado){
        Navigator.pushNamed(context, "/camera");
      }
    };
    _updateLastRow().then((_) {
      print("JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ");
      _startTimerReserved();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isVisible = ModalRoute.of(context)?.isCurrent == true;
    if (!_isVisible){
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      print(_timerReserved == null);
      _timerReserved?.cancel();
    }
  }

  void _startTimerReserved() {
    _timerReserved = Timer.periodic(const Duration(seconds: 1), (timer) {
      Duration duration = DateTime.now().toUtc().difference(_reservedTime);
      final int day = duration.inDays;
      final String dayString = "${day} day${day == 1 ? "" : "s"} ";
      final int hour = duration.inHours.remainder(24);
      final String hourString = (hour > 0) ? "${hour}hour${hour == 1 ? "" : "s"} " : "";
      final int minutes = duration.inMinutes.remainder(60);
      final String minutesString = "${minutes}minute${minutes == 1 ? "" : "s"}";
      /* print("now: ${DateTime.now().toUtc()}");
      print("reserved: $_reservedTime");
      print("duration: $duration"); */
      setState(() {
        _reservedString = (day == 0) ? "$hourString $minutesString" : "$dayString $hourString";
      });
    });
  }


  Future<void> _updateLastRow() async {
    print("BOTA BER");
    GarageStatusDB().getLastRow().then((lastRow) =>
      setState(() {
        _lastRow = lastRow;
        print(lastRow);
      })
    );
  }

  Future<void> _goMaps({String? query = ""}) async {
    String search = (query == "") ? "" : "search/$query";
    Uri uri = Uri(scheme: 'https', host: 'www.google.com', path: 'maps/$search');
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size dimensions = MediaQuery.of(context).size;
    double widthGapped = dimensions.width - 3 * GlobalVars.gap;
    double half_widthGapped = (MediaQuery.of(context).size.width - 5 * GlobalVars.gap) * 0.5;
    double quarter_widthGapped = (MediaQuery.of(context).size.width - 5 * GlobalVars.gap) * 0.25;
    const double columnGap = 0.25 * GlobalVars.gap;


    List<List<Widget>> bentoBox(GarageStatus gStatus) {
      _reservedTime = gStatus.createdAt;
      return [
        <Widget>[
          GarageMiniInfo(gStatus: gStatus)
        ],
        <Widget>[
          RoundRectColumned(
            onTap: () {_goMaps(query: gStatus.title);},
            color: AllCores.laranja(25),
            width: widthGapped,
            height: null,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[ Text("Check Garage on Maps", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(AllCores.laranja(255), 6))) ]
          ),
        ],
        <Widget>[
          RoundRectColumned(
            width: 3 * quarter_widthGapped,
            height: widthGapped * 0.25,
            children: <Widget>[
              Text("Status", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8))),
              const SizedBox(height: columnGap,),
              if(gStatus.porta_estado == "Open" || gStatus.porta_estado == "Opening") Row(children: <Widget>[
                Text(gStatus.porta_estado, style: GoogleFonts.orbitron(color: AllCores.amarelo(255), textStyle: TxtStyles.paragraph(null, 0))),
                const SizedBox(width: columnGap * 0.7),
                const Icon(Icons.warning_rounded, size: 0.53 * GlobalVars.iconSize, color: Colors.white)
              ])
              else Text(gStatus.porta_estado, style: GoogleFonts.orbitron(color: AllCores.branco(128), textStyle: TxtStyles.paragraph(null, 0)))
            ]
          ),
          RoundRectColumned(
            onTap: () {
              GarageStatusDB().updateLastGarage(active: false).then((_) {
                _updateLastRow();
              });
            },
            color: AllCores.vermelho(50),
            width: quarter_widthGapped,
            height: widthGapped * 0.25,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[ Icon(Icons.close_rounded, size: 1.3 * GlobalVars.iconSize, color: Colors.white) ]
          ),
        ],
        <Widget>[
          RoundRectColumned(
            onTap: () {
              if(gStatus.porta_estado != "Opening" || gStatus.porta_estado != "Closing"){
                if(gStatus.porta_estado == "Closed"){ mqtt.sendMessage("abre-te sésamo", Topics.publish[1]); }
                else{ mqtt.sendMessage("fecha-te chia", Topics.publish[1]); }
              }
            },
            color: (gStatus.porta_estado == "Open") ? AllCores.vermelho(50) : (gStatus.porta_estado == "Closed") ? AllCores.verde(25) : AllCores.amarelo(25),
            width: half_widthGapped,
            height: half_widthGapped,
            children: <Widget>[
              Expanded(child: 
              (gStatus.porta_estado != "Opening" || gStatus.porta_estado != "Closing")
                ? (gStatus.porta_estado == "Open")
                    ? Text("Close\nGarage", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.vermelho(255), 8)))
                    : Text("Open\nGarage", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.verde(255), 8)))
                : Text(gStatus.porta_estado, style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.amarelo(255), 8)))
              ),
              Container(
                alignment: Alignment.bottomRight,
                height: GlobalVars.iconSize,
                child: Image.asset('lib/assets/icons/lock_${(gStatus.porta_estado == "Open") ? "" : "un"}locked.png')
              )
            ]
          ),
          RoundRectColumned(
            onTap: () {
              setState(() {
                _landingTOCameraInicializado = true;
              });
              mqtt.sendMessage("", Topics.publish[2]);
            },
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
        <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("has been reserved for", textAlign: TextAlign.center, style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(null, 0))),
                Text(_reservedString, textAlign: TextAlign.center, style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8))),
                const SizedBox(height: GlobalVars.appbarHeight)
              ]
            )
          )
        ]
      ];
    }


    return Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(GlobalVars.appbarHeight),
            child: MyAppbar(name: "GARAGE\nDASHBOARD")),
        /* bottomNavigationBar: const Navbar(), */
        body: Stack(children: <Widget>[
          (!_landingTOCameraInicializado)
            ? (_lastRow != null && _lastRow!.active) ? Container(
                margin: const EdgeInsets.all(GlobalVars.gap),
                child: SingleChildScrollView(
                  child: Column(
                    children: bentoBox(_lastRow!).map((bentoRow) {
                        return Container(
                        margin: const EdgeInsets.only(bottom: GlobalVars.gap),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: bentoRow));
                      }).toList()
                    )
                )
              )
              : Center(child: 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:<Widget>[
                    WarningInfo(
                      type: "warning",
                      text: "Without Garage Associated",
                      widgets: <Widget>[
                          RoundRect(
                            onTap: () { Navigator.pushNamed(context, NavigationHelper.routes[1]); },
                            child: Text("Scan QR Code", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(null, 0)))
                          )
                        ],
                    )
                  ]
                )
              )
            : Center(child: 
                Container(
                  padding: const EdgeInsets.only(bottom: GlobalVars.appbarHeight),
                  child: SizedBox( height: 2 * GlobalVars.iconSize, child: Image.asset('lib/assets/gifs/loading.gif'))
                )
              ),

            const Align(alignment: Alignment.bottomCenter, child: Navbar())
          ]
        )
    );
  }
}
