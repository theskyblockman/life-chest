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

  /// `Welcome to your Life Chest! Here, you will be able to create chests to store your data securely without compromising usability.`
  String get welcomePage1Content {
    return Intl.message(
      'Welcome to your Life Chest! Here, you will be able to create chests to store your data securely without compromising usability.',
      name: 'welcomePage1Content',
      desc: '',
      args: [],
    );
  }

  /// `Your Security is Our Main Priority`
  String get welcomePage2Title {
    return Intl.message(
      'Your Security is Our Main Priority',
      name: 'welcomePage2Title',
      desc: '',
      args: [],
    );
  }

  /// `We use an encryption system called Chacha20, which means attempting to access your files without your password would take about 200 trillions of trillions of trillions times the age of the universe! And to prove it, we are 100% open-source!`
  String get welcomePage2Content {
    return Intl.message(
      'We use an encryption system called Chacha20, which means attempting to access your files without your password would take about 200 trillions of trillions of trillions times the age of the universe! And to prove it, we are 100% open-source!',
      name: 'welcomePage2Content',
      desc: '',
      args: [],
    );
  }

  /// `Let's Create Your First Chest!`
  String get welcomePage3Title {
    return Intl.message(
      'Let\'s Create Your First Chest!',
      name: 'welcomePage3Title',
      desc: '',
      args: [],
    );
  }

  /// `You'll see, it's fast, easy, and secure!`
  String get welcomePage3Content {
    return Intl.message(
      'You\'ll see, it\'s fast, easy, and secure!',
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

  /// `Create a New Chest`
  String get createANewChest {
    return Intl.message(
      'Create a New Chest',
      name: 'createANewChest',
      desc: '',
      args: [],
    );
  }

  /// `Chest Name`
  String get chestName {
    return Intl.message(
      'Chest Name',
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

  /// `Chest Password`
  String get chestPassword {
    return Intl.message(
      'Chest Password',
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

  /// `The password must be at least 8 characters long`
  String get errorChestPasswordMoreCharacters {
    return Intl.message(
      'The password must be at least 8 characters long',
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

  /// `The scheme must not be empty`
  String get errorChestSchemeShouldNotBeEmpty {
    return Intl.message(
      'The scheme must not be empty',
      name: 'errorChestSchemeShouldNotBeEmpty',
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

  /// `Create the Chest`
  String get createTheNewChest {
    return Intl.message(
      'Create the Chest',
      name: 'createTheNewChest',
      desc: '',
      args: [],
    );
  }

  /// `The application "Life Chest" has been made by Theskyblockman with ❤️ and a 🖥️ under the MIT license. We do not provide any warranty, see the MIT license for more information ©️ 2023 Haroun El Omri`
  String get appLegalese {
    return Intl.message(
      'The application "Life Chest" has been made by Theskyblockman with ❤️ and a 🖥️ under the MIT license. We do not provide any warranty, see the MIT license for more information ©️ 2023 Haroun El Omri',
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

  /// `Please enter the password of this chest`
  String get enterTheChestPassword {
    return Intl.message(
      'Please enter the password of this chest',
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

  /// `Loading video`
  String get loadingVideo {
    return Intl.message(
      'Loading video',
      name: 'loadingVideo',
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

  /// `{count} selected`
  String selected(int count) {
    return Intl.message(
      '$count selected',
      name: 'selected',
      desc: '',
      args: [count],
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

  /// `Are you sure you want to delete all vaults?`
  String get areYouSureClearVaults {
    return Intl.message(
      'Are you sure you want to delete all vaults?',
      name: 'areYouSureClearVaults',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{vaultName}"?`
  String areYouSureDeleteVault(String vaultName) {
    return Intl.message(
      'Are you sure you want to delete "$vaultName"?',
      name: 'areYouSureDeleteVault',
      desc: '',
      args: [vaultName],
    );
  }

  /// `Are you sure you want to delete {count} {count, plural, =1{file} other{files}}?`
  String areYouSureDeleteFiles(int count) {
    return Intl.message(
      'Are you sure you want to delete $count ${Intl.plural(count, one: 'file', other: 'files')}?',
      name: 'areYouSureDeleteFiles',
      desc: '',
      args: [count],
    );
  }

  /// `This action is irreversible! All lost data can't be recovered.`
  String get lostDataContBeRecovered {
    return Intl.message(
      'This action is irreversible! All lost data can\'t be recovered.',
      name: 'lostDataContBeRecovered',
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

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `PIN code`
  String get pinCode {
    return Intl.message(
      'PIN code',
      name: 'pinCode',
      desc: '',
      args: [],
    );
  }

  /// `Pattern`
  String get scheme {
    return Intl.message(
      'Pattern',
      name: 'scheme',
      desc: '',
      args: [],
    );
  }

  /// `Chest PIN code`
  String get chestPinCode {
    return Intl.message(
      'Chest PIN code',
      name: 'chestPinCode',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the unlocking pattern of this chest`
  String get enterTheChestScheme {
    return Intl.message(
      'Please enter the unlocking pattern of this chest',
      name: 'enterTheChestScheme',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the pin code of this chest`
  String get enterThePinCode {
    return Intl.message(
      'Please enter the pin code of this chest',
      name: 'enterThePinCode',
      desc: '',
      args: [],
    );
  }

  /// `Wrong PIN code`
  String get wrongPinCode {
    return Intl.message(
      'Wrong PIN code',
      name: 'wrongPinCode',
      desc: '',
      args: [],
    );
  }

  /// `The chest PIN code shouldn't be empty`
  String get errorChestPinCodeShouldNotBeEmpty {
    return Intl.message(
      'The chest PIN code shouldn\'t be empty',
      name: 'errorChestPinCodeShouldNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The chest PIN code should be at least 4 digits long`
  String get errorChestPinCodeMoreCharacters {
    return Intl.message(
      'The chest PIN code should be at least 4 digits long',
      name: 'errorChestPinCodeMoreCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Unlock the chest`
  String get unlockChest {
    return Intl.message(
      'Unlock the chest',
      name: 'unlockChest',
      desc: '',
      args: [],
    );
  }

  /// `Please use your biometrics to unlock the chest`
  String get pleaseUseBiometrics {
    return Intl.message(
      'Please use your biometrics to unlock the chest',
      name: 'pleaseUseBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `Define the scheme`
  String get defineScheme {
    return Intl.message(
      'Define the scheme',
      name: 'defineScheme',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics`
  String get biometrics {
    return Intl.message(
      'Biometrics',
      name: 'biometrics',
      desc: '',
      args: [],
    );
  }

  /// `Export as a clear file (not encrypted)`
  String get exportAsCleartext {
    return Intl.message(
      'Export as a clear file (not encrypted)',
      name: 'exportAsCleartext',
      desc: '',
      args: [],
    );
  }

  /// `Export as an encrypted file`
  String get exportAsEncrypted {
    return Intl.message(
      'Export as an encrypted file',
      name: 'exportAsEncrypted',
      desc: '',
      args: [],
    );
  }

  /// `We detected {count, plural, =1{a file} other{multiple files}} that come from a vault. To access {count, plural, =1{its} other{their}} content, you must unlock them.`
  String detectedExportedFile(int count) {
    return Intl.message(
      'We detected ${Intl.plural(count, one: 'a file', other: 'multiple files')} that come from a vault. To access ${Intl.plural(count, one: 'its', other: 'their')} content, you must unlock them.',
      name: 'detectedExportedFile',
      desc: '',
      args: [count],
    );
  }

  /// `Unlock the file`
  String get unlockFile {
    return Intl.message(
      'Unlock the file',
      name: 'unlockFile',
      desc: '',
      args: [],
    );
  }

  /// `Use the unlock wizard`
  String get useUnlockWizard {
    return Intl.message(
      'Use the unlock wizard',
      name: 'useUnlockWizard',
      desc: '',
      args: [],
    );
  }

  /// `Unlock wizard`
  String get unlockWizard {
    return Intl.message(
      'Unlock wizard',
      name: 'unlockWizard',
      desc: '',
      args: [],
    );
  }

  /// `Ignore`
  String get ignore {
    return Intl.message(
      'Ignore',
      name: 'ignore',
      desc: '',
      args: [],
    );
  }

  /// `Life Chest bulk file export`
  String get lifeChestBulkSave {
    return Intl.message(
      'Life Chest bulk file export',
      name: 'lifeChestBulkSave',
      desc: '',
      args: [],
    );
  }

  /// `We successfully saved the file(s)`
  String get savedToFolder {
    return Intl.message(
      'We successfully saved the file(s)',
      name: 'savedToFolder',
      desc: '',
      args: [],
    );
  }

  /// `We successfully saved the file(s). WARNING! These encrypted files are more vulnerable in this format, do not publicly distribute them. Life Chest, its authors, or its contributors cannot be held liable for any divulged data.`
  String get savedToFolderWarning {
    return Intl.message(
      'We successfully saved the file(s). WARNING! These encrypted files are more vulnerable in this format, do not publicly distribute them. Life Chest, its authors, or its contributors cannot be held liable for any divulged data.',
      name: 'savedToFolderWarning',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  /// `Group n.{groupID}`
  String group(int groupID) {
    return Intl.message(
      'Group n.$groupID',
      name: 'group',
      desc: '',
      args: [groupID],
    );
  }

  /// `This group can be unlocked with: {unlockName}.`
  String unlockAbleBy(String unlockName) {
    return Intl.message(
      'This group can be unlocked with: $unlockName.',
      name: 'unlockAbleBy',
      desc: '',
      args: [unlockName],
    );
  }

  /// `A file exported from the Life Chest app and needs to be unlocked to get more information about it.`
  String get exportedFileDescription {
    return Intl.message(
      'A file exported from the Life Chest app and needs to be unlocked to get more information about it.',
      name: 'exportedFileDescription',
      desc: '',
      args: [],
    );
  }

  /// `Internal Error`
  String get internalError {
    return Intl.message(
      'Internal Error',
      name: 'internalError',
      desc: '',
      args: [],
    );
  }

  /// `Wrong device, couldn't find the unlock data in the keystore`
  String get wrongDevice {
    return Intl.message(
      'Wrong device, couldn\'t find the unlock data in the keystore',
      name: 'wrongDevice',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics-locked chests can only be unlocked on the device it has been created on. Encrypted file export is unavailable.`
  String get biometricsAreLocal {
    return Intl.message(
      'Biometrics-locked chests can only be unlocked on the device it has been created on. Encrypted file export is unavailable.',
      name: 'biometricsAreLocal',
      desc: '',
      args: [],
    );
  }

  /// `The link has been copied to your clipboard.`
  String get linkCopied {
    return Intl.message(
      'The link has been copied to your clipboard.',
      name: 'linkCopied',
      desc: '',
      args: [],
    );
  }

  /// `Subtitles`
  String get subtitles {
    return Intl.message(
      'Subtitles',
      name: 'subtitles',
      desc: '',
      args: [],
    );
  }

  /// `Playback speed`
  String get playbackSpeed {
    return Intl.message(
      'Playback speed',
      name: 'playbackSpeed',
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
