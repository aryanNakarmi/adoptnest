import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: const Icon(Icons.email),
              ),
            ),
          ),
        ),
      );

      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
          ),
        ),
      );

      final passwordField = find.byType(TextFormField);
      await tester.enterText(passwordField, 'password123');
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Login button can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Login'),
            ),
          ),
        ),
      );

      final button = find.text('Login');
      expect(button, findsOneWidget);
      
      await tester.tap(button);
      await tester.pump();
      
      expect(button, findsOneWidget);
    });

    testWidgets('Email field has @ validation', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                decoration: InputDecoration(hintText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter email";
                  if (!value.contains('@')) return "Enter a valid email";
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'invalidemail');
      
      // Validate the form
      formKey.currentState?.validate();
      await tester.pumpAndSettle();
      
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Password field checks length', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                decoration: InputDecoration(hintText: "Password"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter password";
                  if (value.length < 8) return "Enter correct password";
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      final passwordField = find.byType(TextFormField);
      await tester.enterText(passwordField, '1234');
      
      // Validate the form
      formKey.currentState?.validate();
      await tester.pumpAndSettle();
      
      expect(find.text('Enter correct password'), findsOneWidget);
    });
  });
}