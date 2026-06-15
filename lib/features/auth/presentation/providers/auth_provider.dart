import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/check_cached_user_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

@injectable 
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final CheckCachedUserUseCase _checkCachedUserUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthProvider(
    this._loginUseCase,
    this._signUpUseCase,
    this._checkCachedUserUseCase,
    this._sendEmailVerificationUseCase,
    this._logoutUseCase,
  );

  bool _isLoading = false;
  UserEntity? _currentUser;
  String? _errorMessage;

  // 3. دوال الجلب (Getters) لكي تقرأها الـ UI بأمان دون التعديل عليها
  bool get isLoading => _isLoading;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // ==========================================
  // الدوال التي ستستدعيها واجهة المستخدم (UI)
  // ==========================================

  /// دالة تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    // استدعاء הـ UseCase
    final result = await _loginUseCase(email, password);

    // التعامل مع النتيجة باستخدام fold الخاصة بحزمة dartz
    return result.fold(
      (failure) {
        // حالة الفشل (Left)
        _errorMessage = failure.message;
        _setLoading(false);
        return false; // نرجع false لتعرف الـ UI أن العملية فشلت
      },
      (user) {
        // حالة النجاح (Right)
        _currentUser = user;
        _setLoading(false);
        return true; // نرجع true لتنتقل الـ UI للشاشة التالية
      },
    );
  }

  /// دالة إنشاء الحساب
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _signUpUseCase(email, password);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (user) async {
        _currentUser = user;
        // 🌟 بمجرد نجاح إنشاء الحساب، نرسل إيميل التحقق تلقائياً
        await _sendEmailVerificationUseCase();
        
        _setLoading(false);
        return true;
      },
    );
  }

  /// دالة التحقق من الجلسة المحفوظة (نستدعيها عند فتح التطبيق)
  Future<void> checkAuthStatus() async {
    // هنا لا نحتاج للودينج لأنها ستعمل في الخلفية (أثناء الـ Splash Screen مثلاً)
    final result = await _checkCachedUserUseCase();

    result.fold(
      (failure) {
        // لا يوجد مستخدم محفوظ
        _currentUser = null;
        notifyListeners();
      },
      (user) {
        // وجدنا مستخدم محفوظ في SharedPreferences
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  /// دالة تسجيل الخروج
  Future<void> logout() async {
    _setLoading(true);
    await _logoutUseCase();
    _currentUser = null; // نمسح المستخدم من الذاكرة
    _setLoading(false);
  }

  /// دالة إعادة إرسال إيميل التحقق (لو احتاجها المستخدم)
  Future<bool> resendEmailVerification() async {
    final result = await _sendEmailVerificationUseCase();
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  // ==========================================
  // دوال مساعدة داخلية (Private Helpers)
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // 🌟 نخبر الشاشة أن ترسم نفسها من جديد
  }

  void _clearError() {
    _errorMessage = null;
  }
}