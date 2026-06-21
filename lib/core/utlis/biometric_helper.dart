import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  // فحص ما إذا كان الجهاز يدعم البصمة أو التعرف على الوجه
  Future<bool> hasBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // إظهار واجهة البصمة للمستخدم وإرجاع النتيجة (نجاح أو فشل)
  Future<bool> authenticate() async {
    try {
      if (!await hasBiometrics()) return false;

      // التعديل هنا: نمرر الخصائص مباشرة بدون AuthenticationOptions
      return await _auth.authenticate(
        localizedReason: 'يرجى المصادقة للوصول إلى حسابك',
        persistAcrossBackgrounding: true, // (stickyAuth سابقاً) تبقي الواجهة مفتوحة إذا التطبيق ذهب للخلفية
        biometricOnly: true,              // إجبار النظام على طلب البصمة ومنع استخدام الرقم السري للجهاز
      );
    } catch (e) {
      return false;
    }
  }
}