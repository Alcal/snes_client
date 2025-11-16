import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/connection_provider.dart';

class ControlOverlay extends StatelessWidget {
  const ControlOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isPlayer1 = gameProvider.selectedPlayer == 0;

    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a).withOpacity(0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Player button if P1, otherwise spacer
            isPlayer1
                ? _buildPlayerSelector(context, gameProvider)
                : const SizedBox.shrink(),
            // Center: Connection status, audio, FPS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConnectionStatus(context),
                const SizedBox(width: 12),
                _buildEmulatorControls(context, gameProvider),
                const SizedBox(width: 12),
                _buildInfoPanel(context, gameProvider),
              ],
            ),
            // Right side: Player button if P2, otherwise spacer
            !isPlayer1
                ? _buildPlayerSelector(context, gameProvider)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: provider.isControlConnected ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildPlayerSelector(BuildContext context, GameProvider gameProvider) {
    final isPlayer1 = gameProvider.selectedPlayer == 0;

    return GestureDetector(
      onTap: () => gameProvider.setSelectedPlayer(isPlayer1 ? 1 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          border: Border.all(color: const Color(0xFF666666), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isPlayer1 ? 'P1' : 'P2',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmulatorControls(
    BuildContext context,
    GameProvider gameProvider,
  ) {
    return _buildControlButton(
      context,
      gameProvider.audioEnabled ? '🔊' : '🔇',
      () => gameProvider.enableAudio(),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          border: Border.all(color: const Color(0xFF666666), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, GameProvider gameProvider) {
    return Text(
      'FPS: ${gameProvider.fps}',
      style: const TextStyle(fontSize: 11, color: Color(0xFFaaaaaa)),
    );
  }
}
