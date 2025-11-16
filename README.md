# Snes9x Flutter Client

A Flutter application for connecting to the Snes9x server, featuring WebSocket video/audio streaming and RabbitMQ message support. This client provides a mobile and web interface for remote SNES emulation, allowing you to play SNES games streamed from a server.

## Features

- 🎮 Real-time SNES emulation streaming
- 📺 WebSocket video stream consumption (RGB24 frames)
- 🔊 WebSocket audio stream consumption (16-bit PCM stereo) - *Partially implemented*
- 🐰 RabbitMQ message sending and receiving (optional)
- 🎯 Virtual SNES controller interface with touch controls
- 👥 Multi-player support (Player 1 & Player 2)
- 📱 Android and Chrome support
- 🔄 Automatic reconnection for WebSocket connections
- 📊 Connection status indicators

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio (for Android development)
- Chrome browser (for web development)

## Setup

1. **Clone or navigate to the project directory:**
   ```bash
   cd snes_client
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   Create a `.env` file in the project root:
   ```bash
   touch .env
   ```
   
   Edit `.env` with your server configuration:
   ```env
   SERVER_URL=http://localhost:3000
   WS_URL=ws://localhost:3000
   CLOUDAMQP_URL=amqp://guest:guest@localhost:5672/
   ADMIN_ENABLED=false
   ```
   
   **Note:** 
   - For Android emulator, the app automatically uses `10.0.2.2` instead of `localhost` to access the host machine
   - For physical Android devices, use your machine's local IP address (e.g., `ws://192.168.1.100:3000`)
   - RabbitMQ connection is optional; the app will continue to work if RabbitMQ is unavailable

## Running the App

### Android

1. **Connect an Android device or start an emulator:**
   ```bash
   flutter devices
   ```

2. **Run on Android:**
   ```bash
   flutter run -d android
   ```
   
   **Note:** If using an Android emulator, the app automatically connects to `10.0.2.2:3000` to access the host machine's localhost. For physical devices, ensure your server is accessible on your local network and update the `WS_URL` in `.env` accordingly.

### Chrome (Web)

1. **Run on Chrome:**
   ```bash
   flutter run -d chrome
   ```
   
   **Note:** For web deployment, ensure CORS is properly configured on the server if accessing from a different origin.

## Project Structure

```
lib/
├── main.dart                      # App entry point, initializes providers and UI
├── models/
│   └── control_message.dart      # Control message data models (JSON structure)
├── providers/
│   ├── connection_provider.dart  # WebSocket & RabbitMQ connection management
│   │                             # Tracks connection status for all services
│   └── game_provider.dart        # Game state management, control input handling
├── services/
│   ├── websocket_service.dart    # WebSocket client for video/audio/control streams
│   │                             # Handles binary frame parsing and reconnection
│   ├── rabbitmq_service.dart     # RabbitMQ client for messaging (optional)
│   └── audio_service.dart        # Audio playback service (placeholder)
└── widgets/
    ├── video_viewer.dart         # Video frame display widget (RGB24 → RGBA conversion)
    └── controller_panel.dart     # SNES controller UI with touch controls
                                  # Supports Player 1 & Player 2 selection
```

## Architecture

### State Management

The app uses the Provider pattern for state management:

- **ConnectionProvider**: Manages WebSocket and RabbitMQ connections, tracks connection status
- **GameProvider**: Manages game state, handles control input, and coordinates between services

### WebSocket Connections

The app maintains three WebSocket connections:

- **Control** (`/control`): Sends control input messages (JSON)
  - Automatically reconnects on connection loss
  - Connection status displayed in app bar
- **Video** (`/video`): Receives video frames (binary: type + width + height + RGB24 data)
  - Frames are converted from RGB24 to RGBA for Flutter display
  - Automatically reconnects on connection loss
- **Audio** (`/audio`): Receives audio samples (binary: type + samples + stereo int16 PCM)
  - Currently receives data but playback is not fully implemented
  - Automatically reconnects on connection loss

All WebSocket connections support automatic reconnection with exponential backoff.

### RabbitMQ Integration

- **Exchange**: `control_exchange` (topic)
- **Queue**: `control_queue`
- **Routing Key**: `control`

The app can both publish and consume messages from RabbitMQ. RabbitMQ connection is optional - the app gracefully handles connection failures and continues to work using WebSocket-only control.

### Control Messages

Control messages follow this format:

```dart
{
  "type": "input",
  "port": 0,  // 0 for Player 1, 1 for Player 2
  "buttons": {
    "a": true,
    "b": false,
    "x": false,
    "y": false,
    "l": false,
    "r": false,
    "start": false,
    "select": false,
    "up": false,
    "down": false,
    "left": false,
    "right": false
  }
}
```

Other message types:
- `{"type": "reset"}`
- `{"type": "pause", "paused": true}`
- `{"type": "mouse", "port": 0, "x": 100, "y": 200, "left": true, "right": false}`

## Dependencies

- `web_socket_channel: ^3.0.1`: WebSocket client for video/audio/control streams
- `dart_amqp: ^0.3.0`: RabbitMQ/AMQP client for message queue support
- `provider: ^6.1.2`: State management (ConnectionProvider, GameProvider)
- `flutter_dotenv: ^5.1.0`: Environment variable management
- `http: ^1.2.2`: HTTP client for API calls
- `audioplayers: ^6.0.0`: Audio playback (currently placeholder - PCM audio not fully implemented)

## Development

### Building for Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**Chrome:**
```bash
flutter build web --release
```

## Troubleshooting

### Connection Issues

- Ensure the Snes9x server is running and accessible
- Check that WebSocket URLs are correct (use `ws://` for HTTP, `wss://` for HTTPS)
- Verify RabbitMQ server is running and accessible
- Check firewall settings

### Video Not Displaying

- Verify video WebSocket connection status (check connection indicator in app bar)
- Check server logs for video streaming errors
- Ensure server is sending video frames
- Verify the server is running and a ROM is loaded
- Check network connectivity between client and server

### Audio Not Working

- Audio playback is currently partially implemented
- The app receives audio data via WebSocket but playback requires additional implementation
- Consider using `flutter_sound` or `just_audio` for PCM audio support

### RabbitMQ Connection Failed

- RabbitMQ connection is optional; the app will continue to work without it
- Verify `CLOUDAMQP_URL` is correct in `.env` file
- Check RabbitMQ server is running and accessible
- Ensure network connectivity to RabbitMQ server
- The app will log connection errors but won't crash if RabbitMQ is unavailable

## Version

Current version: `1.0.0+1` (as defined in `pubspec.yaml`)

## License

ISC

## Related Projects

- [snes-server](../snes-server): Node.js server with Snes9x emulator core
  - Provides WebSocket endpoints for video, audio, and control
  - Handles ROM loading and emulator state management
  - Supports RabbitMQ integration for distributed control input
