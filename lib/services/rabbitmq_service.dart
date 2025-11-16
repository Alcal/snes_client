import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RabbitMQService {
  Client? _client;
  Channel? _channel;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Clean up existing connection if any
      await disconnect();

      _client = Client(
        settings: ConnectionSettings(
          host: dotenv.env['CLOUDAMQP_HOST'] ?? 'localhost',
          port: int.parse(dotenv.env['CLOUDAMQP_PORT'] ?? '5672'),
          virtualHost: dotenv.env['CLOUDAMQP_USER'] ?? '/',
          authProvider: PlainAuthenticator(
            dotenv.env['CLOUDAMQP_USER'] ?? 'guest',
            dotenv.env['CLOUDAMQP_PASSWORD'] ?? 'guest',
          ),
        ),
      );

      _channel = await _client!.channel();

      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> publish(
    String exchangeName,
    String routingKey,
    Map<String, dynamic> message,
  ) async {
    if (!_isConnected || _channel == null) {
      throw Exception('RabbitMQ not connected');
    }

    try {
      final exchange = await _channel!.exchange(
        exchangeName,
        ExchangeType.TOPIC,
        durable: true,
      );
      final payload = jsonEncode(message);
      exchange.publish(payload, routingKey);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      // Close channel
      await _channel?.close();
      _channel = null;

      // Close client
      await _client?.close();
      _client = null;
    } catch (e) {
      // Ignore errors during disconnect
      print('Error during RabbitMQ disconnect: $e');
    }
    _isConnected = false;
  }

  void dispose() {
    disconnect();
  }
}
