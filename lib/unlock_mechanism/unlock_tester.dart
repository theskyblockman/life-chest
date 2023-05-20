import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/vault.dart';

class UnlockTester {
  const UnlockTester(this.chest, {required this.onKeyIssued});
  final Function(SecretKey issuedKey, bool didPushed) onKeyIssued;
  final Vault chest;

  bool shouldUseChooser(BuildContext context) {

    for(var unlockMechanismType in UnlockMechanism.unlockMechanisms.entries) {
      if(unlockMechanismType.value == chest.unlockMechanismType) {
        UnlockMechanism mechanism = unlockMechanismType.key(
                (SecretKey retrievedKey, bool didPushed) {
              onKeyIssued(retrievedKey, didPushed);
              if(kDebugMode) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('the retriever issued a key: ${retrievedKey.toString()}')));
            }
        );
        mechanism.build(context, chest.additionalUnlockData);
        return false;
      }
    }

    return true;
  }
}

class UnlockChooser extends StatelessWidget {
  const UnlockChooser({super.key, required this.onKeyIssued});
  final Function(SecretKey issuedKey, bool didPushed) onKeyIssued;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Unlock tester')), body: ListView.builder(itemBuilder: (context, index) {
      UnlockMechanism mechanism = List.from(UnlockMechanism.unlockMechanisms.keys)[index]!(
              (SecretKey retrievedKey, bool didPushed) {
            onKeyIssued(retrievedKey, didPushed);
            if(kDebugMode) {
              retrievedKey.extractBytes().then((value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('the retriever issued a key, hash is ${String.fromCharCodes(value)}')));
              });
            }
          }
      );
      return ListTile(title: Text('Mechanism n.${index + 1}'), onTap: () {
        mechanism.build(context, {});
      },);
    }, itemCount: UnlockMechanism.unlockMechanisms.length));
  }
}