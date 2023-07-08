import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/vault.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_crypto/local_auth_crypto.dart';

class BiometricsUnlockMechanism extends UnlockMechanism {
  BiometricsUnlockMechanism({required super.onKeyRetrieved});

  static final LocalAuthCrypto localAuthCryptoInstance =
      LocalAuthCrypto.instance;

  @override
  void build(
      BuildContext context, Map<String, dynamic> additionalUnlockData) async {
    BiometricPromptInfo promptInfo = BiometricPromptInfo(
        title: S.of(context).pleaseUseBiometrics,
        negativeButton: S.of(context).cancel,
        description: S.of(context).unlockChest);

    String? encryptedString = VaultsManager.globalAdditionalUnlockData['biometrics']['globalKey'];
    if (encryptedString != null) {
      try {
        String decryptedString = (await localAuthCryptoInstance.authenticate(
            promptInfo, encryptedString))!;
        HapticFeedback.heavyImpact();
        onKeyRetrieved(SecretKey(decryptedString.codeUnits), false, this);
      } on PlatformException catch(e, st) {
        if(e.code != 'E05') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wrongDevice)));
          debugPrint('Failed authentication: ${e.message}, Stack trace:');
          debugPrint(st.toString());
        }

      }
    }
  }

  @override
  bool canBeFocused() => false;

  @override
  Future<
      (
        SecretKey? createdKey,
        String reason,
        Map<String, dynamic> additionalUnlockData
      )> createKey(BuildContext context, VaultPolicy policy) async {
    BiometricPromptInfo promptInfo = BiometricPromptInfo(
        title: S.of(context).pleaseUseBiometrics,
        negativeButton: S.of(context).cancel,
        description: S.of(context).unlockChest);
    if(!VaultsManager.globalAdditionalUnlockData.containsKey('biometrics') || !VaultsManager.globalAdditionalUnlockData['biometrics'].containsKey('globalKey')) {
      String plainKey = md5RandomFileName().substring(0, 32);

      if(!VaultsManager.globalAdditionalUnlockData.containsKey('biometrics')) VaultsManager.globalAdditionalUnlockData['biometrics'] = {};

      VaultsManager.globalAdditionalUnlockData['biometrics']['globalKey'] = await localAuthCryptoInstance.encrypt(plainKey);
    }

    try {
      String? plainKey = await localAuthCryptoInstance.authenticate(promptInfo, VaultsManager.globalAdditionalUnlockData['biometrics']['globalKey']);

      return (
        SecretKey(plainKey!.codeUnits),
        'OK',
        <String, dynamic>{}
      );
    } on PlatformException catch(e, st) {
      if(e.code != 'E05' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wrongDevice)));
        debugPrint('Failed authentication: ${e.message}, Stack trace:');
        debugPrint(st.toString());
      }
    }

    return (
      null,
      'Authentication error',
      <String, dynamic>{}
    );
  }

  @override
  String getName(BuildContext context) => S.of(context).biometrics;

  @override
  Widget keyCreationBuild(BuildContext context, VaultPolicy policy) {
    return ListTile(leading: const Icon(Icons.warning_amber, color: Colors.orange), title: Text(S.of(context).biometricsAreLocal, style: const TextStyle(color: Colors.orange),));
  }

  @override
  Future<bool> isAvailable() async {
    return await LocalAuthentication().canCheckBiometrics &&
        (await LocalAuthentication().getAvailableBiometrics())
            .contains(BiometricType.strong);
  }

  @override
  bool isEncryptedExportAllowed() => false;
}
