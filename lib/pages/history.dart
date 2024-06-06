import 'package:flutter/material.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/model/garage_status.dart';
import 'package:garagem_app/navigation_helper.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/garageMiniInfo.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:garagem_app/widgets/warningInfo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget{
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>{
  List<GarageStatus>? _allGarages;

  Future<void> _updateAllGarages() async {
    print("BOTA BER GARAGENS");
    GarageStatusDB().getAll(reverse: true).then((allGarages) =>
      setState(() {
        _allGarages = allGarages;
    print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        print(allGarages);
        print(allGarages.isEmpty);
      })
    );
  }

  @override
  void initState() {
    super.initState();
    _updateAllGarages();
  }

  List<Widget> _buildRectsAllGarages(List<GarageStatus> allGarages){
    return allGarages.map((gStatus) {
      return Opacity(opacity: (gStatus.active) ? 1 : 0.5, child: Container(
        margin: const EdgeInsets.only(bottom: GlobalVars.gap),
        child: GarageMiniInfo(gStatus: gStatus, withActive: true)
      ));
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(GlobalVars.appbarHeight),
        child: MyAppbar(name: "GARAGE HISTORY")
      ),
      body: Stack(
        children: <Widget>[
          if(_allGarages != null)
            (_allGarages!.isNotEmpty)
            ? Container(
              margin: const EdgeInsets.all(GlobalVars.gap),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRectsAllGarages(_allGarages!)
                )
              )
            )
            : Center(child: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget>[
                  WarningInfo(
                    type: "nohistory",
                    text: "You don't have any\nGarages on History",
                    widgets: <Widget>[
                        RoundRect(
                          onTap: () { Navigator.pushNamed(context, NavigationHelper.routes[1]); },
                          child: Text("Scan QR Code", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(null, 0)))
                        )
                      ],
                  )
                ]
              )
            ),
          const Align(alignment: Alignment.bottomCenter, child: Navbar())
        ]
      )
    );
  }
}