import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ControllerPanel extends StatelessWidget {
  const ControllerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Container(
      width: 300,
      color: const Color(0xFF2a2a2a),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlayerSelector(context, gameProvider),
            const SizedBox(height: 24),
            _buildControllerButtons(context, gameProvider),
            const SizedBox(height: 24),
            _buildDpad(context, gameProvider),
            const SizedBox(height: 24),
            _buildEmulatorControls(context, gameProvider),
            const SizedBox(height: 24),
            _buildInfoPanel(context, gameProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelector(BuildContext context, GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Player Selection',
          style: TextStyle(
            color: Color(0xFFaaaaaa),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPlayerOption(
                context,
                gameProvider,
                0,
                'Player 1',
                gameProvider.selectedPlayer == 0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPlayerOption(
                context,
                gameProvider,
                1,
                'Player 2',
                gameProvider.selectedPlayer == 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerOption(
    BuildContext context,
    GameProvider gameProvider,
    int player,
    String label,
    bool selected,
  ) {
    return GestureDetector(
      onTap: () => gameProvider.setSelectedPlayer(player),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2a5a2a) : const Color(0xFF444444),
          border: Border.all(
            color: selected ? Colors.green : const Color(0xFF666666),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.green : Colors.white,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControllerButtons(BuildContext context, GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controller',
          style: TextStyle(
            color: Color(0xFFaaaaaa),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: [
            _buildButton(context, gameProvider, 'y', 'Y'),
            _buildButton(context, gameProvider, 'x', 'X'),
            _buildButton(context, gameProvider, 'l', 'L'),
            _buildButton(context, gameProvider, 'r', 'R'),
            _buildButton(context, gameProvider, 'a', 'A'),
            _buildButton(context, gameProvider, 'b', 'B'),
            _buildButton(context, gameProvider, 'select', 'Select'),
            _buildButton(context, gameProvider, 'start', 'Start'),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    GameProvider gameProvider,
    String buttonName,
    String label,
  ) {
    final isPressed = gameProvider.buttons[buttonName] == true;
    
    return GestureDetector(
      onTapDown: (_) => gameProvider.pressButton(buttonName),
      onTapUp: (_) => gameProvider.releaseButton(buttonName),
      onTapCancel: () => gameProvider.releaseButton(buttonName),
      child: Container(
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFF0a0a0a) : const Color(0xFF444444),
          border: Border.all(
            color: isPressed ? Colors.green : const Color(0xFF666666),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDpad(BuildContext context, GameProvider gameProvider) {
    return Column(
      children: [
        _buildDpadButton(context, gameProvider, 'up', '↑'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDpadButton(context, gameProvider, 'left', '←'),
            const SizedBox(width: 8),
            _buildDpadButton(context, gameProvider, 'right', '→'),
          ],
        ),
        _buildDpadButton(context, gameProvider, 'down', '↓'),
      ],
    );
  }

  Widget _buildDpadButton(
    BuildContext context,
    GameProvider gameProvider,
    String buttonName,
    String label,
  ) {
    final isPressed = gameProvider.buttons[buttonName] == true;
    
    return GestureDetector(
      onTapDown: (_) => gameProvider.pressButton(buttonName),
      onTapUp: (_) => gameProvider.releaseButton(buttonName),
      onTapCancel: () => gameProvider.releaseButton(buttonName),
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFF0a0a0a) : const Color(0xFF444444),
          border: Border.all(
            color: isPressed ? Colors.green : const Color(0xFF666666),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmulatorControls(BuildContext context, GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emulator Controls',
          style: TextStyle(
            color: Color(0xFFaaaaaa),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildControlButton(
              context,
              'Reset',
              () => gameProvider.reset(),
            ),
            _buildControlButton(
              context,
              gameProvider.audioEnabled ? '🔊 Audio Enabled' : '🔇 Enable Audio',
              () => gameProvider.enableAudio(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          border: Border.all(color: const Color(0xFF666666), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FPS: ${gameProvider.fps}', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

