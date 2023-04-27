// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hello there!`
  String get welcomePage1Title {
    return Intl.message(
      'Hello there!',
      name: 'welcomePage1Title',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to your life chest ! Here you will be able to create chests to store your data privately without compromising over usability.`
  String get welcomePage1Content {
    return Intl.message(
      'Welcome to your life chest ! Here you will be able to create chests to store your data privately without compromising over usability.',
      name: 'welcomePage1Content',
      desc: '',
      args: [],
    );
  }

  /// `Here, our main priority is your security`
  String get welcomePage2Title {
    return Intl.message(
      'Here, our main priority is your security',
      name: 'welcomePage2Title',
      desc: '',
      args: [],
    );
  }

  /// `We use an encryption system called Chacha20, so trying to access your files without your password will take about 200 trillions of trillions of trillions times the age of the universe! And to prove it, we are 100% open-source!`
  String get welcomePage2Content {
    return Intl.message(
      'We use an encryption system called Chacha20, so trying to access your files without your password will take about 200 trillions of trillions of trillions times the age of the universe! And to prove it, we are 100% open-source!',
      name: 'welcomePage2Content',
      desc: '',
      args: [],
    );
  }

  /// `Let's create your first chest!`
  String get welcomePage3Title {
    return Intl.message(
      'Let\'s create your first chest!',
      name: 'welcomePage3Title',
      desc: '',
      args: [],
    );
  }

  /// `You'll see, it's fast, easy and secure!`
  String get welcomePage3Content {
    return Intl.message(
      'You\'ll see, it\'s fast, easy and secure!',
      name: 'welcomePage3Content',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get welcomeSkip {
    return Intl.message(
      'Skip',
      name: 'welcomeSkip',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get welcomeNext {
    return Intl.message(
      'Next',
      name: 'welcomeNext',
      desc: '',
      args: [],
    );
  }

  /// `Create a new chest`
  String get createANewChest {
    return Intl.message(
      'Create a new chest',
      name: 'createANewChest',
      desc: '',
      args: [],
    );
  }

  /// `Chest name`
  String get chestName {
    return Intl.message(
      'Chest name',
      name: 'chestName',
      desc: '',
      args: [],
    );
  }

  /// `The chest name must not be empty`
  String get errorChestNameShouldNotBeEmpty {
    return Intl.message(
      'The chest name must not be empty',
      name: 'errorChestNameShouldNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Chest password`
  String get chestPassword {
    return Intl.message(
      'Chest password',
      name: 'chestPassword',
      desc: '',
      args: [],
    );
  }

  /// `The password must not be empty`
  String get errorChestPasswordShouldNotBeEmpty {
    return Intl.message(
      'The password must not be empty',
      name: 'errorChestPasswordShouldNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The password must be 8 characters or more`
  String get errorChestPasswordMoreCharacters {
    return Intl.message(
      'The password must be 8 characters or more',
      name: 'errorChestPasswordMoreCharacters',
      desc: '',
      args: [],
    );
  }

  /// `The password must contain at least one uppercase character`
  String get errorChestPasswordMoreUppercaseLetter {
    return Intl.message(
      'The password must contain at least one uppercase character',
      name: 'errorChestPasswordMoreUppercaseLetter',
      desc: '',
      args: [],
    );
  }

  /// `The password must contain at least one lowercase character`
  String get errorChestPasswordMoreLowercaseLetter {
    return Intl.message(
      'The password must contain at least one lowercase character',
      name: 'errorChestPasswordMoreLowercaseLetter',
      desc: '',
      args: [],
    );
  }

  /// `The password must contain at least one digit`
  String get errorChestPasswordMoreDigits {
    return Intl.message(
      'The password must contain at least one digit',
      name: 'errorChestPasswordMoreDigits',
      desc: '',
      args: [],
    );
  }

  /// `Enter airplane mode when the vault opens`
  String get shouldEnterAirplaneMode {
    return Intl.message(
      'Enter airplane mode when the vault opens',
      name: 'shouldEnterAirplaneMode',
      desc: '',
      args: [],
    );
  }

  /// `What should we do when the application is paused`
  String get whatShouldBeDoneAfterUnfocus {
    return Intl.message(
      'What should we do when the application is paused',
      name: 'whatShouldBeDoneAfterUnfocus',
      desc: '',
      args: [],
    );
  }

  /// `Do nothing`
  String get doNothing {
    return Intl.message(
      'Do nothing',
      name: 'doNothing',
      desc: '',
      args: [],
    );
  }

  /// `Notify you`
  String get notify {
    return Intl.message(
      'Notify you',
      name: 'notify',
      desc: '',
      args: [],
    );
  }

  /// `Close the chest`
  String get closeChest {
    return Intl.message(
      'Close the chest',
      name: 'closeChest',
      desc: '',
      args: [],
    );
  }

  /// `The duration must not be empty`
  String get errorDurationMustNotBeEmpty {
    return Intl.message(
      'The duration must not be empty',
      name: 'errorDurationMustNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The duration must be in the HH:MM format`
  String get errorDurationMustBeFormatted {
    return Intl.message(
      'The duration must be in the HH:MM format',
      name: 'errorDurationMustBeFormatted',
      desc: '',
      args: [],
    );
  }

  /// `Create the chest`
  String get createTheNewChest {
    return Intl.message(
      'Create the chest',
      name: 'createTheNewChest',
      desc: '',
      args: [],
    );
  }

  /// `The application "Life Chest" has been made by Theskyblockman with a ❤️ and a 🖥️ under the MIT License, ©️ 2023 Haroun El Omri`
  String get appLegalese {
    return Intl.message(
      'The application "Life Chest" has been made by Theskyblockman with a ❤️ and a 🖥️ under the MIT License, ©️ 2023 Haroun El Omri',
      name: 'appLegalese',
      desc: '',
      args: [],
    );
  }

  /// `No chests created yet`
  String get noChestsCreatedYet {
    return Intl.message(
      'No chests created yet',
      name: 'noChestsCreatedYet',
      desc: '',
      args: [],
    );
  }

  /// `No files added yet`
  String get noFilesCreatedYet {
    return Intl.message(
      'No files added yet',
      name: 'noFilesCreatedYet',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the password of this vault`
  String get enterTheChestPassword {
    return Intl.message(
      'Please enter the password of this vault',
      name: 'enterTheChestPassword',
      desc: '',
      args: [],
    );
  }

  /// `Validate`
  String get validate {
    return Intl.message(
      'Validate',
      name: 'validate',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Delete all the chests`
  String get deleteAllChests {
    return Intl.message(
      'Delete all the chests',
      name: 'deleteAllChests',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  /// `About...`
  String get about {
    return Intl.message(
      'About...',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Add files`
  String get addFiles {
    return Intl.message(
      'Add files',
      name: 'addFiles',
      desc: '',
      args: [],
    );
  }

  /// `Loading elements`
  String get loadingElements {
    return Intl.message(
      'Loading elements',
      name: 'loadingElements',
      desc: '',
      args: [],
    );
  }

  /// `Loading document`
  String get loadingDocuments {
    return Intl.message(
      'Loading document',
      name: 'loadingDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Loading image`
  String get loadingImage {
    return Intl.message(
      'Loading image',
      name: 'loadingImage',
      desc: '',
      args: [],
    );
  }

  /// `Loading audio track`
  String get loadingAudioTrack {
    return Intl.message(
      'Loading audio track',
      name: 'loadingAudioTrack',
      desc: '',
      args: [],
    );
  }

  /// `Pick the files you want to add`
  String get pickFilesDialogTitle {
    return Intl.message(
      'Pick the files you want to add',
      name: 'pickFilesDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick the folder you want to add`
  String get pickFolderDialogTitle {
    return Intl.message(
      'Pick the folder you want to add',
      name: 'pickFolderDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} {count, plural, =1{selected} other{selected}}`
  String selected(num count) {
    final NumberFormat countNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String countString = countNumberFormat.format(count);

    return Intl.message(
      '$countString ${Intl.plural(count, one: 'selected', other: 'selected')}',
      name: 'selected',
      desc: '',
      args: [countString],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message(
      'Select all',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Wrong password`
  String get wrongPassword {
    return Intl.message(
      'Wrong password',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `You still have a chest opened`
  String get closeChestNotificationTitle {
    return Intl.message(
      'You still have a chest opened',
      name: 'closeChestNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Click on the button down there to close it`
  String get closeChestNotificationContent {
    return Intl.message(
      'Click on the button down there to close it',
      name: 'closeChestNotificationContent',
      desc: '',
      args: [],
    );
  }

  /// `Create a new folder`
  String get createANewFolder {
    return Intl.message(
      'Create a new folder',
      name: 'createANewFolder',
      desc: '',
      args: [],
    );
  }

  /// `New folder`
  String get newFolder {
    return Intl.message(
      'New folder',
      name: 'newFolder',
      desc: '',
      args: [],
    );
  }

  /// `Sort by...`
  String get sortBy {
    return Intl.message(
      'Sort by...',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `First detected number`
  String get numberSortName {
    return Intl.message(
      'First detected number',
      name: 'numberSortName',
      desc: '',
      args: [],
    );
  }

  /// `Alphabetical order`
  String get nameSortName {
    return Intl.message(
      'Alphabetical order',
      name: 'nameSortName',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
