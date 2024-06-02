part of 'network_service.dart';

class _MQTTNetworkService implements _NetworkServiceImpl {
  late final MqttServerClient _client;
  var _currentData = ThermostatData(
    heatingOn: false,
    hotWaterOn: false,
    hasTemperatureSensors: false,
    actualHeatingTemperature: 20,
    actualHotWaterTemperature: 20,
    roomTemperature1: 0,
    roomTemperature2: 0,
    miscellaneousData: MiscellaneousData(
      secondHeatingCircuitAvailable: false,
      burnerOn: false,
      openThermStatus: 0,
      boilerStatus: 0,
      returningTemp: 0,
      modulation: 0,
      pressure: 0,
    ),
  );
  static const _topics = [
    'aha/ST/ST_BoilerT/stat_t',
    'aha/ST/ST_Boiler/mode_stat_t',
    'aha/ST/ST_Toutdoor/stat_t',
    'aha/ST/ST_Tindoor/stat_t',
    'aha/ST/ST_Flame/stat_t',
    'aha/ST/ST_OT/stat_t',
    'aha/ST/ST_RetT/stat_t',
    'aha/ST/ST_Modulation/stat_t',
    'aha/ST/ST_Pressure/stat_t',
  ];

  late final _handlers = [
    _boilerTempHandler,
    _heatingOnHandler,
    _t1SensorHandler,
    _t2SensorHandler,
    _burnerOnHandler,
    _openThermStatusHandler,
    _returningTermperatureHandler,
    _modulationHandler,
    _pressureHandler,
  ];

  @override
  Future<void> connectToThermostat(Thermostat device) async {
    final credentials = device.mqttData!;
    final client = MqttServerClient(credentials.brokerIP, '')
      ..setProtocolV311()
      ..keepAlivePeriod = 60
      ..onConnected = (() => debugPrint('Connected to ${credentials.brokerIP}'))
      ..onDisconnected = (() => debugPrint('Disconnected from mqtt'))
      ..onSubscribed = ((s) => debugPrint('Subscribed: $s'))
      ..onSubscribeFail = (s) => debugPrint('Subscribe failed: $s');

    await client.connect(
      credentials.username,
      credentials.password,
    );

    for (final topic in _topics) {
      client.subscribe(topic, MqttQos.exactlyOnce);
    }

    final updatesBroadcast = client.updates!.expand((element) => element).asBroadcastStream();

    assert(
      _topics.length == _handlers.length,
      'There should be the same amount of topics and handlers',
    );

    for (var i = 0; i < _topics.length; ++i) {
      final topic = _topics[i];
      final handler = _handlers[i];
      updatesBroadcast.where((event) => event.topic == topic).listen(handler);
    }

    _client = client;
  }

  @override
  Future<ThermostatData> getThermostatStatus() async {
    return _currentData;
  }

  @override
  Future<void> setParameters(Thermostat device) async {
    final thermostatSettings = device.data!;
    if (_currentData.heatingOn != thermostatSettings.heatingOn) {
      final builder = MqttClientPayloadBuilder()
        ..addString(thermostatSettings.heatingOn ? 'heat' : 'off');
      _client.publishMessage('aha/ST/ST_Boiler/mode_cmd_t', MqttQos.atLeastOnce, builder.payload!);
    }
    final builder = MqttClientPayloadBuilder()
      ..addString((device.heatingTemperature * 100).toString());
    _client.publishMessage('aha/ST/ST_Boiler/temp_cmd_t', MqttQos.atLeastOnce, builder.payload!);
  }

  void _boilerTempHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final currentTemperature = double.parse(MqttPublishPayload.bytesToStringAsString(message));
    _currentData = _currentData.copyWith(actualHeatingTemperature: currentTemperature);
  }

  void _heatingOnHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final mode = MqttPublishPayload.bytesToStringAsString(message);
    _currentData = _currentData.copyWith(heatingOn: mode == 'heat');
  }

  void _t1SensorHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final temperature = MqttPublishPayload.bytesToStringAsString(message);
    if (temperature == 'None') {
      return;
    }
    _currentData = _currentData.copyWith(
      hasTemperatureSensors: true,
      roomTemperature1: double.parse(temperature),
    );
  }

  void _t2SensorHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final temperature = MqttPublishPayload.bytesToStringAsString(message);
    if (temperature == 'None') {
      return;
    }
    _currentData = _currentData.copyWith(
      hasTemperatureSensors: true,
      roomTemperature2: double.parse(temperature),
    );
  }

  void _burnerOnHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final status = MqttPublishPayload.bytesToStringAsString(message);

    _currentData = _currentData.copyWith.miscellaneousData(burnerOn: status == 'ON');
  }

  void _openThermStatusHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final status = MqttPublishPayload.bytesToStringAsString(message);

    _currentData =
        _currentData.copyWith.miscellaneousData(openThermStatus: status == 'ON' ? 0 : -1);
  }

  void _errorStatusHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final status = MqttPublishPayload.bytesToStringAsString(message);

    if (status != 'нет') {
      _currentData = _currentData.copyWith.miscellaneousData(openThermStatus: 2);
    }
  }

  void _returningTermperatureHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final temperature = MqttPublishPayload.bytesToStringAsString(message);

    _currentData =
        _currentData.copyWith.miscellaneousData(returningTemp: double.parse(temperature));
  }

  void _modulationHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final modulation = MqttPublishPayload.bytesToStringAsString(message);

    _currentData = _currentData.copyWith.miscellaneousData(modulation: double.parse(modulation));
  }

  void _pressureHandler(MqttReceivedMessage<MqttMessage> event) {
    final message = (event.payload as MqttPublishMessage).payload.message;
    final pressure = MqttPublishPayload.bytesToStringAsString(message);

    _currentData = _currentData.copyWith.miscellaneousData(pressure: double.parse(pressure));
  }
}
