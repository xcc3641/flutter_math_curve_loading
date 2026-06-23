import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_math_curve_loading_example/main.dart';

void main() {
  testWidgets('gallery renders', (tester) async {
    await tester.pumpWidget(const GalleryApp());
    expect(find.text('Math Curve Loaders'), findsOneWidget);
  });
}
