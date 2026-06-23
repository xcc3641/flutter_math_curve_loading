import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Maps a normalized [progress] (0..1 around the curve) and a breathing
/// [detailScale] to a point in a 0..100 coordinate space (origin top-left,
/// y growing downward), matching the reference SVG `viewBox="0 0 100 100"`.
typedef CurvePointFn = Offset Function(double progress, double detailScale);

const double _twoPi = math.pi * 2;

/// A single mathematical curve for [MathCurveLoading].
///
/// Build one with a named constructor — every shape parameter is exposed, e.g.
/// `MathCurve.rose(k: 6, a: 11)` — then tweak look/timing with [copyWith].
/// The [MathCurves] presets are just default invocations of these constructors.
///
/// Ported from https://github.com/Paidax01/math-curve-loaders.
class MathCurve {
  /// The low-level constructor. Most callers want a named constructor such as
  /// [MathCurve.rose] or a [MathCurves] preset instead.
  const MathCurve({
    required this.name,
    required this.tag,
    required this.point,
    required this.particleCount,
    required this.trailSpan,
    required this.loop,
    required this.pulse,
    required this.strokeWidth,
    this.rotate = false,
    this.rotation = const Duration(seconds: 28),
  });

  /// Human-readable name, e.g. "Rose Curve".
  final String name;

  /// Short formula tag, e.g. "r = a cos(kθ)".
  final String tag;

  /// The parametric point function in 0..100 space.
  final CurvePointFn point;

  /// Number of trailing particles.
  final int particleCount;

  /// How far back along the curve the tail reaches (fraction of one loop).
  final double trailSpan;

  /// Time for the head particle to travel one full loop of the curve.
  final Duration loop;

  /// Breathing period that drives `detailScale`.
  final Duration pulse;

  /// Faint background track stroke width, in 0..100 viewBox units.
  final double strokeWidth;

  /// Whether the whole figure slowly rotates.
  final bool rotate;

  /// Rotation period when [rotate] is true.
  final Duration rotation;

  /// Returns a copy with the given look/timing fields overridden. The curve
  /// *shape* ([point]) is preserved — change the shape with a named constructor.
  MathCurve copyWith({
    String? name,
    String? tag,
    int? particleCount,
    double? trailSpan,
    Duration? loop,
    Duration? pulse,
    Duration? rotation,
    double? strokeWidth,
    bool? rotate,
  }) {
    return MathCurve(
      name: name ?? this.name,
      tag: tag ?? this.tag,
      point: point,
      particleCount: particleCount ?? this.particleCount,
      trailSpan: trailSpan ?? this.trailSpan,
      loop: loop ?? this.loop,
      pulse: pulse ?? this.pulse,
      rotation: rotation ?? this.rotation,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      rotate: rotate ?? this.rotate,
    );
  }

  // --------------------------------------------------------------------------
  // Named constructors — one per curve family. Shape params first, then the
  // look/timing knobs (all with sensible defaults).
  // --------------------------------------------------------------------------

