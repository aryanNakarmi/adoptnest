import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adoptnest/features/auth/presentation/pages/login_screen.dart';
import 'package:adoptnest/features/auth/presentation/state/auth_state.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';

class FakeAuthViewModel extends AuthViewModel {
  final AuthState _fakeState;
  FakeAuthViewModel(this._fakeState);

  @override
  AuthState build() => _fakeState;

  @override
  Future<void> login({required String email, required String password}) async {}
}

Future<Widget> buildLoginScreen(AuthState state) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(() => FakeAuthViewModel(state)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('TW-01: renders email, password fields and login button',
        (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('TW-02: shows validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      await tester.tap(find.text('Login').last);
      await tester.pump();

      expect(find.text('Please enter email'), findsOneWidget);
    });

    testWidgets('TW-03: shows validation error for invalid email format',
        (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.text('Login').last);
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('TW-04: shows validation error when password is empty',
        (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Login').last);
      await tester.pump();

      expect(find.text('Please enter password'), findsOneWidget);
    });

    testWidgets('TW-05: shows loading indicator when status is loading',
        (tester) async {
      await tester.pumpWidget(
          await buildLoginScreen(const AuthState(status: AuthStatus.loading)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TW-06: Sign Up text is present', (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('TW-07: password field renders with lock icon', (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      expect(find.byIcon(Icons.lock), findsWidgets);
    });

    testWidgets('TW-08: toggles password visibility on suffix icon tap',
        (tester) async {
      await tester.pumpWidget(await buildLoginScreen(const AuthState()));
      await tester.pump();

      // visibility_outlined means password is currently obscured
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // after tap it becomes visibility_off_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
} 