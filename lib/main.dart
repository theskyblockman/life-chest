import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_chest/color_schemes.g.dart';
import 'package:life_chest/file_explorer.dart';
import 'package:life_chest/vault.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioPlayer.global.changeLogLevel(LogLevel.error);
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  Directory appDocuments = await getApplicationDocumentsDirectory();
  VaultsManager.appFolder = appDocuments.path;
  VaultsManager.mainConfigFile = File('${VaultsManager.appFolder}/.config');
  bool firstLaunch = !VaultsManager.mainConfigFile.existsSync();
  if (firstLaunch) {
    VaultsManager.mainConfigFile.createSync();

    VaultsManager.mainConfigFile.writeAsStringSync(await rootBundle.loadString('file_settings/default_config.json', cache: false));
  }

  runApp(LifeChestApp(firstLaunch: firstLaunch)); //firstLaunch || kDebugMode
}

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
      theme: lightTheme.copyWith(textTheme: GoogleFonts.robotoTextTheme(lightTheme.textTheme)),
      darkTheme: darkTheme.copyWith(textTheme: GoogleFonts.robotoTextTheme(darkTheme.textTheme)),
      home: firstLaunch ? const WelcomePage() : const ChestMainPage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  late List<List<Widget>> welcomePages;

  PageController controller = PageController();
  int previousPage = 0;
  @override
  Widget build(BuildContext context) {
    AppLocalizations currentLocal = AppLocalizations.of(context)!;

    welcomePages = [
      [
        Text(currentLocal.welcomePage1Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
            currentLocal.welcomePage1Content,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade)
      ],
      [
        Text(currentLocal.welcomePage2Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 1.75,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
            currentLocal.welcomePage2Content,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade)
      ],
      [
        Text(currentLocal.welcomePage3Title,
            style: const TextStyle(fontWeight: FontWeight.w900),
            textScaleFactor: 2.25,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
          currentLocal.welcomePage3Content,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textScaleFactor: 1.5,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        )
      ]
    ];

    bool isLastPage = controller.hasClients
        ? (controller.page!.round() == welcomePages.length - 1 ? true : false)
        : false;
    String textToDisplay = isLastPage ? currentLocal.createANewChest : currentLocal.welcomeNext;
    controller.addListener(
      () {
        int currentPage = controller.page!.round();
        if (previousPage != currentPage) {
          previousPage = currentPage;
          setState(() {});
        }
      },
    );
    return Scaffold(
      appBar: AppBar(actions: [
        AnimatedOpacity(
            opacity: isLastPage ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  if (!isLastPage) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChestMainPage()));
                  }
                },
                icon: const Icon(Icons.keyboard_double_arrow_right),
                label: Text(currentLocal.welcomeSkip)))
      ]),
      body: Center(
        child: Stack(children: [
          PageView.builder(
              itemBuilder: (context, index) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: welcomePages[index]);
              },
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemCount: welcomePages.length),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: ElevatedButton.icon(
                      icon: isLastPage
                          ? const Icon(Icons.add)
                          : const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        if (isLastPage) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChestMainPage()));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateNewChestPage()));
                        } else {
                          setState(() {
                            controller.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut);
                          });
                        }
                      },
                      label: Text(textToDisplay),
                      key: ValueKey(textToDisplay),
                    ))),
          )
        ]),
      ),
      extendBodyBehindAppBar: true,
    );
  }
}

class CreateNewChestPage extends StatefulWidget {
  const CreateNewChestPage({super.key});

  @override
  State<StatefulWidget> createState() => CreateNewChestPageState();
}

