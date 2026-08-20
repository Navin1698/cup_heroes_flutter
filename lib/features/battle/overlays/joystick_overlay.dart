import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class JoystickOverlay extends StatefulWidget {
  final Function(Vector2) onDirectionChanged;

  const JoystickOverlay({super.key, required this.onDirectionChanged});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay> {
  Offset _knobOffset = Offset.zero;
  static const double _maxRadius = 45.0;

  void _updateKnob(Offset localPos, Offset center) {
    final delta = localPos - center;
    final dist = delta.distance;

    if (dist <= _maxRadius) {
      _knobOffset = delta;
    } else {
      final angle = atan2(delta.dy, delta.dx);
      _knobOffset = Offset(cos(angle) * _maxRadius, sin(angle) * _maxRadius);
    }

    final normalized = Vector2(_knobOffset.dx / _maxRadius, _knobOffset.dy / _maxRadius);
    widget.onDirectionChanged(normalized);
    setState(() {});
  }

  void _resetKnob() {
    _knobOffset = Offset.zero;
    widget.onDirectionChanged(Vector2.zero());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 30,
      child: GestureDetector(
        onPanStart: (details) => _updateKnob(details.localPosition, const Offset(65, 65)),
        onPanUpdate: (details) => _updateKnob(details.localPosition, const Offset(65, 65)),
        onPanEnd: (_) => _resetKnob(),
        onPanCancel: () => _resetKnob(),
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF151A38).withValues(alpha: 0.65),
            border: Border.all(color: EmberColors.secondary.withValues(alpha: 0.4), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: EmberColors.secondary.withValues(alpha: 0.15),
                blurRadius: 16,
              ),
            ],
          ),
          child: Center(
            child: Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [EmberColors.secondary, EmberColors.primary],
                  ),
                  border: Border.all(color: Colors.white, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: EmberColors.secondary.withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
