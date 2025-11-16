# Snes9x Flutter Client

A Flutter application for connecting to the Snes9x server, featuring WebSocket video/audio streaming and RabbitMQ message support. Targets Android and Chrome platforms.

## Features

- 🎮 Real-time SNES emulation streaming
- 📺 WebSocket video stream consumption
- 🔊 WebSocket audio stream consumption
- 🐰 RabbitMQ message sending and receiving
- 🎯 Virtual SNES controller interface
- 👥 Multi-player support (Player 1 & Player 2)
- 📱 Android and Chrome support

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
   Create a `.env` file in the project root (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your server configuration:
   ```env
   SERVER_URL=http://localhost:3000
   WS_URL=ws://localhost:3000
   CLOUDAMQP_URL=amqp://guest:guest@localhost:5672/
   ADMIN_ENABLED=false
   ```

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

### Chrome (Web)

1. **Run on Chrome:**
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── control_message.dart  # Control message data models
├── providers/
│   ├── connection_provider.dart  # WebSocket & RabbitMQ connection management
│   └── game_provider.dart        # Game state management
├── services/
│   ├── websocket_service.dart    # WebSocket client for video/audio/control
│   └── rabbitmq_service.dart     # RabbitMQ client for messaging
└── widgets/
    ├── video_viewer.dart         # Video frame display widget
    └── controller_panel.dart     # SNES controller UI
```

## Architecture

### WebSocket Connections

The app maintains three WebSocket connections:

- **Control** (`/control`): Sends control input messages (JSON)
- **Video** (`/video`): Receives video frames (binary: type + width + height + RGB24 data)
- **Audio** (`/audio`): Receives audio samples (binary: type + samples + stereo int16 PCM)

### RabbitMQ Integration

- **Exchange**: `control_exchange` (topic)
- **Queue**: `control_queue`
- **Routing Key**: `control`

The app can both publish and consume messages from RabbitMQ.

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

- `web_socket_channel`: WebSocket client
- `dart_amqp`: RabbitMQ/AMQP client
- `provider`: State management
- `flutter_dotenv`: Environment variable management
- `http`: HTTP client
- `audioplayers`: Audio playback (for future audio implementation)

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

- Verify video WebSocket connection status (check connection indicator)
- Check server logs for video streaming errors
- Ensure server is sending video frames

### RabbitMQ Connection Failed

- Verify `CLOUDAMQP_URL` is correct
- Check RabbitMQ server is running
- Ensure network connectivity to RabbitMQ server

## License

ISC

## Related Projects

- [snes-server](../snes-server): Node.js server with Snes9x emulator core
