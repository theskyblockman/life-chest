import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:life_chest/color_schemes.g.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_viewers/audio.dart';
import 'package:life_chest/new_chest.dart';
import 'package:life_chest/onboarding.dart';
import 'package:life_chest/vault.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory appDocuments = await getApplicationDocumentsDirectory();
  VaultsManager.appFolder = appDocuments.path;
  VaultsManager.mainConfigFile = File('${VaultsManager.appFolder}/.config');
  bool firstLaunch = !VaultsManager.mainConfigFile.existsSync();
  if (firstLaunch) {
    VaultsManager.mainConfigFile.createSync();

    VaultsManager.mainConfigFile.writeAsStringSync(await rootBundle
        .loadString('file_settings/default_config.json', cache: false));
  }

  AudioListener.audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
          androidNotificationChannelId:
              'fr.theskyblockman.life_chest.channel.audio',
          androidNotificationChannelName: 'Audio player',
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
    ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
    );
    ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );

    return MaterialApp(
      title: 'Life Chest',
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: firstLaunch ? const WelcomePage() : const ChestMainPage(),
    );
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
  TextEditingController passwordField = TextEditingController();
  FocusNode passwordFieldFocusNode = FocusNode();
  bool failedPasswordForVault = false;

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
                    PopupMenuItem(
                      onTap: () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          showAboutDialog(
                            context: context,
                            applicationVersion: '1.0.0',
                            applicationIcon:
                                Image.asset('logo.png', height: 64, width: 64),
                            applicationLegalese:
                                AppLocalizations.of(context)!.appLegalese,
                          );
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.about),
                    ),
                    if (VaultsManager.storedVaults.isNotEmpty)
                      PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .areYouSure),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .no)),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .yes))
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
                          child: Text(
                              AppLocalizations.of(context)!.deleteAllChests)),
                    if (kDebugMode)
                      PopupMenuItem(
                        child: const Text('Debug button'),
                        onTap: () async {},
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
                child: Opacity(
                    opacity: 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 128),
                        Text(
                          AppLocalizations.of(context)!.noChestsCreatedYet,
                          textScaleFactor: 2.5,
                          textAlign: TextAlign.center,
                        )
                      ],
                    )))
            : ListView.builder(
                itemBuilder: (context, index) {
                  Vault chest = VaultsManager.storedVaults[index];
                  return Card(
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
                                        setState(() {
                                          VaultsManager.deleteVault(chest);
                                          VaultsManager.loadVaults();
                                        });
                                      });
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.delete),
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
                                            // NOTE: Do not edit this, as the value can be null it is easier to try to put value as true as to verify that it isn't null and to then verify it's bool value
                                            setState(() {});
                                          }
                                        });
                                      });
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.rename),
                                  )
                                ];
                              }),
                          onTap: () {
                            showDialog(
                                    context: context,
                                    builder: (context) {
                                      passwordField = TextEditingController();
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .enterTheChestPassword),
                                              content: TextField(
                                                  autofocus: true,
                                                  controller: passwordField,
                                                  focusNode:
                                                      passwordFieldFocusNode,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                      border:
                                                          const OutlineInputBorder(),
                                                      errorText:
                                                          failedPasswordForVault
                                                              ? AppLocalizations
                                                                      .of(context)!
                                                                  .wrongPassword
                                                              : null)),
                                              actions: [
                                                TextButton(
                                                    onPressed: () async {
                                                      chest.encryptionKey =
                                                          SecretKey(
                                                              passwordToCryptKey(
                                                                  passwordField
                                                                      .text));
                                                      chest.locked =
                                                          !(await VaultsManager
                                                              .testVaultKey(
                                                                  chest));
                                                      if (!kDebugMode) {
                                                        passwordField.text = '';
                                                      }
                                                      if (!chest.locked) {
                                                        if (context.mounted) {
                                                          passwordFieldFocusNode
                                                              .unfocus();
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      FileExplorer(
                                                                          chest))).then(
                                                              (_) {
                                                            if (context
                                                                .mounted) {
                                                              setState(
                                                                  () => {});
                                                            }
                                                          });
                                                        }
                                                      } else {
                                                        if (context.mounted) {
                                                          setState(() {
                                                            failedPasswordForVault =
                                                                true;
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .validate))
                                              ]);
                                        },
                                      );
                                    })
                                .then(
                                    (value) => failedPasswordForVault = false);
                          }));
                },
                itemCount: VaultsManager.storedVaults.length));
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
            'notification_title':
                AppLocalizations.of(context)!.closeChestNotificationTitle,
            'notification_content':
                AppLocalizations.of(context)!.closeChestNotificationContent,
            'notification_close_button_content':
                AppLocalizations.of(context)!.closeChest
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
