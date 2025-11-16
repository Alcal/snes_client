import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ActionButtonsPanel extends StatelessWidget {
  const ActionButtonsPanel({super.key});

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
          _buildActionButtons(context, gameProvider),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // R shoulder button at the top
        _buildShoulderButton(context, gameProvider, 'r', 'R', Colors.orange),
        const SizedBox(height: 24),
        // Y and X buttons (top row)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, gameProvider, 'y', 'Y', Colors.purple, 65),
            const SizedBox(width: 16),
            _buildButton(context, gameProvider, 'x', 'X', Colors.blue, 65),
          ],
        ),
        const SizedBox(height: 20),
        // B and A buttons (main action buttons, slightly offset)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildButton(context, gameProvider, 'b', 'B', Colors.red, 70),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildButton(context, gameProvider, 'a', 'A', Colors.green, 70),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Start and Select
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, gameProvider, 'select', 'Select', Colors.grey, 55),
            const SizedBox(width: 12),
            _buildButton(context, gameProvider, 'start', 'Start', Colors.grey, 55),
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
    Color buttonColor,
    double size,
  ) {
    final isPressed = gameProvider.buttons[buttonName] == true;
    
    return GestureDetector(
      onTapDown: (_) => gameProvider.pressButton(buttonName),
      onTapUp: (_) => gameProvider.releaseButton(buttonName),
      onTapCancel: () => gameProvider.releaseButton(buttonName),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPressed 
              ? buttonColor.withOpacity(0.3) 
              : buttonColor.withOpacity(0.7),
          border: Border.all(
            color: isPressed ? Colors.white : buttonColor,
            width: 2,
          ),
          shape: BoxShape.circle,
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
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
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

