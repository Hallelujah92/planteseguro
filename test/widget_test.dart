import 'package:flutter_test/flutter_test.dart';
import 'package:plante_seguro/app.dart';

void main() {
  testWidgets('renders Plante Seguro welcome screen', (tester) async {
    await tester.pumpWidget(const PlanteSeguroApp());
    expect(find.text('Plante Seguro'), findsOneWidget);
  });
}
