import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/vault.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The page to create and parameter a new chest
class CreateNewChestPage extends StatefulWidget {
  const CreateNewChestPage({super.key});

  @override
  State<StatefulWidget> createState() => CreateNewChestPageState();
}

/// The [CreateNewChestPage]'s state
class CreateNewChestPageState extends State<CreateNewChestPage> {
  VaultPolicy policy = VaultPolicy();
  FocusNode nameNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController timeoutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.createANewChest)),
      body: SingleChildScrollView(
          child: Form(
        key: formState,
        child: Column(children: [
          ListTile(
            title: TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                policy.vaultName = value;
              },
              onEditingComplete: () => passwordNode.requestFocus(),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.chestName),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .errorChestNameShouldNotBeEmpty;
                }

                return null;
              },
            ),
            focusNode: nameNode,
            leading: const Icon(Icons.perm_identity),
          ),
          ListTile(
            title: TextFormField(
              maxLines: 1,
              onChanged: (value) {
                policy.vaultPassword = value;
              },
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.chestPassword),
              obscureText: true,
              focusNode: passwordNode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .errorChestPasswordShouldNotBeEmpty;
                }
                if (value.length < 8 && !kDebugMode) {
                  return AppLocalizations.of(context)!
                      .errorChestPasswordMoreCharacters;
                }
                if (!value.contains(RegExp(r'[A-Z]')) && !kDebugMode) {
                  return AppLocalizations.of(context)!
                      .errorChestPasswordMoreUppercaseLetter;
                }
                if (!value.contains(RegExp(r'[a-z]')) && !kDebugMode) {
                  return AppLocalizations.of(context)!
                      .errorChestPasswordMoreLowercaseLetter;
                }
                if (!value.contains(RegExp(r'\d')) && !kDebugMode) {
                  return AppLocalizations.of(context)!
                      .errorChestPasswordMoreDigits;
                }

                return null;
              },
            ),
            leading: const Icon(Icons.lock_outline),
          ),
          const Divider(),
          ListTile(
            trailing: Switch(
                onChanged: (value) => setState(() {
                      policy.shouldDisconnectWhenVaultOpened = value;
                    }),
                value: policy.shouldDisconnectWhenVaultOpened),
            title: Text(AppLocalizations.of(context)!.shouldEnterAirplaneMode),
          ),
          const Divider(),
          ListTile(
              title: Text(
                  AppLocalizations.of(context)!.whatShouldBeDoneAfterUnfocus)),
          ListTile(
            title: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                      value: 0,
                      label: Text(AppLocalizations.of(context)!.doNothing)),
                  ButtonSegment(
                      value: 1,
                      label: Text(AppLocalizations.of(context)!.notify)),
                  ButtonSegment(
                      value: 2,
                      label: Text(AppLocalizations.of(context)!.closeChest)),
                ],
                selected: {
                  policy.securityLevel
                },
                multiSelectionEnabled: false,
                emptySelectionAllowed: false,
                onSelectionChanged: (newSet) {
                  setState(() {
                    policy.securityLevel = newSet.first;
                  });
                }),
          )
        ]),
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formState.currentState!.validate()) {
            Vault createdVault =
                await VaultsManager.createVaultFromPolicy(policy);
            VaultsManager.storedVaults.add(createdVault);
            VaultsManager.saveVaults();
            if (context.mounted) Navigator.pop(context);
          }
        },
        label: Text(AppLocalizations.of(context)!.createTheNewChest),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    nameNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }
}

class HourMinsFormatter extends TextInputFormatter {
  late RegExp pattern;

  HourMinsFormatter() {
    pattern = RegExp(r'^[\d:]+$');
  }

  String pack(String value) {
    if (value.length != 4) return value;
    return '${value.substring(0, 2)}:${value.substring(2, 4)}';
  }

  String unpack(String value) {
    return value.replaceAll(':', '');
  }

  String complete(String value) {
    if (value.length >= 4) return value;
    final multiplier = 4 - value.length;
    return ('0' * multiplier) + value;
  }

  String limit(String value) {
    if (value.length <= 4) return value;
    return value.substring(value.length - 4, value.length);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!pattern.hasMatch(newValue.text)) return oldValue;

    TextSelection newSelection = newValue.selection;

    String toRender;
    String newText = newValue.text;

    toRender = '';
    if (newText.length < 5) {
      if (newText == '00:0') {
        toRender = '';
      } else {
        toRender = pack(complete(unpack(newText)));
      }
    } else if (newText.length == 6) {
      toRender = pack(limit(unpack(newText)));
    }

    newSelection = newValue.selection.copyWith(
      baseOffset: min(toRender.length, toRender.length),
      extentOffset: min(toRender.length, toRender.length),
    );

    return TextEditingValue(
      text: toRender,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
