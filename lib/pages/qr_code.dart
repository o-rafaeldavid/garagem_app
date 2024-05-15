import 'package:flutter/material.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeWidget extends StatefulWidget{
  const QRCodeWidget({super.key});

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget>{
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? qrController;
  String result = "";

  @override
  void dispose(){
    qrController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController qrController){
    this.qrController = qrController;
    qrController.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code!;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(128),
        child: MyAppbar(name: "SCAN QR CODE")
      ),
      bottomNavigationBar: const Navbar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated
              )
            ),
            Text("resultado: $result")
          ]
        )
      )
    );
  }
}