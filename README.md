# flutter_math_curve_loading

[![pub package](https://img.shields.io/pub/v/flutter_math_curve_loading.svg)](https://pub.dev/packages/flutter_math_curve_loading)
[![pub points](https://img.shields.io/pub/points/flutter_math_curve_loading)](https://pub.dev/packages/flutter_math_curve_loading/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-blue.svg)](https://pub.dev/packages/flutter_math_curve_loading)

Mathematical-curve loading indicators for Flutter. A particle trail rides a
parametric curve over a faint background track, with breathing detail and
optional slow rotation.

A Flutter port of [math-curve-loaders](https://github.com/Paidax01/math-curve-loaders).

<img src="https://raw.githubusercontent.com/xcc3641/flutter_math_curve_loading/main/images/showcase.png" width="640" alt="Six math-curve loaders: rose trail, rose curve, Lissajous, cardioid heart, butterfly, and Fourier flow" />

## Usage

```dart
import 'package:flutter_math_curve_loading/flutter_math_curve_loading.dart';

// Defaults to MathCurves.originalThinking.
const MathCurveLoading();

// Pick a preset, size, and color.
MathCurveLoading(
  curve: MathCurves.roseCurve,
  size: 132,
  color: Colors.white,
);
```

| Property     | Default                        | Description                                  |
| ------------ | ------------------------------ | -------------------------------------------- |
| `curve`      | `MathCurves.originalThinking`  | The curve preset to animate.                 |
| `size`       | `96`                           | Square edge length, in logical pixels.       |
| `color`      | ambient text color             | Particle and track color.                    |
| `showTrack`  | `true`                         | Draw the faint background track.             |
| `speed`      | `1.0`                          | Animation speed multiplier.                  |

## Presets

21 built-in curves in `MathCurves`:

`originalThinking`, `thinkingFive`, `thinkingNine`, `roseOrbit`, `roseCurve`,
`roseTwo`, `roseThree`, `roseFour`, `lissajousDrift`, `lemniscateBloom`,
`hypotrochoidLoop`, `threePetalSpiral`, `fourPetalSpiral`, `fivePetalSpiral`,
`sixPetalSpiral`, `butterflyPhase`, `cardioidGlow`, `cardioidHeart`,
`heartWave`, `spiralSearch`, `fourierFlow`.

`MathCurves.all` lists them in gallery order.

## Configuring a curve

Each preset is a default invocation of a named constructor — every **shape
parameter** is a named argument. Tune **look/timing** with `copyWith`.

```dart
// Shape: 6-petal rose with a bigger radius.
MathCurve.rose(k: 6, a: 11, scale: 3.0);

// Look/timing: more particles, longer tail, thicker track, no rotation.
MathCurves.roseCurve.copyWith(
  particleCount: 120,
  trailSpan: 0.5,
  strokeWidth: 6,
  rotate: false,
  loop: const Duration(milliseconds: 3000),
);

// Combine both.
MathCurveLoading(
  curve: MathCurve.spiral(bigR: 8, r: 1.4).copyWith(particleCount: 100),
  speed: 1.5,
);
```

Named constructors (with their key shape params):

| Constructor              | Shape params                                   |
| ------------------------ | ---------------------------------------------- |
| `MathCurve.roseTrail`    | `petals`, `detail`, `baseRadius`, `scale`      |
| `MathCurve.roseOrbit`    | `k`, `orbitRadius`, `detail`, `scale`          |
| `MathCurve.rose`         | `k`, `a`, `aBoost`, `breathBase`, `scale`      |
| `MathCurve.lissajous`    | `a`, `b`, `phase`, `amp`, `yScale`             |
| `MathCurve.lemniscate`   | `a`, `boost`                                   |
| `MathCurve.hypotrochoid` | `bigR`, `r`, `d`, `scale`                      |
| `MathCurve.spiral`       | `bigR`, `r`, `d`, `scale`, `breath`            |
| `MathCurve.butterfly`    | `turns`, `scale`, `cosWeight`, `power`         |
| `MathCurve.cardioid`     | `a`, `scale`, `heart`                          |
| `MathCurve.heartWave`    | `b`, `root`, `waveAmp`, `scaleX`, `scaleY`     |
| `MathCurve.spiralSearch` | `turns`, `baseRadius`, `radiusAmp`, `scale`    |
| `MathCurve.fourier`      | `x1`, `x3`, `x5`, `y1`, `y2`, `y4`, `mixPulse` |

Every constructor also takes the look/timing knobs `particleCount`,
`trailSpan`, `loop`, `pulse`, `rotation`, `strokeWidth`, and `rotate`.

For a fully bespoke shape, use the base constructor with your own `point` — it
maps a normalized `progress` (0..1) and a breathing `detailScale` (~0.04..1) to
an `Offset` in a `0..100` box (origin top-left, y down):

```dart
MathCurve(
  name: 'Circle',
  tag: 'r = const',
  particleCount: 64,
  trailSpan: 0.4,
  loop: const Duration(milliseconds: 3000),
  pulse: const Duration(milliseconds: 4000),
  strokeWidth: 5,
  point: (progress, detailScale) {
    final t = progress * 2 * math.pi;
    return Offset(50 + 40 * math.cos(t), 50 + 40 * math.sin(t));
  },
);
```

## Example

A gallery of every preset that runs in the browser:

```sh
cd example
flutter run -d chrome
```
