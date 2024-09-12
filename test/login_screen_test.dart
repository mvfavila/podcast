import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:podcast/login_screen.dart';

void main() {
  group('handleFirebaseAuthError', () {
    test('returns correct error message for account-exists-with-different-credential', () {
      final e = FirebaseAuthException(code: 'account-exists-with-different-credential');
      expect(handleFirebaseAuthError(e), 'Incorrect user/password. Please try again.');
    });

    test('returns correct error message for invalid-credential', () {
      final e = FirebaseAuthException(code: 'invalid-credential');
      expect(handleFirebaseAuthError(e), 'Incorrect user/password. Please try again.');
    });

    test('returns correct error message for wrong-password', () {
      final e = FirebaseAuthException(code: 'wrong-password');
      expect(handleFirebaseAuthError(e), 'Incorrect user/password. Please try again.');
    });

    test('returns correct error message for user-disabled', () {
      final e = FirebaseAuthException(code: 'user-disabled');
      expect(handleFirebaseAuthError(e), 'Incorrect user/password. Please try again.');
    });

    test('returns correct error message for user-not-found', () {
      final e = FirebaseAuthException(code: 'user-not-found');
      expect(handleFirebaseAuthError(e), 'Incorrect user/password. Please try again.');
    });

    test('returns correct error message for operation-not-allowed', () {
      final e = FirebaseAuthException(code: 'operation-not-allowed');
      expect(handleFirebaseAuthError(e), 'Sign-in with Google is not enabled.');
    });

    test('returns correct error message for unknown error code', () {
      final e = FirebaseAuthException(code: 'unknown-error');
      expect(handleFirebaseAuthError(e), 'An unknown error occurred. Please try again later.');
    });
  });
}