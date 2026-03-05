import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adoptnest/features/auth/presentation/pages/signup_screen.dart';
import 'package:adoptnest/features/auth/presentation/state/auth_state.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';

class FakeAuthViewModel extends AuthViewModel {
  final AuthState _fakeState;
  FakeAuthViewModel(this._fakeState);

  @override
  AuthState build() => _fakeState;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {}
}

Future<Widget> buildSignupScreen(AuthState state) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(() => FakeAuthViewModel(state)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MaterialApp(home: SignupScreen()),
  );
}

// Helper: scroll until a widget is visible then tap it
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  group('SignupScreen Widget Tests', () {
    testWidgets('TW-09: renders all 5 form fields and register button',
        (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.text('Create Your Account'), findsOneWidget);
    });

    testWidgets('TW-10: shows error when name field is empty', (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      // Scroll to Register button and tap
      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      await scrollAndTap(tester, registerBtn);

      expect(find.text('Please enter Full name'), findsOneWidget);
    });

    testWidgets('TW-11: shows error for invalid email on submit',
        (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'notanemail');

      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      await scrollAndTap(tester, registerBtn);

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('TW-12: shows error when phone is too short', (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), '123');

      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      await scrollAndTap(tester, registerBtn);

      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('TW-13: shows error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), '1234567890');
      await tester.enterText(fields.at(3), 'Password123');
      await tester.enterText(fields.at(4), 'DifferentPass');

      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      await scrollAndTap(tester, registerBtn);

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('TW-14: shows loading indicator when status is loading',
        (tester) async {
      await tester.pumpWidget(
          await buildSignupScreen(const AuthState(status: AuthStatus.loading)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TW-15: Login link is present at bottom', (tester) async {
      await tester.pumpWidget(await buildSignupScreen(const AuthState()));
      await tester.pump();

      expect(find.text('Already have an account?'), findsOneWidget);
    });
  });
}