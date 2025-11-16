import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/control_message.dart';
import '../providers/connection_provider.dart';

class GameProvider with ChangeNotifier {
  final ConnectionProvider _connectionProvider;

  int _selectedPlayer;
  final Map<String, bool> _buttons = {};
  bool _audioEnabled = false;
  int _frameCount = 0;
  int _fps = 0;
  DateTime _lastFpsTime = DateTime.now();

  int get selectedPlayer => _selectedPlayer;
  Map<String, bool> get buttons => Map.unmodifiable(_buttons);
  bool get audioEnabled => _audioEnabled;
  int get fps => _fps;

  GameProvider(this._connectionProvider)
    : _selectedPlayer = Random().nextInt(2);

  void setSelectedPlayer(int player) {
    _selectedPlayer = player;
    _buttons.clear();
    _sendButtonState();
    notifyListeners();
  }

  void pressButton(String buttonName) {
    _buttons[buttonName] = true;
    _sendButtonState();
    notifyListeners();
  }

  void releaseButton(String buttonName) {
    _buttons[buttonName] = false;
    _sendButtonState();
    notifyListeners();
  }

  void _sendButtonState() {
    final message = ControlMessage.input(
      port: _selectedPlayer,
      buttons: Map.from(_buttons),
    );
    // _connectionProvider.webSocketService.sendControl(message.toJson());
    sendRabbitMQMessage(message.toJson());
  }

  void reset() {
    final message = ControlMessage.reset();
    _connectionProvider.webSocketService.sendControl(message.toJson());
  }

  void pause({required bool paused}) {
    final message = ControlMessage.pause(paused: paused);
    _connectionProvider.webSocketService.sendControl(message.toJson());
  }

  void enableAudio() {
    _audioEnabled = true;
    _connectionProvider.connectAudio();
    notifyListeners();
  }

  void updateFps() {
    _frameCount++;
    final now = DateTime.now();
    if (now.difference(_lastFpsTime).inSeconds >= 1) {
      _fps = _frameCount;
      _frameCount = 0;
      _lastFpsTime = now;
      notifyListeners();
    }
  }

  Future<void> sendRabbitMQMessage(Map<String, dynamic> message) async {
    try {
      await _connectionProvider.rabbitMQService.publish(
        'control_exchange',
        'control',
        message,
      );
    } catch (e) {
      print('Error sending RabbitMQ message: $e');
    }
  }
}
