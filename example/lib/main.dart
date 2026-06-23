import 'package:flutter/material.dart';
import 'package:flutter_math_curve_loading/flutter_math_curve_loading.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Curve Loading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Math Curve Loaders',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Particle trails riding parametric curves. Tap a card to enlarge and tune it.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _CurveCard(curve: MathCurves.all[i]),
                  childCount: MathCurves.all.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _CurveCard extends StatelessWidget {
  const _CurveCard({required this.curve});

  final MathCurve curve;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFF0A0A0A),
          child: _CurveTuner(curve: curve),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: MathCurveLoading(curve: curve, size: 132, color: Colors.white),
              ),
            ),
            Text(curve.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(curve.tag, style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Enlarged preview with live sliders — demonstrates the configurable knobs
/// via `MathCurve.copyWith` and `MathCurveLoading.speed`.
class _CurveTuner extends StatefulWidget {
  const _CurveTuner({required this.curve});

  final MathCurve curve;

  @override
  State<_CurveTuner> createState() => _CurveTunerState();
}

class _CurveTunerState extends State<_CurveTuner> {
  late int _particleCount = widget.curve.particleCount;
  late double _trailSpan = widget.curve.trailSpan;
  late double _strokeWidth = widget.curve.strokeWidth;
  double _speed = 1.0;
  bool _showTrack = true;

  @override
  Widget build(BuildContext context) {
    final tuned = widget.curve.copyWith(
      particleCount: _particleCount,
      trailSpan: _trailSpan,
      strokeWidth: _strokeWidth,
    );
    return SizedBox(
      width: 420,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MathCurveLoading(curve: tuned, size: 200, color: Colors.white, speed: _speed, showTrack: _showTrack),
            const SizedBox(height: 16),
            Text(widget.curve.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text(widget.curve.tag, style: const TextStyle(color: Colors.white38)),
            const SizedBox(height: 16),
            _slider('Particles', _particleCount.toDouble(), 12, 160, (v) => setState(() => _particleCount = v.round())),
            _slider('Trail', _trailSpan, 0.08, 0.7, (v) => setState(() => _trailSpan = v)),
            _slider('Stroke', _strokeWidth, 0, 8, (v) => setState(() => _strokeWidth = v)),
            _slider('Speed', _speed, 0.1, 3, (v) => setState(() => _speed = v)),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Show track', style: TextStyle(fontSize: 13)),
              value: _showTrack,
              onChanged: (v) => setState(() => _showTrack = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70))),
        Expanded(child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged)),
        SizedBox(width: 44, child: Text(value.toStringAsFixed(value < 10 ? 2 : 0), style: const TextStyle(fontSize: 12, color: Colors.white38), textAlign: TextAlign.right)),
      ],
    );
  }
}
