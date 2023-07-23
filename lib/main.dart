import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_chest/color_schemes.g.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_viewers/audio.dart';
import 'package:life_chest/new_chest.dart';
import 'package:life_chest/onboarding.dart';
import 'package:life_chest/unlock_mechanism/unlock_mechanism.dart';
import 'package:life_chest/unlock_mechanism/unlock_tester.dart';
import 'package:life_chest/vault.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:life_chest/generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory appDocuments = await getApplicationDocumentsDirectory();
  VaultsManager.appFolder = appDocuments.path;
  VaultsManager.mainConfigFile = File('${VaultsManager.appFolder}/.config');
  VaultsManager.packageInfo = await PackageInfo.fromPlatform();
  VaultsManager.nonceStorage = const FlutterSecureStorage(aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ), iOptions: IOSOptions(groupId: 'fr.theskyblockman'));
  bool firstLaunch = !VaultsManager.mainConfigFile.existsSync() || kDebugMode;
  if (firstLaunch) {
    VaultsManager.mainConfigFile.createSync();

    VaultsManager.mainConfigFile.writeAsStringSync(await rootBundle
        .loadString('file_settings/default_config.json', cache: false));
  }

  AudioListener.audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
          androidNotificationChannelId: 'fr.theskyblockman.life_chest.audio',
          androidNotificationChannelName: 'Life chest audio player',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true));

  runApp(LifeChestApp(firstLaunch: firstLaunch)); //firstLaunch || kDebugMode
}

/// The app root widget
class LifeChestApp extends StatelessWidget {
  const LifeChestApp({super.key, required this.firstLaunch});

  final bool firstLaunch;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ThemeData lightTheme = ThemeData(
        useMaterial3: true,
        colorScheme:
            kDebugMode ? lightColorScheme : lightDynamic ?? lightColorScheme,
      );
      ThemeData darkTheme = ThemeData(
        useMaterial3: true,
        colorScheme:
            kDebugMode ? darkColorScheme : darkDynamic ?? darkColorScheme,
      );

      return MaterialApp(
          title: 'Life Chest',
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: firstLaunch ? const WelcomePage() : const ChestMainPage());
    });
  }
}

/// The main app's page, made to open chests and unlock them
class ChestMainPage extends StatefulWidget {
  static GlobalKey<ChestMainPageState> pageKey = GlobalKey();

  const ChestMainPage({super.key});

  @override
  State<ChestMainPage> createState() => ChestMainPageState();
}

