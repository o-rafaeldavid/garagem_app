import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:typed_data/typed_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

const globalTopic = "estanciunamentu4000";
abstract class Topics{
  static List<String> subscribe = [
    "userresauth-$globalTopic",
    "portaestado-$globalTopic",
    "alerta-$globalTopic",
    "imagempedir-$globalTopic"
  ];

  static List<String> publish = [
    "userreqauth-$globalTopic",
    "portaacao-$globalTopic",
    "imagemenvia-$globalTopic"
  ];
}

class MQTTManager {
  late dynamic client;
  String broker = 'broker.hivemq.com';
  int port = 8000;
  final StreamController<String> _messageController = StreamController<String>();
  Stream<String> get messageStream => _messageController.stream;


  //////////////////////////////////////////////////////
  MQTTManager() {
    if(!kIsWeb){
      client = MqttServerClient(broker, '$globalTopic-app');
      port = 1883;
    }
    else{
      client = MqttBrowserClient("ws://$broker", 'estanciunamentu-app', maxConnectionAttempts: 100);
      port = 8000;
    }
    client.port = port;
    _connect();
  }

  //////////////////////////////////////////////////////
  void _connect() async {
    client.logging(on: true);

    client.onConnected = () {
      debugPrint('Connected to $broker:$port');
      Topics.subscribe.forEach((topic) {
        client.subscribe(topic, MqttQos.exactlyOnce);
      });
  
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        
        if (c.isNotEmpty){
          final MqttMessage mqttMessage = c[0].payload;
          final String msgTopic = c[0].topic;
          if (mqttMessage is MqttPublishMessage) {
            final String payload = MqttPublishPayload.bytesToStringAsString(mqttMessage.payload.message);
            
            if(Topics.subscribe.contains(msgTopic)){
              debugPrint("Recebido: [$msgTopic] $payload");
              _messageController.add("$msgTopic $payload");
            }
            else{ debugPrint("Recebido: [$msgTopic] TOPICO NEGADO | MENSAGEM: $payload"); }
          }
        }
      });
    };

    client.onDisconnected = () {
      debugPrint('Disconnected');
    };

    client.onSubscribed = (String topic) {
      debugPrint('Subscribed to $topic');
    };

    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      client.disconnect();
    }
  }

  void sendMessage(String message, String topicToSend) {
    if(Topics.publish.contains(topicToSend)){
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      final Uint8Buffer? payload = builder.payload;
      if (payload != null){
        client.publishMessage(topicToSend, MqttQos.exactlyOnce, payload);
        debugPrint("Enviado: [$topicToSend] $message");
      }
    }
    else{ throw Exception("O tópico $topicToSend não dá pa ___enviares___ pÁ! (OH BURRO)"); }
  }

  void onTopicDoIt(String topicRecieved, Function fun){
    if(Topics.subscribe.contains(topicRecieved)) fun;
    else{ throw Exception("O tópico $topicRecieved não dá pa ___receberes___ pÁ! (OH BURRO)"); }
  }

  void disconnect() {
    client.disconnect();
  }
}
