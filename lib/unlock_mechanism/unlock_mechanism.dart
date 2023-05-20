import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/biometrics_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/password_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/pin_code_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/pattern_unlock_mechanism.dart';
import 'package:life_chest/vault.dart';

abstract class UnlockMechanism {
  const UnlockMechanism({required this.onKeyRetrieved});
  /// Once published, these fields shouldn't be edited.
  static final Map<UnlockMechanism Function(void Function(SecretKey retrievedKey, bool didPushed) onKeyRetrieved), String> unlockMechanisms = {
    (retrievedKey) => PasswordUnlockMechanism(onKeyRetrieved: retrievedKey): 'password',
    (retrievedKey) => PinUnlockMechanism(onKeyRetrieved: retrievedKey): 'pin code',
    (retrievedKey) => SchemeUnlockMechanism(onKeyRetrieved: retrievedKey): 'scheme',
    (retrievedKey) => BiometricsUnlockMechanism(onKeyRetrieved: retrievedKey): 'biometrics'
  };

  final Function(SecretKey retrievedKey, bool didPushed) onKeyRetrieved;

  void build(BuildContext context, Map<String, dynamic> additionalUnlockData);

  Widget keyCreationBuild(BuildContext context, VaultPolicy policy);

  void focus() {}

  void creationFocus() {}

  Future<(SecretKey? createdKey, String reason, Map<String, dynamic> additionalUnlockData)> createKey(BuildContext context, VaultPolicy policy);

  String getName(BuildContext context);

  bool canBeFocused();

  Future<bool> isAvailable() => Future.value(true);
}