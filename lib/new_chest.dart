import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_chest/unlock_mechanism/password_unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/vault.dart';
import 'package:life_chest/generated/l10n.dart';

/// The page to create and parameter a new chest
class CreateNewChestPage extends StatefulWidget {
  const CreateNewChestPage({super.key});

  @override
  State<StatefulWidget> createState() => CreateNewChestPageState();
}

/// The [CreateNewChestPage]'s state
class CreateNewChestPageState extends State<CreateNewChestPage> {
  VaultPolicy policy = VaultPolicy(vaultUnlockAdditionalData: {});
  FocusNode nameNode = FocusNode();
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController timeoutController = TextEditingController();
  UnlockMechanism? currentMechanism;

  @override
  Widget build(BuildContext context) {
    currentMechanism ??= PasswordUnlockMechanism(onKeyRetrieved: (retrievedKey, didPushed) => null);
    return Scaffold(
      appBar:
          AppBar(title: Text(S.of(context).createANewChest)),
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
              onEditingComplete: () => currentMechanism?.creationFocus(),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: S.of(context).chestName),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.of(context)
                      .errorChestNameShouldNotBeEmpty;
                }

                return null;
              },
            ),
            focusNode: nameNode,
            leading: const Icon(Icons.perm_identity),
          ),
          const Divider(),
          ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(spacing: 5.0, clipBehavior: Clip.none, children: [
                ...List.generate(UnlockMechanism.unlockMechanisms.length, (index) {
                  dynamic mechanismBuilder = List.from(UnlockMechanism.unlockMechanisms.keys)[index]!;
                  UnlockMechanism mechanism = mechanismBuilder((retrievedKey, didPushed) => null);
                  if(mechanism.runtimeType == currentMechanism?.runtimeType) {
                    mechanism = currentMechanism!;
                  }

                  return FutureBuilder<bool>(future: mechanism.isAvailable(), initialData: false, builder: (context, snapshot) {
                    return ChoiceChip(label: Text(mechanism.getName(context)), selected: mechanism == currentMechanism, onSelected: snapshot.data! ? (value) {
                      setState(() {
                        currentMechanism = mechanism;
                        policy.unlockType = UnlockMechanism.unlockMechanisms[mechanismBuilder]!;
                      });
                    } : null);
                  });




                })
              ]),
            ),
          ),
          currentMechanism != null ? currentMechanism!.keyCreationBuild(context, policy) : Container(),
          const Divider(),
          ListTile(
            trailing: Switch(
                onChanged: (value) => setState(() {
                      policy.shouldDisconnectWhenVaultOpened = value;
                    }),
                value: policy.shouldDisconnectWhenVaultOpened),
            title: Text(S.of(context).shouldEnterAirplaneMode),
          ),
          const Divider(),
          ListTile(
              title: Text(
                  S.of(context).whatShouldBeDoneAfterUnfocus)),
          ListTile(
            title: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                      value: 0,
                      label: Text(S.of(context).doNothing)),
                  ButtonSegment(
                      value: 1,
                      label: Text(S.of(context).notify)),
                  ButtonSegment(
                      value: 2,
                      label: Text(S.of(context).closeChest)),
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
            var createdKey = await currentMechanism!.createKey(context, policy);
            policy.key = createdKey.$1;
            Vault createdVault =
                await VaultsManager.createVaultFromPolicy(policy);
            createdVault.additionalUnlockData = createdKey.$3;
            VaultsManager.storedVaults.add(createdVault);
            VaultsManager.saveVaults();
            if (context.mounted) Navigator.pop(context);
          }
        },
        label: Text(S.of(context).createTheNewChest),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    nameNode.dispose();
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
