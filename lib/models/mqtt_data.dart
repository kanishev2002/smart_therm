import 'package:freezed_annotation/freezed_annotation.dart';

part 'mqtt_data.freezed.dart';
part 'mqtt_data.g.dart';

@freezed
class MQTTData with _$MQTTData {
  factory MQTTData({
    required String brokerIP,
    required String username,
    required String password,
  }) = _MQTTData;

  factory MQTTData.fromJson(Map<String, dynamic> json) => _$MQTTDataFromJson(json);
}
