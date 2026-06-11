// مسار الملف: lib/core/errors/failures.dart

/// الكلاس الأساسي المجرد الذي سترث منه كل أنواع الأخطاء في التطبيق
abstract class Failure {
  final String message;

  Failure(this.message);
}

/// خطأ يحدث عند فشل الاتصال بالخادم (الإنترنت أو الـ API)
class ServerFailure extends Failure {
  ServerFailure([String message = 'حدث خطأ في الاتصال بالخادم']) : super(message);
}

/// خطأ يحدث عند فشل التعامل مع قاعدة البيانات المحلية (مثل Hive أو SharedPreferences)
class CacheFailure extends Failure {
  CacheFailure([String message = 'حدث خطأ في جلب البيانات المحلية']) : super(message);
}

/// خطأ يحدث عندما يقوم المستخدم بإدخال بيانات غير صالحة (مثل ترك حقل البحث فارغاً)
class InputFailure extends Failure {
  InputFailure(String message) : super(message);
}