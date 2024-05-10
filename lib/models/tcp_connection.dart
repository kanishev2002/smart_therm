import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smart_therm/models/thermostat_request.dart';

class TCPConnection {
  TCPConnection({
    required this.ip,
    this.port = 6769,
  });

  Future<bool> start() async {
    if (_active) {
      return true;
    }
    try {
      _connection = await Socket.connect(ip, port, timeout: _timeout);
      _outputStream = _connection.asBroadcastStream();

      final success = await _handshake();
      _active = success;

      _outputStream.listen(
        (event) {
          debugPrint(
            'Receiver data from socket: ${ThermostatResponse.fromBytes(event)}',
          );
        },
        onDone: () {
          _active = false;
          debugPrint('Socket closed');
        },
        onError: (Object error) {
          debugPrint('Socket error: $error');
        },
      );

      return success;
    } catch (e) {
      debugPrint('Could not establish connection: $e');
      rethrow;
    }
  }

  Future<ThermostatResponse> submitRequest(ThermostatRequest request) async {
    if (!_active) {
      await start();
    }
    _connection.add(request.toBytes());
    await _connection.flush();
    final response = await _outputStream.first.timeout(_timeout);

    return ThermostatResponse.fromBytes(response);
  }

  Future<void> close() async {
    if (_active) {
      await _connection.flush();
    }
    await _connection.close();
    _active = false;
  }

  Future<bool> _handshake() async {
    const handshakeCmd = 0x2020;
    final request = ThermostatRequest(
      cmd0: 0x22,
      cmd: handshakeCmd,
      buffer: ascii.encode(_handshakeRequest),
    );

    _connection.add(request.toBytes());
    await _connection.flush();
    final responseBuffer = await _outputStream.first.timeout(_timeout);

    final response = ThermostatResponse.fromBytes(responseBuffer);
    final handshakeResponse = ascii.decode(response.buffer);

    return handshakeResponse == _handshakeResponse;
  }

  bool _active = false;
  final InternetAddress ip;
  final int port;
  late Socket _connection;
  late Stream<Uint8List> _outputStream;
  static const _handshakeRequest = 'TCPiptEsT\x00';
  static const _handshakeResponse = 'ipTCPTeSt\x00';
  static const _timeout = Duration(seconds: 5);
}
