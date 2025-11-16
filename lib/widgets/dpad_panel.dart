import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class DpadPanel extends StatelessWidget {
  const DpadPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Container(
      width: 200,
      color: const Color(0xFF2a2a2a),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // L shoulder button at the top
          _buildShoulderButton(context, gameProvider, 'l', 'L', Colors.orange),
          const SizedBox(height: 24),
          _buildDpad(context, gameProvider),
        ],
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
        width: 70,
        height: 70,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFF0a0a0a) : const Color(0xFF444444),
          border: Border.all(
            color: isPressed ? Colors.green : const Color(0xFF666666),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoulderButton(
    BuildContext context,
    GameProvider gameProvider,
    String buttonName,
    String label,
    Color buttonColor,
  ) {
    final isPressed = gameProvider.buttons[buttonName] == true;
    
    return GestureDetector(
      onTapDown: (_) => gameProvider.pressButton(buttonName),
      onTapUp: (_) => gameProvider.releaseButton(buttonName),
      onTapCancel: () => gameProvider.releaseButton(buttonName),
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: isPressed 
              ? buttonColor.withOpacity(0.3) 
              : buttonColor.withOpacity(0.7),
          border: Border.all(
            color: isPressed ? Colors.white : buttonColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

