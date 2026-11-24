import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern frosted glass circular plus button matching the exact visual
/// specification (glowing ice/sky-blue gradient with beveled white glass rim
/// and crisp white '+' symbol, without text).
class GlassPlusButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final String? tooltip;

  const GlassPlusButton({
    super.key,
    required this.onTap,
    this.size = 56,
    this.tooltip,
  });

  @override
  State<GlassPlusButton> createState() => _GlassPlusButtonState();
}

class _GlassPlusButtonState extends State<GlassPlusButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : (_isHovered ? 1.06 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: _isHovered ? 0.55 : 0.42),
                  blurRadius: _isHovered ? 26 : 20,
                  offset: const Offset(0, 8),
                  spreadRadius: _isHovered ? 1 : -2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFBAE6FD), // Light ice-blue highlight
                        Color(0xFF38BDF8), // Vibrant cyan-blue center
                        Color(0xFF60A5FA), // Bright smooth blue base
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: widget.size >= 50 ? 2.8 : 2.0,
                    ),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: widget.size * 0.52,
                        shadows: const [
                          Shadow(
                            color: Color(0x330284C7),
                            blurRadius: 4,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
