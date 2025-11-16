class ControlMessage {
  final String type;
  final int? port;
  final Map<String, bool>? buttons;
  final int? x;
  final int? y;
  final bool? left;
  final bool? right;
  final bool? paused;

  ControlMessage({
    required this.type,
    this.port,
    this.buttons,
    this.x,
    this.y,
    this.left,
    this.right,
    this.paused,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (port != null) json['port'] = port;
    if (buttons != null) json['buttons'] = buttons;
    if (x != null) json['x'] = x;
    if (y != null) json['y'] = y;
    if (left != null) json['left'] = left;
    if (right != null) json['right'] = right;
    if (paused != null) json['paused'] = paused;
    return json;
  }

  factory ControlMessage.input({
    required int port,
    required Map<String, bool> buttons,
  }) {
    return ControlMessage(
      type: 'input',
      port: port,
      buttons: buttons,
    );
  }

  factory ControlMessage.mouse({
    required int port,
    required int x,
    required int y,
    bool? left,
    bool? right,
  }) {
    return ControlMessage(
      type: 'mouse',
      port: port,
      x: x,
      y: y,
      left: left,
      right: right,
    );
  }

  factory ControlMessage.reset() {
    return ControlMessage(type: 'reset');
  }

  factory ControlMessage.pause({required bool paused}) {
    return ControlMessage(type: 'pause', paused: paused);
  }
}

