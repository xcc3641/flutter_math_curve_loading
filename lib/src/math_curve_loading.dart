import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'math_curve.dart';

/// A loading indicator that animates a particle trail along a mathematical
/// curve, with a faint background track, breathing detail, and optional slow
/// rotation.
///
/// Ported from https://github.com/Paidax01/math-curve-loaders.
///
/// ```dart
/// MathCurveLoading(curve: MathCurves.originalThinking, size: 132)
/// ```
class MathCurveLoading extends StatefulWidget {
  const MathCurveLoading({
    super.key,
    this.curve,
    this.size = 96,
    this.color,
    this.showTrack = true,
    this.speed = 1.0,
  });

  /// The curve preset to animate. Defaults to [MathCurves.originalThinking].
  final MathCurve? curve;

  /// Width and height of the (square) indicator, in logical pixels.
  final double size;

  /// Particle/track color. Defaults to the ambient text color, falling back to
  /// a dark slate when none is available.
  final Color? color;

  /// Whether to draw the faint background track under the particles.
  final bool showTrack;

  /// Animation speed multiplier (1.0 = reference timing).
  final double speed;

  @override
  State<MathCurveLoading> createState() => _MathCurveLoadingState();
}

class _MathCurveLoadingState extends State<MathCurveLoading>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _elapsedMs = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _elapsedMs.value = elapsed.inMicroseconds / 1000.0 * widget.speed;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsedMs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ponytail: widgets-only color resolution (no Material dependency).
    final color = widget.color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF111827);
    return SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _MathCurvePainter(
          curve: widget.curve ?? MathCurves.originalThinking,
          color: color,
          showTrack: widget.showTrack,
          ms: _elapsedMs,
        ),
      ),
    );
  }
}

class _MathCurvePainter extends CustomPainter {
  _MathCurvePainter({
    required this.curve,
    required this.color,
    required this.showTrack,
    required this.ms,
  }) : super(repaint: ms);

  final MathCurve curve;
  final Color color;
  final bool showTrack;
  final ValueNotifier<double> ms;

  static double _normalize(double p) => ((p % 1) + 1) % 1;

  @override
  void paint(Canvas canvas, Size size) {
    final time = ms.value;

    // Breathing factor `s`, identical to the reference getDetailScale().
    final pulseMs = curve.pulse.inMilliseconds.toDouble();
    final pulseAngle = (time % pulseMs) / pulseMs * math.pi * 2;
    final s = 0.52 + ((math.sin(pulseAngle + 0.55) + 1) / 2) * 0.48;

    final loopMs = curve.loop.inMilliseconds.toDouble();
    final progress = (time % loopMs) / loopMs;

    double rotationRad = 0;
    if (curve.rotate) {
      final rotMs = curve.rotation.inMilliseconds.toDouble();
      rotationRad = -((time % rotMs) / rotMs) * math.pi * 2;
    }

    // Map the 0..100 viewBox into the box with a small margin so curves that
    // briefly exceed the bounds (e.g. Heart Wave) are not clipped.
    final scale = size.shortestSide / 110.0;
    final pad = (size.shortestSide - 100 * scale) / 2;

    canvas.save();
    canvas.translate(pad, pad);
    canvas.scale(scale);
    canvas.translate(50, 50);
    canvas.rotate(rotationRad);
    canvas.translate(-50, -50);

    if (showTrack) {
      _paintTrack(canvas, s);
    }
    _paintParticles(canvas, progress, s);

    canvas.restore();
  }

  void _paintTrack(Canvas canvas, double s) {
    const steps = 480;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final pt = curve.point(i / steps, s);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = curve.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.1);
    canvas.drawPath(path, paint);
  }

  void _paintParticles(Canvas canvas, double progress, double s) {
    // ponytail: guard the count-1 divisor; presets are all >= 62.
    final denom = math.max(1, curve.particleCount - 1);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < curve.particleCount; i++) {
      final tailOffset = i / denom;
      final pt = curve.point(_normalize(progress - tailOffset * curve.trailSpan), s);
      final fade = math.pow(1 - tailOffset, 0.56).toDouble();
      paint.color = color.withValues(alpha: (0.04 + fade * 0.96).clamp(0.0, 1.0));
      canvas.drawCircle(pt, 0.9 + fade * 2.7, paint);
    }
  }

  @override
  bool shouldRepaint(_MathCurvePainter old) =>
      old.curve != curve || old.color != color || old.showTrack != showTrack;
}
