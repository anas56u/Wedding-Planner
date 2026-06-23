import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/utlis/biometric_helper.dart';
import 'package:provider_test/features/auth/domain/usecases/check_email_verification_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/delete_account_with_biometric_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/update_user_info_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/enable_biometric_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/disable_biometric_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/login_with_biometric_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/is_biometric_enabled_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/check_cached_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final CheckCachedUserUseCase _checkCachedUserUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final UpdateUserInfoUseCase _updateUserInfoUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  final EnableBiometricUseCase _enableBiometricUseCase;
  final DisableBiometricUseCase _disableBiometricUseCase;
  final LoginWithBiometricUseCase _loginWithBiometricUseCase;
  final IsBiometricEnabledUseCase _isBiometricEnabledUseCase;
  final DeleteAccountWithBiometricUseCase _deleteAccountWithBiometricUseCase;

  AuthProvider(
    this._loginUseCase,
    this._signUpUseCase,
    this._checkCachedUserUseCase,
    this._sendEmailVerificationUseCase,
    this._logoutUseCase,
    this._checkEmailVerificationUseCase,
    this._sendPasswordResetUseCase,
    this._updateUserInfoUseCase,
    this._deleteAccountUseCase,
    this._enableBiometricUseCase,
    this._disableBiometricUseCase,
    this._loginWithBiometricUseCase,
    this._isBiometricEnabledUseCase,
    this._deleteAccountWithBiometricUseCase,
  );

  bool _isLoading = false;
  UserEntity? _currentUser;
  String? _errorMessage;
  bool _isBiometricEnabled = false;

  bool get isLoading => _isLoading;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<void> checkAuthStatus() async {
    _clearError();

    final bioStatusResult = await _isBiometricEnabledUseCase();
    _isBiometricEnabled = bioStatusResult.fold(
      (_) => false,
      (enabled) => enabled,
    );

    if (_isBiometricEnabled) {
      final BiometricHelper biometricHelper = BiometricHelper();
      final hasHardware = await biometricHelper.hasBiometrics();

      if (hasHardware) {
        final authenticated = await biometricHelper.authenticate();

        if (authenticated) {
          _setLoading(true);

          final loginResult = await _loginWithBiometricUseCase();

          loginResult.fold(
            (failure) {
              _errorMessage = failure.message;
              _currentUser = null;
            },
            (user) {
              _currentUser = user;
            },
          );
          _setLoading(false);
          return;
        } else {
          _currentUser = null;
          notifyListeners();
          return;
        }
      }
    }

    final result = await _checkCachedUserUseCase();

    result.fold(
      (failure) {
        _currentUser = null;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  Future<bool> deleteAccountWithBiometric() async {
    _setLoading(true);
    _clearError();

    final BiometricHelper biometricHelper = BiometricHelper();
    final hasHardware = await biometricHelper.hasBiometrics();

    if (!hasHardware) {
      _errorMessage = "الجهاز الحالي لا يدعم المصادقة الحيوية.";
      _setLoading(false);
      return false;
    }

    final authenticated = await biometricHelper.authenticate();

    if (!authenticated) {
      _errorMessage = "تم إلغاء نظام المصادقة أو فشل التعرف على البصمة.";
      _setLoading(false);
      return false;
    }

    final result = await _deleteAccountWithBiometricUseCase();

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _currentUser = null;
        _isBiometricEnabled = false;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> toggleEnableBiometric(String email, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _enableBiometricUseCase(email, password);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _isBiometricEnabled = true;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> toggleDisableBiometric() async {
    _setLoading(true);
    _clearError();

    final result = await _disableBiometricUseCase();

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _isBiometricEnabled = false;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> loadBiometricSettingsStatus() async {
    final result = await _isBiometricEnabledUseCase();
    _isBiometricEnabled = result.fold((_) => false, (enabled) => enabled);
    notifyListeners();
  }

  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();
    final result = await _deleteAccountUseCase(password);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _currentUser = null;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> updateUserProfile(String name, int age) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _clearError();
    final result = await _updateUserInfoUseCase(_currentUser!.uid, name, age);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _currentUser = UserEntity(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          isEmailVerified: _currentUser!.isEmailVerified,
          name: name,
          age: age,
        );
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    final result = await _sendPasswordResetUseCase(email);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> checkEmailVerification() async {
    _setLoading(true);
    _clearError();
    final result = await _checkEmailVerificationUseCase();
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (updatedUser) {
        _currentUser = updatedUser;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    _setLoading(true);
    _clearError();
    final result = await _loginUseCase(email, password, rememberMe);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (user) {
        _currentUser = user;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    int age,
  ) async {
    _setLoading(true);
    _clearError();
    final result = await _signUpUseCase(email, password, name, age);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (user) async {
        _currentUser = user;
        await _sendEmailVerificationUseCase();
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    _setLoading(true);

    await _logoutUseCase();

    _currentUser = null;

    _isBiometricEnabled = false;

    _setLoading(false);
  }

  Future<bool> resendEmailVerification() async {
    final result = await _sendEmailVerificationUseCase();
    return result.fold((failure) {
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) => true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
