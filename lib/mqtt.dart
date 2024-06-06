import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:typed_data/typed_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

const globalTopic = "estanciunamentu4000";
abstract class Topics{
  static final List<String> subscribe = [
    "userresauthgaragem-$globalTopic",
    "portaestado-$globalTopic",
    "alerta-$globalTopic",
    "imagemenvia-$globalTopic"
  ];

  static final List<String> publish = [
    "userreqauthgaragem-$globalTopic",
    "portaacao-$globalTopic",
    "imagempedir-$globalTopic"
  ];
}

///
///
///
bool checkAuthRequestQR(String scanString){
  RegExp regex = RegExp(r'^authreq_local\d+_garage\d+$');
  return regex.hasMatch(scanString);
}

bool checkAuthResponseMQTT(String mqttString){
  RegExp regex = RegExp(r'^local\d+_garage\d+_sim$');
  return regex.hasMatch(mqttString);
}
///
///
///

class MQTTManager {
  late dynamic client;
  String broker = 'broker.hivemq.com';
  int port = 8000;
  final StreamController<String> _messageController = StreamController<String>();
  Stream<String> get messageStream => _messageController.stream;
  ///
  Function? onGarageStatusUpdated;
  Function? onSuccessResGaragem;
  Function? onFailResGaragem;
  Function? onSuccessCamera;
  bool _readingCamera = false;
  String _savedCameraRead = "";
  final GarageStatusDB _garageStatusDB = GarageStatusDB();


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

              ///
              if (msgTopic == Topics.subscribe[1] /* porta estado */ && !_readingCamera) {
                String porta_estado = payload;
                _garageStatusDB.updateLastGarage(porta_estado: porta_estado);
                if (onGarageStatusUpdated != null) { onGarageStatusUpdated!(); }
              }
              else if (msgTopic == Topics.subscribe[0] /* res garagem */ && !_readingCamera) {
                if (checkAuthResponseMQTT(payload) && onSuccessResGaragem != null) { onSuccessResGaragem!(payload); }
                else if (!checkAuthResponseMQTT(payload) && onFailResGaragem != null) { onFailResGaragem!(); }
              } 
              else if(msgTopic == Topics.subscribe[3] /* receber garagem */ && onSuccessCamera != null){
                print(payload);
                if(!_readingCamera && payload == "#####__STARTCAMERA__#####"){
                  _readingCamera = true;
                }
                else{
                  if(payload == "#####__FINISHCAMERA__#####"){
                    _readingCamera = false;
                    onSuccessCamera!(_savedCameraRead);
                    _savedCameraRead = "";
                  }
                  else{
                    _savedCameraRead = _savedCameraRead + payload;
                    print("NEW");
                    print(_savedCameraRead);
                    print("FINISH NEW");
                  }
                }
              }
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
    debugPrint(topicToSend);
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
