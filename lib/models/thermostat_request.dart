import 'dart:typed_data';

class ThermostatRequest {
  ThermostatRequest({
    required this.cmd0,
    required this.cmd,
    required this.buffer,
  }) : requestId = _requestId++;

  factory ThermostatRequest.fromBytes(Uint8List bytes) {
    final data = bytes.buffer.asByteData();
    final cmd0 = data.getInt16(0, Endian.little);
    final cmd = data.getInt16(2, Endian.little);
    final id = data.getInt16(4, Endian.little);
    return ThermostatRequest._(
      cmd0: cmd0,
      cmd: cmd,
      requestId: id,
      buffer: bytes.sublist(6),
    );
  }

  ThermostatRequest._({
    required this.cmd0,
    required this.cmd,
    required this.requestId,
    required this.buffer,
  });

  final int cmd0;
  final int cmd;
  final int requestId;
  final Uint8List buffer;
  static int _requestId = 0;

  List<int> toBytes() {
    return [
      cmd0 & 0xff,
      (cmd0 >> 8) & 0xff,
      cmd & 0xff,
      (cmd >> 8) & 0xff,
      requestId & 0xff,
      (requestId >> 8) & 0xff,
      ...buffer,
    ];
  }
}

typedef ThermostatResponse = ThermostatRequest;
