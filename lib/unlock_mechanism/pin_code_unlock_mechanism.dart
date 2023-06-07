import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/vault.dart';

class PinUnlockMechanism extends UnlockMechanism {
  PinUnlockMechanism({required super.onKeyRetrieved});
  bool failedPinForVault = false;
  TextEditingController pinField = TextEditingController();
  FocusNode pinFieldFocusNode = FocusNode();
  FocusNode pinNode = FocusNode();

  @override
  void build(BuildContext context, Map<String, dynamic> additionalUnlockData) {
    showDialog(
        context: context,
        builder: (context) {
          pinField = TextEditingController();
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  title: Text(S.of(context).enterThePinCode),
                  content: TextField(
                      key: const ValueKey('PASSCODE'),
                      autofocus: true,
                      controller: pinField,
                      focusNode: pinFieldFocusNode,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorText: failedPinForVault
                              ? S.of(context).wrongPinCode
                              : null)),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          onKeyRetrieved(
                              SecretKey(passwordToCryptKey(pinField.text)),
                              true);
                        },
                        child: Text(S.of(context).validate))
                  ]);
            },
          );
        }).then((value) => failedPinForVault = false);
  }

  @override
  Widget keyCreationBuild(BuildContext context, VaultPolicy policy) {
    return ListTile(
      title: TextFormField(
        key: const ValueKey('PASSCODE'),
        maxLines: 1,
        onChanged: (value) {
          policy.vaultUnlockAdditionalData['pin'] = value;
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: S.of(context).chestPinCode),
        obscureText: true,
        focusNode: pinNode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).errorChestPinCodeShouldNotBeEmpty;
          }
          if (value.length < 4 && !kDebugMode) {
            return S.of(context).errorChestPinCodeMoreCharacters;
          }
          return null;
        },
      ),
      leading: const Icon(Icons.lock_outline),
    );
  }

  @override
  void focus() {
    pinFieldFocusNode.requestFocus();
  }

  @override
  void creationFocus() {
    pinNode.requestFocus();
  }

  @override
  Future<
      (
        SecretKey? createdKey,
        String reason,
        Map<String, dynamic> additionalUnlockData
      )> createKey(BuildContext context, VaultPolicy policy) {
    if (policy.vaultUnlockAdditionalData['pin'] != null) {
      return Future.value((
        SecretKey(passwordToCryptKey(policy.vaultUnlockAdditionalData['pin'])),
        'OK',
        <String, dynamic>{}
      ));
    }
    return Future.value((
      null,
      S.of(context).errorChestPinCodeShouldNotBeEmpty,
      <String, dynamic>{}
    ));
  }

  @override
  String getName(BuildContext context) => S.of(context).pinCode;

  @override
  bool canBeFocused() => true;
}
