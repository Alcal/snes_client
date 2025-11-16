import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/connection_provider.dart';
import 'providers/game_provider.dart';
import 'widgets/video_viewer.dart';
import 'widgets/controller_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
        ChangeNotifierProxyProvider<ConnectionProvider, GameProvider>(
          create: (context) => GameProvider(
            Provider.of<ConnectionProvider>(context, listen: false),
          ),
          update: (context, connectionProvider, previous) =>
              previous ?? GameProvider(connectionProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Snes9x Flutter Client',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1a1a1a),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    // Get default host based on platform
    // For Android emulator, use 10.0.2.2 to access host machine's localhost
    // For physical Android devices, use your machine's local IP address
    // For other platforms, use localhost
    String defaultHost = 'localhost';
    if (Platform.isAndroid) {
      defaultHost = '10.0.2.2'; // Android emulator special IP for host machine
    }

    final wsUrl = dotenv.env['WS_URL'] ?? 'ws://$defaultHost:3000';

    final connectionProvider = Provider.of<ConnectionProvider>(
      context,
      listen: false,
    );

    try {
      await connectionProvider.connect(wsUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Snes9x Flutter Client'),
        actions: [
          Consumer<ConnectionProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isControlConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isControlConnected
                          ? 'Connected'
                          : 'Disconnected',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: const [
                Expanded(child: VideoViewer()),
                ControllerPanel(),
              ],
            ),
    );
  }
}
