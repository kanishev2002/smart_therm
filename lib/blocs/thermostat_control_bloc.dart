import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/services/network_service.dart';

part 'thermostat_control_event.dart';

class ThermostatControlBloc
    extends HydratedBloc<ThermostatControlEvent, ThermostatControlState> {
  ThermostatControlBloc({required this.networkService})
      : super(
          ThermostatControlState(
            status: LoadingStatus.done,
            deviceData: [],
            customHeatingTemperature: 60,
            customHotWaterTemperature: 60,
          ),
        ) {
    on<FetchThermostatData>(_onFetchThermostatData);
    on<SelectDevice>(_onSelectDevice);
    on<ToggleBurner>(_onToggleBurner);
    on<AddDevice>(_onAddDevice);
    on<SetHeatingTemperature>(_onSetHeatingTemperature);
    on<SetWaterTemperature>(_onSetWaterTemperature);
    on<AppStartRefresh>(_onAppStartRefresh);
    on<UpdateDevice>(_onUpdateDevice);
    on<DeleteDevice>(_onDeleteDevice);
    on<AutomaticDataRefresh>(_onAutomaticDataRefresh);

    autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      _autoRefreshData,
    );
  }

  final NetworkService networkService;
  late final Timer autoRefreshTimer;

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
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      await networkService.connectToThermostat(state.deviceData[event.index]);
      emit(
        state.copyWith(
          selectedDevice: event.index,
          status: LoadingStatus.done,
        ),
      );
    } catch (e) {
      debugPrint('Could not select device: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  Future<void> _onToggleBurner(
    ToggleBurner event,
    Emitter<ThermostatControlState> emit,
  ) async {
    try {
      final burnerOn = state.deviceData[state.selectedDevice].data!.heatingOn;
      final updatedDevice =
          state.deviceData[state.selectedDevice].copyWith.data!(
        heatingOn: !burnerOn,
      );
      final newData = [...state.deviceData];
      await networkService.setParameters(updatedDevice);
      newData[state.selectedDevice] = updatedDevice;
      emit(state.copyWith(deviceData: newData));
    } catch (e) {
      debugPrint('Unable to turn off heating: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
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
          customHeatingTemperature: event.device.usePID ? 15 : 60,
          customHotWaterTemperature: 60,
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

  Future<void> _onSetHeatingTemperature(
    SetHeatingTemperature event,
    Emitter<ThermostatControlState> emit,
  ) async {
    try {
      final device = state.deviceData[state.selectedDevice];
      final updated = device.copyWith(
        heatingTemperature: event.temperature,
      );
      await networkService.setParameters(updated);
      final newData = [...state.deviceData];
      newData[state.selectedDevice] = updated;
      final customTemp =
          event.isCustom ? event.temperature : state.customHeatingTemperature;
      emit(
        state.copyWith(
          deviceData: newData,
          customHeatingTemperature: customTemp,
        ),
      );
    } catch (e) {
      debugPrint('Could not set heating temperature: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  Future<void> _onSetWaterTemperature(
    SetWaterTemperature event,
    Emitter<ThermostatControlState> emit,
  ) async {
    try {
      final device = state.deviceData[state.selectedDevice];
      final updated = device.copyWith(
        hotWaterTemperature: event.temperature,
      );
      await networkService.setParameters(updated);
      final newData = [...state.deviceData];
      newData[state.selectedDevice] = updated;
      final customTemp =
          event.isCustom ? event.temperature : state.customHotWaterTemperature;
      emit(
        state.copyWith(
          deviceData: newData,
          customHotWaterTemperature: customTemp,
        ),
      );
    } catch (e) {
      debugPrint('Could not set water temperature: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  Future<void> _onAppStartRefresh(
    AppStartRefresh event,
    Emitter<ThermostatControlState> emit,
  ) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      await networkService.connectToThermostat(
        state.deviceData[state.selectedDevice],
      );

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
      debugPrint('Could not refresh data: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }
  }

  Future<void> _onUpdateDevice(
    UpdateDevice event,
    Emitter<ThermostatControlState> emit,
  ) async {
    try {
      final currentDevice = state.deviceData[event.index];
      var updatedDevice = event.device;

      if (currentDevice.ip != updatedDevice.ip) {
        emit(state.copyWith(status: LoadingStatus.loading));
        await networkService.connectToThermostat(updatedDevice);
        final data = await networkService.getThermostatStatus();
        updatedDevice = updatedDevice.copyWith(data: data);
      }

      if (currentDevice.usePID != updatedDevice.usePID) {
        updatedDevice = updatedDevice.copyWith(
          heatingTemperature: updatedDevice.usePID ? 22 : 50,
        );
      }

      final updatedData = [...state.deviceData];
      updatedData[event.index] = updatedDevice;
      emit(
        state.copyWith(
          status: LoadingStatus.done,
          deviceData: updatedData,
        ),
      );
    } catch (e) {
      debugPrint('Could not update device: $e');
    }
  }

  Future<void> _onDeleteDevice(
    DeleteDevice event,
    Emitter<ThermostatControlState> emit,
  ) async {
    final updatedData = [...state.deviceData]..removeAt(event.index);
    emit(state.copyWith(deviceData: updatedData, status: LoadingStatus.done));
  }

  Future<void> _onAutomaticDataRefresh(
    AutomaticDataRefresh event,
    Emitter<ThermostatControlState> emit,
  ) async {
    try {
      if (state.status.isLoading) {
        await stream
            .firstWhere((newState) => !newState.status.isLoading)
            .timeout(const Duration(seconds: 5));
      }
      final data = await networkService.getThermostatStatus();
      final updatedDevice = state.deviceData[state.selectedDevice].copyWith(
        data: data,
      );
      final updatedDevices = [...state.deviceData];
      updatedDevices[state.selectedDevice] = updatedDevice;
      emit(state.copyWith(deviceData: updatedDevices));
    } catch (e) {
      debugPrint('Auto refresh failed: $e');
    }
  }

  void _autoRefreshData(Timer t) {
    add(const AutomaticDataRefresh());
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

  @override
  ThermostatControlState? fromJson(Map<String, dynamic> json) =>
      ThermostatControlState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ThermostatControlState state) => state.toJson();
}
