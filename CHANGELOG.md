## 0.0.1

Initial release — a Flutter port of
[math-curve-loaders](https://github.com/Paidax01/math-curve-loaders).

* `MathCurveLoading` widget — a particle trail rides a parametric curve over a
  faint background track, with breathing detail and optional slow rotation.
* 21 built-in `MathCurves` presets: rose trails, polar roses, Lissajous,
  lemniscate, hypotrochoid, rolling-circle spirals, butterfly, cardioids,
  heart wave, spiral search, and a Fourier flow.
* Fully configurable curves: a named constructor per family
  (`MathCurve.rose`, `MathCurve.spiral`, `MathCurve.lissajous`, …) exposes
  every shape parameter, and `MathCurve.copyWith` overrides look/timing
  (`particleCount`, `trailSpan`, `loop`, `pulse`, `rotation`, `strokeWidth`,
  `rotate`). Build a bespoke shape with the base constructor + your own `point`.
* `MathCurveLoading` knobs: `color`, `size`, `speed`, `showTrack`.
