import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RabbitMQService {
  Client? _client;
  Channel? _channel;
  Consumer? _consumer;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
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

      // Declare exchange
      final exchange = await _channel!.exchange(
        'control_exchange',
        ExchangeType.TOPIC,
        durable: true,
      );

      // Declare queue
      final queue = await _channel!.queue('control_queue');

      // Bind queue to exchange
      await queue.bind(exchange, 'control');

      // Create consumer
      _consumer = await queue.consume();

      _consumer!.listen((message) {
        try {
          final payload = message.payload;

          if (payload == null) {
            message.ack();
            return;
          }

          final String content;
          if (payload is String) {
            content = payload as String;
          } else if (payload is List<int>) {
            content = utf8.decode(payload);
          }

          if (content.isNotEmpty) {
            final data = jsonDecode(content) as Map<String, dynamic>;
            _messageController.add(data);
          }

          // Acknowledge message
          message.ack();
        } catch (e) {
          message.ack(); // Acknowledge even on error to prevent message buildup
        }
      });

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
      await _consumer?.cancel();
      await _channel?.close();
      await _client?.close();
    } catch (e) {
      // Ignore errors during disconnect
    }
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
