import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kagcoffee/screens/checkout.dart';
import 'package:kagcoffee/screens/login.dart';
import 'package:kagcoffee/screens/register.dart';

Future<void> pumpAuthScreen(WidgetTester tester, Widget screen) async {
  // Keep the prototype's scrollable forms visible for taps.
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: screen,
      routes: {'/register': (_) => const RegisterPage()},
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Simulated checkout has no payment inputs and updates totals', (
    tester,
  ) async {
    await pumpAuthScreen(tester, const CheckoutPage());
    expect(
      find.textContaining('No payment is collected or processed.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(
      find.widgetWithText(ElevatedButton, 'Place Demo Order'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(find.text(r'Black Coffee: $2.99'), findsOneWidget);
    expect(find.text(r'Plain Bagel: $1.99'), findsOneWidget);
    expect(find.text(r'$4.98'), findsOneWidget);
    expect(find.text(r'$0.31'), findsOneWidget);
    expect(find.text(r'$5.29'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login renders email, password, and navigation controls', (
    tester,
  ) async {
    await pumpAuthScreen(tester, const LoginPage());
    expect(find.widgetWithText(TextField, 'Email:'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password:'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty login is rejected before contacting Firebase', (
    tester,
  ) async {
    await pumpAuthScreen(tester, const LoginPage());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Please fill in all fields'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login password visibility toggles in both directions', (
    tester,
  ) async {
    await pumpAuthScreen(tester, const LoginPage());
    final password = find.widgetWithText(TextField, 'Password:');
    await tester.enterText(password, 'Example123');
    expect(tester.widget<TextField>(password).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);
    expect(tester.widget<TextField>(password).controller!.text, 'Example123');
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isTrue);
  });

  testWidgets('Login opens registration without Firebase', (tester) async {
    await pumpAuthScreen(tester, const LoginPage());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Confirm Password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Registration rejects mismatched passwords before Firebase', (
    tester,
  ) async {
    await pumpAuthScreen(tester, const RegisterPage());
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Example123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm Password'),
      'Different123',
    );
    final submit = find.widgetWithText(ElevatedButton, 'Register');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Passwords do not match!'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
