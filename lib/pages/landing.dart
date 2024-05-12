import 'package:flutter/material.dart';
import 'package:garagem_app/mqtt.dart';
import 'package:garagem_app/widgets/navbar.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container()
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