class CreateNewChestPageState extends State<CreateNewChestPage> {
  VaultPolicy policy = VaultPolicy();
  FocusNode nameNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  int timeoutLevel = 0;
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController timeoutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.createANewChest)),
        body: SingleChildScrollView(
            child: Form(
          key: formState,
          child: Column(children: [
            ListTile(
              title: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  policy.vaultName = value;
                },
                onEditingComplete: () => passwordNode.requestFocus(),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(), labelText: AppLocalizations.of(context)!.chestName),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.errorChestNameShouldNotBeEmpty;
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
                    border: const OutlineInputBorder(), labelText: AppLocalizations.of(context)!.chestPassword),
                obscureText: true,
                focusNode: passwordNode,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.errorChestPasswordShouldNotBeEmpty;
                  }
                  if(value.length < 8) {
                    return AppLocalizations.of(context)!.errorChestPasswordMoreCharacters;
                  }
                  if(!value.contains(RegExp(r'[A-Z]'))) {
                    return AppLocalizations.of(context)!.errorChestPasswordMoreUppercaseLetter;
                  }
                  if(!value.contains(RegExp(r'[a-z]'))) {
                    return AppLocalizations.of(context)!.errorChestPasswordMoreLowercaseLetter;
                  }
                  if(!value.contains(RegExp(r'\d'))) {
                    return AppLocalizations.of(context)!.errorChestPasswordMoreDigits;
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
              title: Text(
                  AppLocalizations.of(context)!.shouldEnterAirplaneMode),
            ),
            const Divider(),
            ListTile(
                title: Text(AppLocalizations.of(context)!.whatShouldBeDoneAfterTimeout)),
            ListTile(
              title: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(AppLocalizations.of(context)!.doNothing)),
                    ButtonSegment(value: 1, label: Text(AppLocalizations.of(context)!.notify)),
                    ButtonSegment(value: 2, label: Text(AppLocalizations.of(context)!.closeChest)),
                  ],
                  selected: {
                    timeoutLevel
                  },
                  multiSelectionEnabled: false,
                  emptySelectionAllowed: false,
                  onSelectionChanged: (newSet) {
                    setState(() {
                      timeoutLevel = newSet.first;
                    });
                  }),
            ),
            ListTile(
                enabled: timeoutLevel > 0,
                leading: const Icon(Icons.timelapse),
                title: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    decoration: const InputDecoration(hintText: '00:00'),
                    inputFormatters: [HourMinsFormatter()],
                    enabled: timeoutLevel > 0,
                    validator: (value) {
                      if(timeoutLevel < 1) return null;

                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.errorDurationMustNotBeEmpty;
                      }
                      if (!value.contains(':') || value.length != 5) {
                        return AppLocalizations.of(context)!.errorDurationMustBeFormatted;
                      }

                      return null;
                    }, controller: timeoutController,))
          ]),
        )), floatingActionButton: FloatingActionButton.extended(onPressed: () async {
          if(formState.currentState!.validate()) {
            policy.isTimeoutEnabled = timeoutLevel > 0;
            if(policy.isTimeoutEnabled) {
              int hours = int.parse(timeoutController.text.split(':')[0]);
              int minutes = int.parse(timeoutController.text.split(':')[1]);
              policy.vaultTimeout = Duration(hours: hours, minutes: minutes);
              policy.automaticallyCloseVaultOnTimeout = timeoutLevel > 1;
            }
            Vault createdVault = await VaultsManager.createVaultFromPolicy(policy);
            VaultsManager.storedVaults.add(createdVault);
            VaultsManager.saveVaults();
            if(context.mounted) Navigator.pop(context);
          }
        }, label: Text(AppLocalizations.of(context)!.createTheNewChest), icon: const Icon(Icons.add),), floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,);
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

class ChestMainPage extends StatefulWidget {
  const ChestMainPage({super.key});

  @override
  State<ChestMainPage> createState() => ChestMainPageState();
}

class ChestMainPageState extends State<ChestMainPage> {
  GlobalKey<AnimatedListState> animatedListState = GlobalKey();
  int currentlySelectedChestID = -1;
  TextEditingController passwordField = TextEditingController();
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
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
                  if(kDebugMode)
                    PopupMenuItem(child: const Text('Debug button'), onTap: () {
                      
                    },)
                ];
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateNewChestPage())).then((_) => setState(() => {}));
          },
          child: const Icon(Icons.add)),
      body: VaultsManager.storedVaults.isEmpty ? Center(
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
              ))) : ListView.builder(itemBuilder: (context, index) {
                Vault chest = VaultsManager.storedVaults[index];
                return Card(
                    child: ListTile(
                        title: Text(chest.name),
                        trailing:  PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  onTap: () {
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      setState(() {
                                        VaultsManager.deleteVault(chest);
                                        VaultsManager.loadVaults();
                                      });
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.redAccent)),
                                )
                              ];
                            }), onTap: () {
                      showDialog(context: context, builder: (context) {
                        passwordField = TextEditingController();
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(title: Text(AppLocalizations.of(context)!.enterTheChestPassword), content: TextField(autofocus: true, controller: passwordField, obscureText: true, decoration: InputDecoration(border: const OutlineInputBorder(), errorText: failedPasswordForVault ? AppLocalizations.of(context)!.wrongPassword : null)), actions: [
                            TextButton(onPressed: () async {
                              chest.encryptionKey = SecretKey(passwordToCryptKey(passwordField.text));
                              chest.locked = !(await VaultsManager.testVaultKey(chest));
                              if(!kDebugMode) passwordField.text = '';
                              if(!chest.locked && context.mounted) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => FileExplorer(chest))).then((_) => setState(() => {}));
                              } else {
                                setState(() {
                                  failedPasswordForVault = true;
                                });
                              }
                            }, child: Text(AppLocalizations.of(context)!.validate))
                          ]);
                        },);
                      }).then((value) => failedPasswordForVault = false);
                    }
                    )
                );
              }, itemCount: VaultsManager.storedVaults.length)
    );
  }

  @override
  void initState() {
    VaultsManager.loadVaults();
    super.initState();
  }
}