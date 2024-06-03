import 'package:flutter/material.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:garagem_app/widgets/warningInfo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeWidget extends StatefulWidget{
  const QRCodeWidget({super.key});

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> with RouteAware{
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? qrController;
  String result = "";
  bool _isVisible = true;
  bool _cameraPermissionGranted = false;

  final GarageStatusDB _garageStatusDB = GarageStatusDB();

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
  }

  Future<void> requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    setState(() {
      _cameraPermissionGranted = status.isGranted;
    });
  }

  @override
  void dispose(){
    qrController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isVisible = ModalRoute.of(context)?.isCurrent == true;
    if (_isVisible && qrController != null) {
      qrController!.resumeCamera();
    } else if(_isVisible) {
      qrController?.pauseCamera();
    }
  }

  void _onQRViewCreated(QRViewController qrController){
    this.qrController = qrController;
    qrController.scannedDataStream.listen((scanData) {
      if(scanData.code! == "authreq_local1_garage1") {
        setState(() {
          _cameraPermissionGranted = false;
        });
      }

      setState(() {
        result = scanData.code!;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(GlobalVars.appbarHeight),
        child: MyAppbar(name: "SCAN QR CODE")
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_cameraPermissionGranted) ...<Widget>[
                  Container(padding: const EdgeInsets.only(bottom: GlobalVars.appbarHeight), child: Column(children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 2 * GlobalVars.gap,
                      height: MediaQuery.of(context).size.width - 2 * GlobalVars.gap,
                      child: Stack(
                        children: <Widget>[
                          QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                          ),
                          Image.asset('lib/assets/icons/cut_cam.png')
                        ]
                      )
                    ),
                    Text("resultado: $result")
                  ])),
                ]
                else ...<Widget>[
                  WarningInfo(
                    type: "nocam",
                    text: "Without Camera Permission",
                    widgets: <Widget>[
                      RoundRect(
                        onTap: () { openAppSettings(); },
                        child: Text("Check Permissions", style: GoogleFonts.orbitron(textStyle: TxtStyles.paragraph(null, 0)))
                      )
                    ],
                  )
                ]
              ]
            )
          ),
          const Align(alignment: Alignment.bottomCenter, child: Navbar())
        ]
      )
    );
  }
}