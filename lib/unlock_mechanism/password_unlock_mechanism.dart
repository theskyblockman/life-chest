import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/vault.dart';

class PasswordUnlockMechanism extends UnlockMechanism {
  PasswordUnlockMechanism({required super.onKeyRetrieved});
  bool failedPasswordForVault = false;
  TextEditingController passwordField = TextEditingController();
  FocusNode passwordFieldFocusNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  void build(BuildContext context, Map<String, dynamic> additionalUnlockData) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  title: Text(S.of(context).enterTheChestPassword),
                  content: TextField(
                    key: const ValueKey('PASSWORD'),
                      autofocus: true,
                      controller: passwordField,
                      focusNode: passwordFieldFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorText: failedPasswordForVault
                              ? S.of(context).wrongPassword
                              : null)),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          onKeyRetrieved(
                              SecretKey(passwordToCryptKey(passwordField.text)),
                              true,
                              this);
                        },
                        child: Text(S.of(context).validate))
                  ]);
            },
          );
        }).then((value) => failedPasswordForVault = false);
  }

  @override
  Widget keyCreationBuild(BuildContext context, VaultPolicy policy) {
    return ListTile(
      title: TextFormField(
        key: const ValueKey('PASSWORD'),
        maxLines: 1,
        onChanged: (value) {
          policy.vaultUnlockAdditionalData['password'] = value;
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: S.of(context).chestPassword),
        obscureText: true,
        focusNode: passwordNode,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).errorChestPasswordShouldNotBeEmpty;
          }
          if (value.length < 8 && !kDebugMode) {
            return S.of(context).errorChestPasswordMoreCharacters;
          }
          if (!value.contains(RegExp(r'[A-Z]')) && !kDebugMode) {
            return S.of(context).errorChestPasswordMoreUppercaseLetter;
          }
          if (!value.contains(RegExp(r'[a-z]')) && !kDebugMode) {
            return S.of(context).errorChestPasswordMoreLowercaseLetter;
          }
          if (!value.contains(RegExp(r'\d')) && !kDebugMode) {
            return S.of(context).errorChestPasswordMoreDigits;
          }

          return null;
        },
      ),
      leading: const Icon(Icons.lock_outline),
    );
  }

  @override
  void focus() {
    passwordFieldFocusNode.requestFocus();
  }

  @override
  void creationFocus() {
    passwordNode.requestFocus();
  }

  @override
  Future<
      (
        SecretKey? createdKey,
        String reason,
        Map<String, dynamic> additionalUnlockData
      )> createKey(BuildContext context, VaultPolicy policy) {
    if (policy.vaultUnlockAdditionalData['password'] != null) {
      return Future.value((
        SecretKey(
            passwordToCryptKey(policy.vaultUnlockAdditionalData['password'])),
        'OK',
        <String, dynamic>{}
      ));
    }
    return Future.value((
      null,
      S.of(context).errorChestNameShouldNotBeEmpty,
      <String, dynamic>{}
    ));
  }

  @override
  String getName(BuildContext context) => S.of(context).password;

  @override
  bool canBeFocused() => true;

  @override
  bool isEncryptedExportAllowed() => true;
}
