import 'package:flutter/material.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/model/garage_status.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GarageMiniInfo extends StatefulWidget{
  final GarageStatus? gStatus;
  final bool withActive;

  const GarageMiniInfo({
    super.key,
    required this.gStatus,
    this.withActive = false
  });

  @override
  State<GarageMiniInfo> createState() => _GarageMiniInfo();
}

class _GarageMiniInfo extends State<GarageMiniInfo>{
  late GarageStatus? gStatus;
  late bool? withActive = false;

  @override
  void initState() {
    super.initState();
    gStatus = widget.gStatus;
    withActive = widget.withActive;
  }
  
  @override
  Widget build(BuildContext context) {
  Size dimensions = MediaQuery.of(context).size;
  double widthGapped = dimensions.width - 3 * GlobalVars.gap;
  const double columnGap = 0.25 * GlobalVars.gap;

  DateFormat dateFormat = DateFormat("dd MMM yyyy");
  DateFormat timeFormat = DateFormat("HH'h'mm'min'");
  String formattedCreated = "${timeFormat.format(gStatus!.createdAt.toLocal())} | ${dateFormat.format(gStatus!.createdAt.toLocal())}";
  String formattedUpdated = (gStatus!.updatedAt != null) ? "${timeFormat.format(gStatus!.updatedAt!.toLocal())} | ${dateFormat.format(gStatus!.updatedAt!.toLocal())}" : "$formattedCreated (creation)";

  return RoundRectColumned(
      width: widthGapped,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Text>[
            Text(gStatus!.title, style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(AllCores.laranja(255), 8))),
            if(withActive != null && withActive!)
              (gStatus!.active)
                ? Text("Active", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(AllCores.verde(255), 8)))
                : Text("Not Active", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(AllCores.vermelho(255), 8)))
          ]
        ),
        const SizedBox(height: columnGap,),
        
        Text("Created At ", style: GoogleFonts.orbitron(color: AllCores.branco(200), textStyle: TxtStyles.paragraph(null, 0))),
        Text("$formattedCreated", style: GoogleFonts.orbitron(color: AllCores.branco(128), textStyle: TxtStyles.smallInfo(null, 0))),
        const SizedBox(height: columnGap* 0.5,),
        
        Text("Last Update: ", style: GoogleFonts.orbitron(color: AllCores.branco(200), textStyle: TxtStyles.paragraph(null, 0))),
        Text("$formattedUpdated${((gStatus!.active) ? "" : " (deletion)")}", style: GoogleFonts.orbitron(color: AllCores.branco(128), textStyle: TxtStyles.smallInfo(null, 0))),
        
      ]
    );
  }
}