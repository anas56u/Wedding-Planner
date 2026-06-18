import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/features/auth/domain/usecases/check_email_verification_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:provider_test/features/auth/domain/usecases/update_user_info_usecase.dart';
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
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase; 
  final UpdateUserInfoUseCase _updateUserInfoUseCase;

  AuthProvider(
    this._loginUseCase,
    this._signUpUseCase,
    this._checkCachedUserUseCase,
    this._sendEmailVerificationUseCase,
    this._logoutUseCase,
    this._checkEmailVerificationUseCase,
    this._sendPasswordResetUseCase,
    this._updateUserInfoUseCase,
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

/// دالة تحديث بيانات المستخدم (الاسم والعمر)
  Future<bool> updateUserProfile(String name, int age) async {
    // نتأكد أولاً أن هناك مستخدم مسجل دخول
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    // نستدعي الـ UseCase ونمرر له الـ uid الخاص بالمستخدم الحالي
    final result = await _updateUserInfoUseCase(_currentUser!.uid, name, age);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false; // فشل التحديث
      },
      (_) {
        // 🌟 أفضل الممارسات (Best Practice): التحديث التفاعلي (Reactive UI)
        // بدلاً من استدعاء البيانات من فايربيس مرة أخرى، نقوم بتحديث كائن المستخدم المحلي
        // هذا سيجعل الاسم الجديد يظهر في الشاشة فوراً دون أي تأخير
        
        _currentUser = UserEntity(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          isEmailVerified: _currentUser!.isEmailVerified,
          name: name, // الاسم الجديد
          age: age,   // العمر الجديد
        );
        
        _setLoading(false); // الدالة هذه تحتوي على notifyListeners() بداخلها فستحدث الواجهة
        return true; // نجح التحديث
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
        return false; // فشل الإرسال
      },
      (_) {
        _setLoading(false);
        return true; // تم الإرسال بنجاح
      },
    );
  }


// أضف هذه الدالة داخل الـ AuthProvider
  Future<bool> checkEmailVerification() async {
    _setLoading(true);
    _clearError();

    // هنا نحن نستدعي الـ UseCase الجديد (تأكد من إضافته للـ Constructor)
    final result = await _checkEmailVerificationUseCase(); // اسم المتغير حسب ما تعرفه في الأعلى

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false; // الإيميل لم يتأكد بعد
      },
      (updatedUser) {
        _currentUser = updatedUser; // 🌟 هنا يتم تحديث حالة التطبيق بالكامل
        _setLoading(false);
        return true; // تم التأكيد بنجاح! يمكن نقله للـ Dashboard
      },
    );
  }  Future<bool> login(String email, String password,bool rememberMe) async {
    _setLoading(true);
    _clearError();

    // استدعاء הـ UseCase
    final result = await _loginUseCase(email, password, rememberMe);

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
  Future<bool> signUp(String email, String password, String name, int age) async {
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