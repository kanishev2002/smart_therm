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
  }

  final NetworkService networkService;

  Future<void> _onFetchThermostatData(
    FetchThermostatData event,
    Emitter<ThermostatControlState> emit,
  ) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      final devices = await networkService.getThermostats();
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

  void _onSelectDevice(
    SelectDevice event,
    Emitter<ThermostatControlState> emit,
  ) {
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
    final burnerOn = state.deviceData[state.selectedDevice].heatingOn;
    final newData = [...state.deviceData];
    newData[state.selectedDevice] = newData[state.selectedDevice].copyWith(
      heatingOn: !burnerOn,
    );
    emit(state.copyWith(deviceData: newData)); // Update list
  }

  void _onAddDevice(
    AddDevice event,
    Emitter<ThermostatControlState> emit,
  ) {
    final newData = [...state.deviceData, event.device];
    emit(state.copyWith(deviceData: newData));
  }

  void _onSetHeatingTemperature(
    SetHeatingTemperature event,
    Emitter<ThermostatControlState> emit,
  ) {
    final device = state.deviceData[state.selectedDevice].copyWith(
      heatingTemperature: event.temperature.toDouble(),
    );
    final newData = [...state.deviceData];
    newData[state.selectedDevice] = device;
    emit(state.copyWith(deviceData: newData));
  }

  void _onSetWaterTemperature(
    SetWaterTemperature event,
    Emitter<ThermostatControlState> emit,
  ) {
    final device = state.deviceData[state.selectedDevice].copyWith(
      hotWaterTemperature: event.temperature.toDouble(),
    );
    final newData = [...state.deviceData];
    newData[state.selectedDevice] = device;
    emit(state.copyWith(deviceData: newData));
  }
}
