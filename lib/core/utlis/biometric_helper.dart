import 'package:easy_localization/easy_localization.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();
  Future<bool> hasBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }
  Future<bool> authenticate() async {
    try {
      if (!await hasBiometrics()) return false;
      return await _auth.authenticate(
        localizedReason: 'core.biometric_reason'.tr(),
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}