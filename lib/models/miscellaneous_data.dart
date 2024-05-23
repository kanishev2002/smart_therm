import 'package:freezed_annotation/freezed_annotation.dart';

part 'miscellaneous_data.freezed.dart';
part 'miscellaneous_data.g.dart';

@freezed
class MiscellaneousData with _$MiscellaneousData {
  factory MiscellaneousData({
    required bool secondHeatingCircuitAvailable,
    required bool burnerOn,
    required int openThermStatus,
    required int boilerStatus,
    required double returningTemp,
    required double modulation,
    required double pressure,
  }) = _MiscellaneousData;

  factory MiscellaneousData.fromJson(Map<String, dynamic> json) =>
      _$MiscellaneousDataFromJson(json);
}
