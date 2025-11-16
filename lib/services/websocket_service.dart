import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _controlChannel;
  WebSocketChannel? _videoChannel;
  WebSocketChannel? _audioChannel;
  
  final _controlController = StreamController<Map<String, dynamic>>.broadcast();
  final _videoController = StreamController<VideoFrame>.broadcast();
  final _audioController = StreamController<AudioData>.broadcast();
  
  Stream<Map<String, dynamic>> get controlStream => _controlController.stream;
  Stream<VideoFrame> get videoStream => _videoController.stream;
  Stream<AudioData> get audioStream => _audioController.stream;
  
  bool _isControlConnected = false;
  bool _isVideoConnected = false;
  bool _isAudioConnected = false;
  
  bool get isControlConnected => _isControlConnected;
  bool get isVideoConnected => _isVideoConnected;
  bool get isAudioConnected => _isAudioConnected;
  
  String _baseUrl = '';
  
  void setBaseUrl(String url) {
    _baseUrl = url;
  }
  
  Future<void> connectControl() async {
    if (_controlChannel != null && _isControlConnected) return;
    
    try {
      final uri = Uri.parse('$_baseUrl/control');
      _controlChannel = WebSocketChannel.connect(uri);
      
      _controlChannel!.stream.listen(
        (message) {
          try {
            if (message is String) {
              final data = Map<String, dynamic>.from(
                // Assuming JSON response if any
                message.isNotEmpty ? {} : {},
              );
              _controlController.add(data);
            }
          } catch (e) {
            print('Error parsing control message: $e');
          }
        },
        onError: (error) {
          print('Control WebSocket error: $error');
          _isControlConnected = false;
          _reconnectControl();
        },
        onDone: () {
          print('Control WebSocket closed');
          _isControlConnected = false;
          _reconnectControl();
        },
      );
      
      _isControlConnected = true;
      print('Control WebSocket connected');
    } catch (e) {
      print('Error connecting control WebSocket: $e');
      _isControlConnected = false;
      _reconnectControl();
    }
  }
  
  Future<void> connectVideo() async {
    if (_videoChannel != null && _isVideoConnected) return;
    
    try {
      final uri = Uri.parse('$_baseUrl/video');
      _videoChannel = WebSocketChannel.connect(uri);
      
      _videoChannel!.stream.listen(
        (message) {
          if (message is Uint8List) {
            _handleVideoFrame(message);
          }
        },
        onError: (error) {
          print('Video WebSocket error: $error');
          _isVideoConnected = false;
          _reconnectVideo();
        },
        onDone: () {
          print('Video WebSocket closed');
          _isVideoConnected = false;
          _reconnectVideo();
        },
      );
      
      _isVideoConnected = true;
      print('Video WebSocket connected');
    } catch (e) {
      print('Error connecting video WebSocket: $e');
      _isVideoConnected = false;
      _reconnectVideo();
    }
  }
  
  Future<void> connectAudio() async {
    if (_audioChannel != null && _isAudioConnected) return;
    
    try {
      final uri = Uri.parse('$_baseUrl/audio');
      _audioChannel = WebSocketChannel.connect(uri);
      
      _audioChannel!.stream.listen(
        (message) {
          if (message is Uint8List) {
            _handleAudioData(message);
          }
        },
        onError: (error) {
          print('Audio WebSocket error: $error');
          _isAudioConnected = false;
          _reconnectAudio();
        },
        onDone: () {
          print('Audio WebSocket closed');
          _isAudioConnected = false;
          _reconnectAudio();
        },
      );
      
      _isAudioConnected = true;
      print('Audio WebSocket connected');
    } catch (e) {
      print('Error connecting audio WebSocket: $e');
      _isAudioConnected = false;
      _reconnectAudio();
    }
  }
  
  void _handleVideoFrame(Uint8List data) {
    if (data.length < 9) return; // Need at least type + width + height
    
    final type = data[0];
    if (type != 0x01) return; // Not a video frame
    
    // Read width and height (little-endian uint32)
    final widthBytes = data.sublist(1, 5);
    final heightBytes = data.sublist(5, 9);
    final width = widthBytes[0] | 
                  (widthBytes[1] << 8) | 
                  (widthBytes[2] << 16) | 
                  (widthBytes[3] << 24);
    final height = heightBytes[0] | 
                   (heightBytes[1] << 8) | 
                   (heightBytes[2] << 16) | 
                   (heightBytes[3] << 24);
    
    // RGB24 data starts at offset 9
    final rgb24Data = data.sublist(9);
    
    _videoController.add(VideoFrame(
      width: width,
      height: height,
      rgb24Data: rgb24Data,
    ));
  }
  
  void _handleAudioData(Uint8List data) {
    if (data.length < 5) return; // Need at least type + samples count
    
    final type = data[0];
    if (type != 0x02) return; // Not audio data
    
    // Read samples count (little-endian uint32)
    final samplesBytes = data.sublist(1, 5);
    final samples = samplesBytes[0] | 
                    (samplesBytes[1] << 8) | 
                    (samplesBytes[2] << 16) | 
                    (samplesBytes[3] << 24);
    
    // Audio data starts at offset 5 (stereo int16)
    final audioData = data.sublist(5);
    
    _audioController.add(AudioData(
      samples: samples,
      audioData: audioData,
    ));
  }
  
  void sendControl(Map<String, dynamic> message) {
    if (_controlChannel != null && _isControlConnected) {
      try {
        final jsonString = jsonEncode(message);
        _controlChannel!.sink.add(jsonString);
      } catch (e) {
        print('Error encoding control message: $e');
      }
    }
  }
  
  void _reconnectControl() {
    Future.delayed(const Duration(seconds: 1), () => connectControl());
  }
  
  void _reconnectVideo() {
    Future.delayed(const Duration(seconds: 1), () => connectVideo());
  }
  
  void _reconnectAudio() {
    Future.delayed(const Duration(seconds: 1), () => connectAudio());
  }
  
  void disconnect() {
    _controlChannel?.sink.close();
    _videoChannel?.sink.close();
    _audioChannel?.sink.close();
    _isControlConnected = false;
    _isVideoConnected = false;
    _isAudioConnected = false;
  }
  
  void dispose() {
    disconnect();
    _controlController.close();
    _videoController.close();
    _audioController.close();
  }
}

class VideoFrame {
  final int width;
  final int height;
  final Uint8List rgb24Data;
  
  VideoFrame({
    required this.width,
    required this.height,
    required this.rgb24Data,
  });
}

class AudioData {
  final int samples;
  final Uint8List audioData;
  
  AudioData({
    required this.samples,
    required this.audioData,
  });
}