/// The [ChestMainPage]'s state
class ChestMainPageState extends State<ChestMainPage> {
  GlobalKey<AnimatedListState> animatedListState = GlobalKey();
  int currentlySelectedChestID = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Life chest'),
          actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                itemBuilder: (BuildContext context) {
                  return [
                    if (VaultsManager.storedVaults.isNotEmpty)
                      PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                          title: Text(S
                                              .of(context)
                                              .areYouSureClearVaults),
                                          content: Text(S
                                              .of(context)
                                              .lostDataContBeRecovered),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: Text(S.of(context).no)),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: Text(S.of(context).yes))
                                          ])).then((value) {
                                if (value == true) {
                                  setState(() {
                                    for (Vault vault in List.from(
                                        VaultsManager.storedVaults)) {
                                      VaultsManager.deleteVault(vault);
                                    }
                                    VaultsManager.saveVaults();
                                  });
                                }
                              });
                            });
                          },
                          child: Text(S.of(context).deleteAllChests)),
                    PopupMenuItem(
                      onTap: () async {
                        PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();

                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          showAboutDialog(
                            context: context,
                            applicationVersion: packageInfo.version,
                            applicationIcon:
                                Image.asset('logo.png', height: 64, width: 64),
                            applicationLegalese: S.of(context).appLegalese,
                          );
                        });
                      },
                      child: Text(S.of(context).about),
                    ),
                    if (kDebugMode)
                      PopupMenuItem(
                        child: const Text('Debug button'),
                        onTap: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WelcomePage()));
                          });
                        },
                      )
                  ];
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateNewChestPage()))
                  .then((_) => setState(() => {}));
            },
            child: const Icon(Icons.add)),
        body: VaultsManager.storedVaults.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 128, color: Theme.of(context).colorScheme.outline),
                  Text(
                    S.of(context).noChestsCreatedYet,
                    textScaleFactor: 2.5,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  )
                ],
              ))
            : ListView.builder(
                itemBuilder: (context, index) {
                  Vault chest = VaultsManager.storedVaults[index];
                  return Card(
                      shadowColor: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          UnlockTester tester = UnlockTester(
                              chest.unlockMechanismType,
                              chest.additionalUnlockData,
                              onKeyIssued:
                                  (issuedKey, didPushed, mechanismUsed) =>
                                      onKeyIssued(chest, issuedKey, didPushed,
                                          mechanismUsed));
                          if (tester.shouldUseChooser(context)) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UnlockChooser(
                                        onKeyIssued: (issuedKey, didPushed,
                                                mechanismUsed) =>
                                            onKeyIssued(chest, issuedKey,
                                                didPushed, mechanismUsed))));
                          }
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: ListTile(
                            title: Text(chest.name),
                            trailing: PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((timeStamp) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                      title: Text(S
                                                          .of(context)
                                                          .areYouSureDeleteVault(
                                                              chest.name)),
                                                      content: Text(S
                                                          .of(context)
                                                          .lostDataContBeRecovered),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: Text(S
                                                                .of(context)
                                                                .no)),
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: Text(S
                                                                .of(context)
                                                                .yes))
                                                      ])).then((value) {
                                            if (value == true) {
                                              setState(() {
                                                VaultsManager.deleteVault(
                                                    chest);
                                                VaultsManager.loadVaults();
                                              });
                                            }
                                          });
                                        });
                                      },
                                      child: Text(S.of(context).delete),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((timeStamp) {
                                          showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return RenameWindow(
                                                  onOkButtonPressed: (newName) {
                                                    chest.name = newName;

                                                    VaultsManager.saveVaults();
                                                    if (context.mounted) {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    }
                                                  },
                                                  onCancelButtonPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  initialName: chest.name);
                                            },
                                          ).then((value) {
                                            if (value == true) {
                                              setState(() {});
                                            }
                                          });
                                        });
                                      },
                                      child: Text(S.of(context).rename),
                                    )
                                  ];
                                })),
                      ));
                },
                itemCount: VaultsManager.storedVaults.length));
  }

  void onKeyIssued(Vault chest, SecretKey issuedKey, bool didPush,
      UnlockMechanism mechanismUsed) async {
    chest.encryptionKey = issuedKey;
    chest.locked = !(await VaultsManager.testVaultKey(chest));
    if (!chest.locked) {
      if (context.mounted) {
        if (didPush) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FileExplorer(
                      chest, mechanismUsed.isEncryptedExportAllowed())));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FileExplorer(
                      chest, mechanismUsed.isEncryptedExportAllowed())));
        }
      }
    }
  }

  /// Setups the notifications the user can receive if they want to
  @override
  void initState() {
    VaultsManager.loadVaults();
    if (!Platform.isAndroid) return;
    const MethodChannel('theskyblockman.fr/channel')
        .setMethodCallHandler((call) async {
      if (call.method == 'goBackToHome') {
        if (FileExplorerState.isPauseAllowed) {
          Navigator.popUntil(context, (route) => route.isFirst);
          return true;
        }
        if (FileExplorerState.shouldNotificationBeSent) {
          const MethodChannel('theskyblockman.fr/channel')
              .invokeMethod('sendVaultNotification', {
            'notification_title': S.of(context).closeChestNotificationTitle,
            'notification_content': S.of(context).closeChestNotificationContent,
            'notification_close_button_content': S.of(context).closeChest
          });
          return true;
        }

        return false;
      } else if (call.method == 'closeVault') {
        Navigator.popUntil(context, (route) => route.isFirst);
        return true;
      }
    });
    super.initState();
  }
}
