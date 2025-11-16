import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../services/rabbitmq_service.dart';

class ConnectionProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  final RabbitMQService _rabbitMQService = RabbitMQService();

  bool _isControlConnected = false;
  bool _isVideoConnected = false;
  bool _isAudioConnected = false;
  bool _isRabbitMQConnected = false;

  bool get isControlConnected => _isControlConnected;
  bool get isVideoConnected => _isVideoConnected;
  bool get isAudioConnected => _isAudioConnected;
  bool get isRabbitMQConnected => _isRabbitMQConnected;

  WebSocketService get webSocketService => _webSocketService;
  RabbitMQService get rabbitMQService => _rabbitMQService;

  Future<void> connect(String serverUrl) async {
    // Convert http:// to ws://
    final wsUrl = serverUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    _webSocketService.setBaseUrl(wsUrl);

    // Connect WebSockets
    await _webSocketService.connectControl();
    await _webSocketService.connectVideo();

    // Update connection status
    _isControlConnected = _webSocketService.isControlConnected;
    _isVideoConnected = _webSocketService.isVideoConnected;

    // Connect RabbitMQ
    try {
      await _rabbitMQService.connect();
      _isRabbitMQConnected = _rabbitMQService.isConnected;

      // Listen to RabbitMQ messages
      _rabbitMQService.messageStream.listen((message) {
        // Handle incoming RabbitMQ messages
        print('Received RabbitMQ message: $message');
        // You can forward these to the WebSocket service if needed
        // or handle them directly here
      });
    } catch (e) {
      print('Failed to connect to RabbitMQ: $e');
      _isRabbitMQConnected = false;
    }

    notifyListeners();
  }

  Future<void> connectAudio() async {
    await _webSocketService.connectAudio();
    _isAudioConnected = _webSocketService.isAudioConnected;
    notifyListeners();
  }

  void disconnect() {
    _webSocketService.disconnect();
    _rabbitMQService.disconnect();
    _isControlConnected = false;
    _isVideoConnected = false;
    _isAudioConnected = false;
    _isRabbitMQConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    _rabbitMQService.dispose();
    super.dispose();
  }
}
