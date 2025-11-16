import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../providers/game_provider.dart';
import '../providers/connection_provider.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key});

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  ui.Image? _currentFrame;
  int _width = 256;
  int _height = 224;

  @override
  void initState() {
    super.initState();
    _listenToVideoStream();
  }

  void _listenToVideoStream() {
    final connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );
    connectionProvider.webSocketService.videoStream.listen((frame) {
      _updateFrame(frame);
    });
  }

  Future<void> _updateFrame(VideoFrame frame) async {
    // Convert RGB24 to Image
    final rgb24Data = frame.rgb24Data;
    final width = frame.width;
    final height = frame.height;

    // Create RGBA data
    final rgbaData = Uint8List(width * height * 4);
    for (int i = 0; i < rgb24Data.length; i += 3) {
      final pixelIndex = i ~/ 3;
      final rgbaIndex = pixelIndex * 4;
      rgbaData[rgbaIndex] = rgb24Data[i]; // R
      rgbaData[rgbaIndex + 1] = rgb24Data[i + 1]; // G
      rgbaData[rgbaIndex + 2] = rgb24Data[i + 2]; // B
      rgbaData[rgbaIndex + 3] = 255; // A
    }

    // Create UI Image
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(rgbaData, width, height, ui.PixelFormat.rgba8888, (
      ui.Image image,
    ) {
      completer.complete(image);
    });

    final image = await completer.future;

    if (mounted) {
      setState(() {
        _currentFrame = image;
        _width = width;
        _height = height;
      });

      // Update FPS
      Provider.of<GameProvider>(context, listen: false).updateFps();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _currentFrame != null
            ? CustomPaint(
                painter: VideoPainter(_currentFrame!),
                size: Size(_width.toDouble(), _height.toDouble()),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class VideoPainter extends CustomPainter {
  final ui.Image image;

  VideoPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(VideoPainter oldDelegate) => oldDelegate.image != image;
}
