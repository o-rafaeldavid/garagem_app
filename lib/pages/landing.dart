import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garagem_app/mqtt.dart';

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
      /* body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Center(
            child: Text(mqtt.recieved),
          ),
        ]
      ) */
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: Container(
          padding: const EdgeInsets.only(top: 32),
          child: const Column(
            children: <Widget>[
              Text("TESTE AAA")
            ]
          )
        )
      ),
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
                  child: const Text("teste", style: TextStyle(color: Colors.black))
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