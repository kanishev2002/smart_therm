import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/services/network_service.dart';

part 'thermostat_control_event.dart';

class ThermostatControlBloc
    extends Bloc<ThermostatControlEvent, ThermostatControlState> {
  ThermostatControlBloc({required this.networkService})
      : super(ThermostatControlState(deviceData: [])) {
    on<FetchThermostatData>(_onFetchThermostatData);
    on<SelectDevice>(_onSelectDevice);
    on<ToggleBurner>(_onToggleBurner);
    on<AddDevice>(_onAddDevice);
    on<SetHeatingTemperature>(_onSetHeatingTemperature);
    on<SetWaterTemperature>(_onSetWaterTemperature);
    //on<SetUsePID>(_onSetUsePID);
  }

  final NetworkService networkService;

  Future<void> _onFetchThermostatData(
    FetchThermostatData event,
    Emitter<ThermostatControlState> emit,
  ) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    if (state.deviceData.isEmpty) {
      emit(state.copyWith(status: LoadingStatus.done));
      return;
    }
    try {
      final status = await networkService.getThermostatStatus();
      final devices = state.deviceData
          .mapIndexed(
            (idx, device) => idx == state.selectedDevice
                ? device.copyWith(
                    data: status,
                  )
                : device,
          )
          .toList();
      emit(
        state.copyWith(
          status: LoadingStatus.done,
          deviceData: devices,
        ),
      );
    } catch (e) {
      debugPrint('Error loading devices data: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  Future<void> _onSelectDevice(
    SelectDevice event,
    Emitter<ThermostatControlState> emit,
  ) async {
    await networkService.connectToThermostat(state.deviceData[event.index]);
    emit(
      state.copyWith(
        selectedDevice: event.index,
      ),
    );
  }

  void _onToggleBurner(
    ToggleBurner event,
    Emitter<ThermostatControlState> emit,
  ) {
    final burnerOn = state.deviceData[state.selectedDevice].data!.heatingOn;
    final newData = [...state.deviceData];
    newData[state.selectedDevice] =
        newData[state.selectedDevice].copyWith.data!(
      heatingOn: !burnerOn,
    );
    emit(state.copyWith(deviceData: newData));
  }

  Future<void> _onAddDevice(
    AddDevice event,
    Emitter<ThermostatControlState> emit,
  ) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      final deviceInfo =
          await networkService.fetchNewThermostatData(event.device);

      final thermostatWithData = event.device.copyWith(data: deviceInfo);
      final newData = [
        ...state.deviceData,
        thermostatWithData,
      ];

      if (newData.length == 1) {
        await networkService.connectToThermostat(thermostatWithData);
      }

      emit(
        state.copyWith(
          deviceData: newData,
          status: LoadingStatus.done,
        ),
      );

      // final mockData = ThermostatData(
      //   heatingOn: true,
      //   hotWaterOn: true,
      //   heatingTemperature: 10,
      //   hotWaterTemperature: 10,
      //   roomTemperature1: 10,
      //   roomTemperature2: 10,
      // );

      // emit(
      //   state.copyWith(
      //     deviceData: [
      //       ...state.deviceData,
      //       event.device.copyWith(data: mockData),
      //     ],
      //   ),
      // );
    } catch (e) {
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  void _onSetHeatingTemperature(
    SetHeatingTemperature event,
    Emitter<ThermostatControlState> emit,
  ) {
    final device = state.deviceData[state.selectedDevice];
    final updated = device.copyWith(
      heatingTemperature: event.temperature,
    );
    networkService.setParameters(updated);
    final newData = [...state.deviceData];
    newData[state.selectedDevice] = updated;
    emit(state.copyWith(deviceData: newData));
  }

  void _onSetWaterTemperature(
    SetWaterTemperature event,
    Emitter<ThermostatControlState> emit,
  ) {
    final device = state.deviceData[state.selectedDevice];
    final updated = device.copyWith(
      hotWaterTemperature: event.temperature,
    );
    networkService.setParameters(updated);
    final newData = [...state.deviceData];
    newData[state.selectedDevice] = updated;
    emit(state.copyWith(deviceData: newData));
  }

  @override
  void onTransition(
    Transition<ThermostatControlEvent, ThermostatControlState> transition,
  ) {
    super.onTransition(transition);
    const encoder = JsonEncoder.withIndent('  ');

    debugPrint('''
> > > T H E R M O S T A T   C O N T R O L   B L O C
Current state: 
${encoder.convert(transition.currentState.toJson())}

Next state:
${encoder.convert(transition.nextState.toJson())}
''');
  }
}
