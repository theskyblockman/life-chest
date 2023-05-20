import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/vault.dart';
import 'package:pattern_lock/pattern_lock.dart';

class SchemeUnlockMechanism extends UnlockMechanism {
  SchemeUnlockMechanism({required super.onKeyRetrieved});
  final FocusNode defineButtonNode = FocusNode();

  @override
  void build(BuildContext context, Map<String, dynamic> additionalUnlockData) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(body: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Flexible(child: Text(S.of(context).enterTheChestPassword, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24))),
        Flexible(child:
          PatternFormField(onCodeCreated: (code) {
            onKeyRetrieved(SecretKey(passwordToCryptKey(code)), true);
          },))
      ]));
    }));
  }

  @override
  Future<(SecretKey? createdKey, String reason, Map<String, dynamic> additionalUnlockData)> createKey(BuildContext context, VaultPolicy policy) {
    if(policy.vaultUnlockAdditionalData['scheme'] != null) {
      return Future.value((SecretKey(passwordToCryptKey(policy.vaultUnlockAdditionalData['scheme'])), 'OK', <String, dynamic>{}));
    }
    return Future.value((null, S.of(context).errorChestSchemeShouldNotBeEmpty, <String, dynamic>{}));
  }

  @override
  String getName(BuildContext context) => S.of(context).scheme;

  @override
  Widget keyCreationBuild(BuildContext context, VaultPolicy policy) {
    return ListTile(titleAlignment: ListTileTitleAlignment.center, title: OutlinedButton(focusNode: defineButtonNode, onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(), body: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Flexible(child: Text(S.of(context).enterTheChestScheme, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24))),
        Flexible(child:
        PatternFormField(validator: (value) {
          if(value == null || value.isEmpty) return S.of(context).errorChestSchemeShouldNotBeEmpty;
          return null;
        }, onCodeCreated: (code) {
          policy.vaultUnlockAdditionalData['scheme'] = code;
          Navigator.of(context).pop();
        }))
      ])
      )));
    }, child: Text(S.of(context).defineScheme)));
  }

  @override
  bool canBeFocused() => true;

  @override
  void creationFocus() {
    defineButtonNode.requestFocus();
  }
}

class PatternFormField extends FormField<String> {
  PatternFormField({super.key, FormFieldSetter<String>? onSaved, FormFieldValidator<String>? validator, AutovalidateMode autovalidate = AutovalidateMode.disabled, void Function(String code)? onCodeCreated}) : super(
    onSaved: onSaved,
    validator: validator,
    autovalidateMode: autovalidate,
    builder: (state) {
      return PatternLock(onInputComplete: (List<int> completedPattern) {
        if(completedPattern.isEmpty) return;

        String createdUniqueCode = '';

        for(int patternPoint in completedPattern) {
          createdUniqueCode += patternPoint.toString();
        }
        state.didChange(createdUniqueCode);
        if(onCodeCreated != null) onCodeCreated(createdUniqueCode);
        debugPrint('$completedPattern: $createdUniqueCode');
      }, showInput: true, fillPoints: true, pointRadius: 5);
    }
  );
}