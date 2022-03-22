import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class FlutterAccuraKyc {
  static const MethodChannel _channel =
      const MethodChannel('flutter_accura_kyc');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getMetaData() async {
    final String result = await _channel.invokeMethod('getMetaData');
    return result;
  }

  static Future<String> setupAccuraConfig(dynamic object) async {
    final String result = await _channel
        .invokeMethod('setupAccuraConfig', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startOcrWithCard(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startOcrWithCard', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startMRZ(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startMRZ', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startBankCard(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startBankCard', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startBarcode(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startBarcode', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startFaceMatch(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startFaceMatch', {'arguments': jsonEncode(object)});
    return result;
  }

  static Future<String> startLiveness(dynamic object) async {
    final String result = await _channel
        .invokeMethod('startLiveness', {'arguments': jsonEncode(object)});
    return result;
  }
}
