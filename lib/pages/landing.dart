import 'package:flutter/material.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/mqtt.dart';
import 'package:garagem_app/widgets/appbar.dart';
import 'package:garagem_app/widgets/navbar.dart';
import 'package:garagem_app/widgets/round_rect.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  MQTTManager mqtt = MQTTManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(GlobalVars.appbarHeight),
        child: MyAppbar(name: "GARAGE\nDASHBOARD")
      ),
      bottomNavigationBar: const Navbar(),
      body: StreamBuilder<String>(
        stream: mqtt.messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Center(
                  child: Text(snapshot.data!,style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                ),
                ElevatedButton(
                  onPressed: () { Navigator.pushNamed(context, '/qr'); },
                  child: const Text("teste QR", style: TextStyle(color: Colors.black))
                ),
                ElevatedButton(
                  onPressed: () { mqtt.sendMessage("manel", Topics.publish[0]); },
                  child: const Text("teste mandar mqtt", style: TextStyle(color: Colors.black))
                ),
                const RoundRect(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Text("a")
                  )
                )
              ]
            );
          } else {
            return const Center(
              child: Text('À espera de mensagens boy...'),
            );
          }
        }
      )
    );
  }
}