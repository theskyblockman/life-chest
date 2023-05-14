import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/generated/l10n.dart';
import 'package:life_chest/vault.dart';

class SchemeUnlockMechanism extends UnlockMechanism {
  SchemeUnlockMechanism({required super.onKeyRetrieved});

  @override
  void build(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(body: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(S.of(context).enterTheChestPassword, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24)),
        const Padding(padding: EdgeInsets.only(top: 20)),
        const UnlockScheme()
      ]));
    }));
  }

  @override
  (SecretKey?, String) createKey(BuildContext context, VaultPolicy policy) {
    return (SecretKey(passwordToCryptKey('TEMPORARY KEY PLEASE REPLACE')), 'OK'); // TODO: Replace this key
  }

  @override
  String getName(BuildContext context) => S.of(context).scheme;

  @override
  Widget keyCreationBuild(BuildContext context, VaultPolicy policy) {
    return const Card(margin: EdgeInsets.all(15), child: Padding(padding: EdgeInsets.all(10),child: UnlockScheme()));
  }

  @override
  bool canBeFocused() => false;
}

class UnlockScheme extends StatefulWidget {
  const UnlockScheme({super.key});

  @override
  State<StatefulWidget> createState() => UnlockSchemeState();
}

class UnlockSchemeState extends State<UnlockScheme> {
  UnlockSchemePaint? schemePaint;

  @override
  Widget build(BuildContext context) {
    Paint paintToDraw = Paint();
    paintToDraw.color = Theme.of(context).colorScheme.onBackground;
    schemePaint ??= UnlockSchemePaint(schemePaint: paintToDraw, currentScreenLowestResolution: min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width));
    return Listener(onPointerMove: (event) {
      schemePaint!.currentPointerGlobalPosition = event.localPosition;
    }, child: CustomPaint(painter: schemePaint, size: Size(min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.6 + 10, min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.6 + 10),));
  }
}

class UnlockSchemePaint extends CustomPainter {
  List<(int id, (int fromX, int fromY), (int toX, int toY))> linkedDots = [];
  final Paint schemePaint;
  Offset? currentPointerGlobalPosition;
  final double currentScreenLowestResolution;

  UnlockSchemePaint({required this.schemePaint, required this.currentScreenLowestResolution});

  @override
  void paint(Canvas canvas, Size size) {
    Offset initialOffset = const Offset(5, 5);
    
    for(int currentRow = 0; currentRow < 3; currentRow++) {
      for(int currentColumn = 0; currentColumn < 3; currentColumn++) {
        canvas.drawCircle(Offset(initialOffset.dx + currentScreenLowestResolution * 0.3 * currentRow, initialOffset.dy + currentScreenLowestResolution * 0.3 * currentColumn), 5, schemePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant UnlockSchemePaint oldDelegate) {
    return oldDelegate.linkedDots != linkedDots;
  }
}