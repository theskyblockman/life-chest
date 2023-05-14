import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/password_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/pin_code_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/scheme_unlock_mechanism.dart';
import 'package:life_chest/vault.dart';

abstract class UnlockMechanism {
  const UnlockMechanism({required this.onKeyRetrieved});
  /// Once published, these fields shouldn't be edited.
  static final Map<UnlockMechanism Function(void Function(SecretKey retrievedKey) onKeyRetrieved), String> unlockMechanisms = {
    (retrievedKey) => PasswordUnlockMechanism(onKeyRetrieved: retrievedKey): 'password',
    (retrievedKey) => PinUnlockMechanism(onKeyRetrieved: retrievedKey): 'pin code',
    (retrievedKey) => SchemeUnlockMechanism(onKeyRetrieved: retrievedKey): 'scheme'
  };

  final Function(SecretKey retrievedKey) onKeyRetrieved;

  void build(BuildContext context);

  Widget keyCreationBuild(BuildContext context, VaultPolicy policy);

  void focus() {}

  void creationFocus() {}

  (SecretKey? createdKey, String reason) createKey(BuildContext context, VaultPolicy policy);

  String getName(BuildContext context);

  bool canBeFocused();
}