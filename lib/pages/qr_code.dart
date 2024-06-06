import 'package:flutter/material.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/mqtt.dart';
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
  bool _isLoading = false;
  bool _onGarage = false;

  bool _qrInicializado = false;

  MQTTManager mqtt = MQTTManager();
  final GarageStatusDB _garageStatusDB = GarageStatusDB();

  @override
  void initState() {
    super.initState();
    mqtt.onSuccessResGaragem = _successResGaragem;
    mqtt.onFailResGaragem = _failResGaragem;
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
    if(!_isLoading){
      if (_isVisible && qrController != null) {
        qrController!.resumeCamera();
      } else {
        qrController?.pauseCamera();
      }
    }
  }

  void _successResGaragem(String payload){
    debugPrint("INFORMAÇÃO — Garagem QR Sucesso!");
    int startIndex = payload.indexOf("garage");
    int underscoreIndex = payload.indexOf("_", startIndex);
    String lowerFinal = payload.substring(startIndex, underscoreIndex);
    if(_qrInicializado){
      _garageStatusDB.create(title: lowerFinal[0].toUpperCase() + lowerFinal.substring(1)).then((res) => {
        Navigator.pushNamed(context, "/")
      });
    }
  }

  void _failResGaragem(){
    debugPrint("ERRO — Garagem QR bué sad!");
    if(_qrInicializado){
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onQRViewCreated(QRViewController qrController){
    this.qrController = qrController;
    qrController.scannedDataStream.listen((scanData) {

      if(checkAuthRequestQR(scanData.code!)) {
        _qrInicializado = true;
        mqtt.sendMessage(scanData.code!, Topics.publish[0] /* req garagem */);
        setState(() {
          _isLoading = true;
          qrController?.pauseCamera();
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
                if(!_isLoading && !_onGarage)
                  if (_cameraPermissionGranted) ...<Widget>[
                    Container(padding: const EdgeInsets.only(bottom: GlobalVars.appbarHeight + GlobalVars.gap), child: Column(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: GlobalVars.gap),
                        child: Text("SCAN YOUR GARAGE HERE", style: GoogleFonts.orbitron(textStyle: TxtStyles.heading2(null, 0))),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 2 * GlobalVars.gap,
                        height: MediaQuery.of(context).size.width - 2 * GlobalVars.gap,
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        )
                      ),
                      /* Text("resultado: $result") */
                    ])),
                  ]
                  else...<Widget>[
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
                else if(!_onGarage) Container(
                  padding: const EdgeInsets.only(bottom: GlobalVars.appbarHeight),
                  child: SizedBox( height: 2 * GlobalVars.iconSize, child: Image.asset('lib/assets/gifs/loading.gif'))
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