  /// Custom rose trail: a circle carved by a `petals`-fold cosine term — the
  /// original "thinking" loader. `x = R cos t − D·s·cos(petals·t)` (×`scale`).
  factory MathCurve.roseTrail({
    String name = 'Original Thinking',
    String tag = 'Custom Rose Trail',
    int petals = 7,
    double detail = 3,
    double baseRadius = 7,
    double scale = 3.9,
    int particleCount = 64,
    double trailSpan = 0.38,
    Duration loop = const Duration(milliseconds: 4600),
    Duration pulse = const Duration(milliseconds: 4200),
    Duration rotation = const Duration(milliseconds: 28000),
    double strokeWidth = 5.5,
    bool rotate = true,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final x = baseRadius * math.cos(t) - detail * s * math.cos(petals * t);
        final y = baseRadius * math.sin(t) - detail * s * math.sin(petals * t);
        return Offset(50 + x * scale, 50 + y * scale);
      },
    );
  }

  /// Breathing radius on a circular orbit: `r = R − A·s·cos(kt)`.
  factory MathCurve.roseOrbit({
    String name = 'Rose Orbit',
    String tag = 'r = cos(kθ)',
    int k = 7,
    double orbitRadius = 7,
    double detail = 2.7,
    double scale = 3.9,
    int particleCount = 72,
    double trailSpan = 0.42,
    Duration loop = const Duration(milliseconds: 5200),
    Duration pulse = const Duration(milliseconds: 4600),
    Duration rotation = const Duration(milliseconds: 28000),
    double strokeWidth = 5.2,
    bool rotate = true,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final r = orbitRadius - detail * s * math.cos(k * t);
        return Offset(50 + math.cos(t) * r * scale, 50 + math.sin(t) * r * scale);
      },
    );
  }

  /// Polar rose: `r = (a + s·aBoost)(breathBase + s·breathBoost)·cos(kt)`.
  factory MathCurve.rose({
    String name = 'Rose Curve',
    String tag = 'r = a cos(kθ)',
    int k = 5,
    double a = 9.2,
    double aBoost = 0.6,
    double breathBase = 0.72,
    double breathBoost = 0.28,
    double scale = 3.25,
    int particleCount = 78,
    double trailSpan = 0.32,
    Duration loop = const Duration(milliseconds: 5400),
    Duration pulse = const Duration(milliseconds: 4600),
    Duration rotation = const Duration(milliseconds: 28000),
    double strokeWidth = 4.5,
    bool rotate = true,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final amp = a + s * aBoost;
        final r = amp * (breathBase + s * breathBoost) * math.cos(k * t);
        return Offset(50 + math.cos(t) * r * scale, 50 + math.sin(t) * r * scale);
      },
    );
  }

  /// Lissajous figure: `x = sin(at + φ)`, `y = sin(bt)`.
  factory MathCurve.lissajous({
    String name = 'Lissajous Drift',
    String tag = 'x = sin(at), y = sin(bt)',
    int a = 3,
    int b = 4,
    double phase = 1.57,
    double amp = 24,
    double ampBoost = 6,
    double yScale = 0.92,
    int particleCount = 68,
    double trailSpan = 0.34,
    Duration loop = const Duration(milliseconds: 6000),
    Duration pulse = const Duration(milliseconds: 5400),
    Duration rotation = const Duration(milliseconds: 36000),
    double strokeWidth = 4.7,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final m = amp + s * ampBoost;
        return Offset(50 + math.sin(a * t + phase) * m, 50 + math.sin(b * t) * (m * yScale));
      },
    );
  }

  /// Bernoulli lemniscate (figure-eight): a breathing infinity sign.
  factory MathCurve.lemniscate({
    String name = 'Lemniscate Bloom',
    String tag = 'Bernoulli Lemniscate',
    double a = 20,
    double boost = 7,
    int particleCount = 70,
    double trailSpan = 0.40,
    Duration loop = const Duration(milliseconds: 5600),
    Duration pulse = const Duration(milliseconds: 5000),
    Duration rotation = const Duration(milliseconds: 34000),
    double strokeWidth = 4.8,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final scale = a + s * boost;
        final denom = 1 + math.sin(t) * math.sin(t);
        return Offset(50 + scale * math.cos(t) / denom, 50 + scale * math.sin(t) * math.cos(t) / denom);
      },
    );
  }

  /// Hypotrochoid (inner spirograph) with breathing inner radius and offset.
  factory MathCurve.hypotrochoid({
    String name = 'Hypotrochoid Loop',
    String tag = 'Inner Spirograph',
    double bigR = 8.2,
    double r = 2.7,
    double rBoost = 0.45,
    double d = 4.8,
    double dBoost = 1.2,
    double scale = 3.05,
    int particleCount = 82,
    double trailSpan = 0.46,
    Duration loop = const Duration(milliseconds: 7600),
    Duration pulse = const Duration(milliseconds: 6200),
    Duration rotation = const Duration(milliseconds: 42000),
    double strokeWidth = 4.6,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final ri = r + s * rBoost;
        final di = d + s * dBoost;
        final x = (bigR - ri) * math.cos(t) + di * math.cos(((bigR - ri) / ri) * t);
        final y = (bigR - ri) * math.sin(t) - di * math.sin(((bigR - ri) / ri) * t);
        return Offset(50 + x * scale, 50 + y * scale);
      },
    );
  }

  /// Rolling-circle spiral: `R` loops, rolling radius `r`, pen offset `d`.
  factory MathCurve.spiral({
    String name = 'Rolling Spiral',
    String? tag,
    int bigR = 3,
    double r = 1,
    double d = 3,
    double scale = 2.2,
    double breath = 0.45,
    int particleCount = 82,
    double trailSpan = 0.34,
    Duration loop = const Duration(milliseconds: 4600),
    Duration pulse = const Duration(milliseconds: 4200),
    Duration rotation = const Duration(milliseconds: 28000),
    double strokeWidth = 4.4,
    bool rotate = true,
  }) {
    return MathCurve(
      name: name,
      tag: tag ?? 'R = $bigR, r = ${_fmt(r)}, d = ${_fmt(d)}',
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final di = d + s * 0.25;
        final ratio = (bigR - r) / r;
        final baseX = (bigR - r) * math.cos(t) + di * math.cos(ratio * t);
        final baseY = (bigR - r) * math.sin(t) - di * math.sin(ratio * t);
        final m = scale + s * breath;
        return Offset(50 + baseX * m, 50 + baseY * m);
      },
    );
  }

  /// The butterfly curve.
  factory MathCurve.butterfly({
    String name = 'Butterfly Phase',
    String tag = 'Butterfly Curve',
    double turns = 12,
    double scale = 4.6,
    double pulseAmp = 0.45,
    double cosWeight = 2,
    int power = 5,
    int particleCount = 88,
    double trailSpan = 0.32,
    Duration loop = const Duration(milliseconds: 9000),
    Duration pulse = const Duration(milliseconds: 7000),
    Duration rotation = const Duration(milliseconds: 50000),
    double strokeWidth = 4.4,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * math.pi * turns;
        final b = math.exp(math.cos(t)) - cosWeight * math.cos(4 * t) - math.pow(math.sin(t / 12), power);
        final m = scale + s * pulseAmp;
        return Offset(50 + math.sin(t) * b * m, 50 + math.cos(t) * b * m);
      },
    );
  }

  /// Cardioid: `r = a(1 ∓ cos t)`. With `heart: true` it is rotated upright.
  factory MathCurve.cardioid({
    String name = 'Cardioid Glow',
    String tag = 'Cardioid',
    double a = 8.4,
    double pulseAmp = 0.8,
    double scale = 2.15,
    bool heart = false,
    int particleCount = 72,
    double trailSpan = 0.36,
    Duration loop = const Duration(milliseconds: 6200),
    Duration pulse = const Duration(milliseconds: 5200),
    Duration rotation = const Duration(milliseconds: 36000),
    double strokeWidth = 4.9,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final r = (a + s * pulseAmp) * (heart ? 1 + math.cos(t) : 1 - math.cos(t));
        final bx = math.cos(t) * r;
        final by = math.sin(t) * r;
        return heart
            ? Offset(50 - by * scale, 50 - bx * scale)
            : Offset(50 + bx * scale, 50 + by * scale);
      },
    );
  }

  /// Heart outline `|x|^(2/3)` filled with a `sin(bπx)` ripple.
  factory MathCurve.heartWave({
    String name = 'Heart Wave',
    String tag = 'f(x) Heart Wave',
    double b = 6.4,
    double root = 3.3,
    double waveAmp = 0.9,
    double scaleX = 23.2,
    double scaleY = 24.5,
    int particleCount = 104,
    double trailSpan = 0.18,
    Duration loop = const Duration(milliseconds: 8400),
    Duration pulse = const Duration(milliseconds: 5600),
    Duration rotation = const Duration(milliseconds: 22000),
    double strokeWidth = 3.9,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final xLimit = math.sqrt(root);
        final x = -xLimit + progress * xLimit * 2;
        final safeRoot = math.max(0.0, root - x * x);
        final wave = waveAmp * math.sqrt(safeRoot) * math.sin(b * math.pi * x);
        final y = math.pow(x.abs(), 2 / 3) + wave;
        return Offset(50 + x * scaleX, 18 + (1.75 - y) * (scaleY + s * 1.5));
      },
    );
  }

  /// Archimedean-style spiral search.
  factory MathCurve.spiralSearch({
    String name = 'Spiral Search',
    String tag = 'Archimedean Spiral',
    double turns = 4,
    double baseRadius = 8,
    double radiusAmp = 8.5,
    double pulseAmp = 2.4,
    double scale = 1,
    int particleCount = 86,
    double trailSpan = 0.28,
    Duration loop = const Duration(milliseconds: 7800),
    Duration pulse = const Duration(milliseconds: 6800),
    Duration rotation = const Duration(milliseconds: 44000),
    double strokeWidth = 4.3,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final angle = t * turns;
        final radius = baseRadius + (1 - math.cos(t)) * (radiusAmp + s * pulseAmp);
        return Offset(50 + math.cos(angle) * radius * scale, 50 + math.sin(angle) * radius * scale);
      },
    );
  }

  /// A few interfering Fourier components — a living waveform.
  factory MathCurve.fourier({
    String name = 'Fourier Flow',
    String tag = 'Fourier Curve',
    double x1 = 17,
    double x3 = 7.5,
    double x5 = 3.2,
    double y1 = 15,
    double y2 = 8.2,
    double y4 = 4.2,
    double mixPulse = 0.16,
    int particleCount = 92,
    double trailSpan = 0.31,
    Duration loop = const Duration(milliseconds: 8400),
    Duration pulse = const Duration(milliseconds: 6800),
    Duration rotation = const Duration(milliseconds: 44000),
    double strokeWidth = 4.2,
    bool rotate = false,
  }) {
    return MathCurve(
      name: name,
      tag: tag,
      rotate: rotate,
      particleCount: particleCount,
      trailSpan: trailSpan,
      loop: loop,
      pulse: pulse,
      rotation: rotation,
      strokeWidth: strokeWidth,
      point: (progress, s) {
        final t = progress * _twoPi;
        final mix = 1 + s * mixPulse;
        final x = x1 * math.cos(t) + x3 * math.cos(3 * t + 0.6 * mix) + x5 * math.sin(5 * t - 0.4);
        final y = y1 * math.sin(t) + y2 * math.sin(2 * t + 0.25) - y4 * math.cos(4 * t - 0.5 * mix);
        return Offset(50 + x, 50 + y);
      },
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// Ready-made curve presets — default invocations of [MathCurve]'s named
/// constructors. Tweak any of them with [MathCurve.copyWith].
class MathCurves {
  MathCurves._();

  static final MathCurve originalThinking = MathCurve.roseTrail();
  static final MathCurve thinkingFive = MathCurve.roseTrail(name: 'Thinking Five', petals: 5, particleCount: 62);
  static final MathCurve thinkingNine = MathCurve.roseTrail(
    name: 'Thinking Nine',
    petals: 9,
    particleCount: 68,
    trailSpan: 0.39,
    loop: const Duration(milliseconds: 4700),
    rotation: const Duration(milliseconds: 30000),
  );

  static final MathCurve roseOrbit = MathCurve.roseOrbit();
  static final MathCurve roseCurve = MathCurve.rose();
  static final MathCurve roseTwo = MathCurve.rose(name: 'Rose Two', tag: 'r = a cos(2θ)', k: 2, particleCount: 74, trailSpan: 0.30, pulse: const Duration(milliseconds: 4300), strokeWidth: 4.6);
  static final MathCurve roseThree = MathCurve.rose(name: 'Rose Three', tag: 'r = a cos(3θ)', k: 3, particleCount: 76, trailSpan: 0.31, pulse: const Duration(milliseconds: 4400), strokeWidth: 4.6);
  static final MathCurve roseFour = MathCurve.rose(name: 'Rose Four', tag: 'r = a cos(4θ)', k: 4, particleCount: 78, trailSpan: 0.32, pulse: const Duration(milliseconds: 4500), strokeWidth: 4.6);

  static final MathCurve lissajousDrift = MathCurve.lissajous();
  static final MathCurve lemniscateBloom = MathCurve.lemniscate();
  static final MathCurve hypotrochoidLoop = MathCurve.hypotrochoid();

  static final MathCurve threePetalSpiral = MathCurve.spiral(name: 'Three-Petal Spiral', tag: 'R = 3, r = 1, d = 3', bigR: 3, particleCount: 82);
  static final MathCurve fourPetalSpiral = MathCurve.spiral(name: 'Four-Petal Spiral', tag: 'R = 4, r = 1, d = 3', bigR: 4, particleCount: 84);
  static final MathCurve fivePetalSpiral = MathCurve.spiral(name: 'Five-Petal Spiral', tag: 'R = 5, r = 1, d = 3', bigR: 5, particleCount: 85);
  static final MathCurve sixPetalSpiral = MathCurve.spiral(name: 'Six-Petal Spiral', tag: 'R = 6, r = 1, d = 3', bigR: 6, particleCount: 86);

  static final MathCurve butterflyPhase = MathCurve.butterfly();
  static final MathCurve cardioidGlow = MathCurve.cardioid();
  static final MathCurve cardioidHeart = MathCurve.cardioid(name: 'Cardioid Heart', tag: 'r = a(1 + cosθ)', a: 8.8, heart: true, particleCount: 74);
  static final MathCurve heartWave = MathCurve.heartWave();
  static final MathCurve spiralSearch = MathCurve.spiralSearch();
  static final MathCurve fourierFlow = MathCurve.fourier();

  /// Every built-in preset, in gallery order.
  static final List<MathCurve> all = [
    originalThinking,
    thinkingFive,
    thinkingNine,
    roseOrbit,
    roseCurve,
    roseTwo,
    roseThree,
    roseFour,
    lissajousDrift,
    lemniscateBloom,
    hypotrochoidLoop,
    threePetalSpiral,
    fourPetalSpiral,
    fivePetalSpiral,
    sixPetalSpiral,
    butterflyPhase,
    cardioidGlow,
    cardioidHeart,
    heartWave,
    spiralSearch,
    fourierFlow,
  ];
}
