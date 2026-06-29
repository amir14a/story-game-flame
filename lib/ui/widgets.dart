import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/palette.dart';

/// A reusable animated cyberpunk background that every overlay sits on top of.
/// Pure [CustomPaint] — moving perspective grid, scanlines, neon haze and a
/// vignette, tinted by [accent].
class NeonScaffold extends StatefulWidget {
  const NeonScaffold({
    super.key,
    required this.child,
    this.accent = NeonPalette.cyan,
    this.gradient,
  });

  final Widget child;
  final Color accent;
  final Gradient? gradient;

  @override
  State<NeonScaffold> createState() => _NeonScaffoldState();
}

class _NeonScaffoldState extends State<NeonScaffold> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        painter: _NeonBackgroundPainter(_c.value, widget.accent, widget.gradient),
        child: child,
      ),
      child: SafeArea(child: widget.child),
    );
  }
}

class _NeonBackgroundPainter extends CustomPainter {
  _NeonBackgroundPainter(this.t, this.accent, this.gradient);
  final double t;
  final Color accent;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final g = gradient ?? NeonPalette.nightSky;
    canvas.drawRect(rect, Paint()..shader = g.createShader(rect));

    // perspective grid receding to a horizon
    final horizon = size.height * 0.46;
    final grid = Paint()
      ..color = accent.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;
    for (var i = -10; i <= 10; i++) {
      final x = size.width / 2 + i * size.width * 0.085;
      canvas.drawLine(Offset(size.width / 2, horizon), Offset(x, size.height), grid);
    }
    final scroll = (t * 0.5) % 0.1;
    for (var i = 0; i < 16; i++) {
      final f = (i / 16) + scroll;
      final y = horizon + (size.height - horizon) * f * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // distant neon haze blobs
    for (var i = 0; i < 3; i++) {
      final cx = size.width * (0.2 + 0.3 * i) + 30 * math.sin(t * 2 * math.pi + i);
      final cy = horizon * (0.5 + 0.2 * i);
      final color = [NeonPalette.magenta, NeonPalette.cyan, NeonPalette.violet][i];
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.12,
        Paint()
          ..color = color.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }

    // scanlines
    final scan = Paint()..color = Colors.black.withValues(alpha: 0.10);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), scan);
    }

    // vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
          stops: const [0.6, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _NeonBackgroundPainter old) => old.t != t || old.accent != accent;
}

/// A glitchy gradient title.
class GlitchTitle extends StatelessWidget {
  const GlitchTitle(this.text, {super.key, this.fontSize = 64, this.gradient});
  final String text;
  final double fontSize;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: fontSize * 0.06,
      height: 1.0,
    );
    return Stack(
      children: [
        Text(text, style: style.copyWith(color: NeonPalette.magenta.withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.only(left: 3, top: 1),
          child: Text(text, style: style.copyWith(color: NeonPalette.cyan.withValues(alpha: 0.5))),
        ),
        ShaderMask(
          shaderCallback: (rect) => (gradient ?? NeonPalette.duotone).createShader(rect),
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

/// A neon-bordered button with a soft glow.
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = NeonPalette.cyan,
    this.primary = false,
    this.enabled = true,
    this.width = 280,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool primary;
  final bool enabled;
  final double width;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled ? widget.color : NeonPalette.textDim;
    final glow = _down ? 0.9 : 0.45;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _down = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        decoration: BoxDecoration(
          color: (widget.primary ? color : NeonPalette.voidBlack).withValues(alpha: widget.primary ? 0.18 : 0.55),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: glow), blurRadius: _down ? 24 : 14, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.enabled ? NeonPalette.textBright : NeonPalette.textDim,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small uppercase tag label.
Widget neonTag(String text, {Color color = NeonPalette.cyan}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(3),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
      ),
    );

/// Text that reveals itself character by character (typewriter).
class TypingText extends StatefulWidget {
  const TypingText(this.text, {super.key, required this.style, this.charsPerSecond = 48});
  final String text;
  final TextStyle style;
  final double charsPerSecond;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.text.length / widget.charsPerSecond * 1000).round().clamp(200, 8000)),
  )..forward();

  @override
  void didUpdateWidget(covariant TypingText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _c
        ..duration = Duration(
            milliseconds: (widget.text.length / widget.charsPerSecond * 1000).round().clamp(200, 8000))
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final count = (widget.text.length * _c.value).round();
        return Text(widget.text.substring(0, count.clamp(0, widget.text.length)), style: widget.style);
      },
    );
  }
}
