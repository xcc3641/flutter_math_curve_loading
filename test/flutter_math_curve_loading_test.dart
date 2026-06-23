import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_math_curve_loading/flutter_math_curve_loading.dart';

void main() {
  test('every preset stays finite across a full loop', () {
    for (final curve in MathCurves.all) {
      expect(curve.particleCount, greaterThan(1), reason: curve.name);
      for (var p = 0.0; p <= 1.0; p += 0.05) {
        for (final s in const [0.04, 0.52, 1.0]) {
          final pt = curve.point(p, s);
          expect(pt.dx.isFinite, isTrue, reason: '${curve.name} dx');
          expect(pt.dy.isFinite, isTrue, reason: '${curve.name} dy');
        }
      }
    }
  });

  test('custom shape params stay finite', () {
    final custom = [
      MathCurve.rose(k: 6, a: 11),
      MathCurve.lissajous(a: 3, b: 5),
      MathCurve.spiral(bigR: 8, r: 1.4, d: 4),
      MathCurve.butterfly(turns: 9, power: 4),
      MathCurve.cardioid(heart: true, a: 10),
      MathCurve.hypotrochoid(bigR: 9, r: 2),
    ];
    for (final c in custom) {
      for (var p = 0.0; p <= 1.0; p += 0.1) {
        expect(c.point(p, 0.5).dx.isFinite, isTrue, reason: c.name);
        expect(c.point(p, 0.5).dy.isFinite, isTrue, reason: c.name);
      }
    }
  });

  test('copyWith overrides look, preserves shape', () {
    final base = MathCurves.roseCurve;
    final tuned = base.copyWith(particleCount: 120, strokeWidth: 6, rotate: false);
    expect(tuned.particleCount, 120);
    expect(tuned.strokeWidth, 6);
    expect(tuned.rotate, isFalse);
    // Same shape function -> same points.
    expect(tuned.point(0.3, 0.6), base.point(0.3, 0.6));
  });

  testWidgets('renders and animates without throwing', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: MathCurveLoading(curve: null, size: 120),
      ),
    );
    expect(find.byType(MathCurveLoading), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
