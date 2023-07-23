// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "Are you sure you want to delete ${count} ${Intl.plural(count, one: 'file', other: 'files')}?";

  static String m1(vaultName) =>
      "Are you sure you want to delete \"${vaultName}\"?";

  static String m2(count) =>
      "We detected ${Intl.plural(count, one: 'a file', other: 'multiple files')} that come from a vault. To access ${Intl.plural(count, one: 'its', other: 'their')} content, you must unlock them.";

  static String m3(groupID) => "Group n.${groupID}";

  static String m4(count) => "${count} selected";

  static String m5(unlockName) =>
      "This group can be unlocked with: ${unlockName}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About..."),
        "addFiles": MessageLookupByLibrary.simpleMessage("Add files"),
        "appLegalese": MessageLookupByLibrary.simpleMessage(
            "The application \"Life Chest\" has been made by Theskyblockman with ❤️ and a 🖥️ under the MIT license. We do not provide any warranty, see the MIT license for more information ©️ 2023 Haroun El Omri"),
        "areYouSureClearVaults": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete all vaults?"),
        "areYouSureDeleteFiles": m0,
        "areYouSureDeleteVault": m1,
        "biometrics": MessageLookupByLibrary.simpleMessage("Biometrics"),
        "biometricsAreLocal": MessageLookupByLibrary.simpleMessage(
            "Biometrics-locked chests can only be unlocked on the device it has been created on. Encrypted file export is unavailable."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chestName": MessageLookupByLibrary.simpleMessage("Chest Name"),
        "chestPassword": MessageLookupByLibrary.simpleMessage("Chest Password"),
        "chestPinCode": MessageLookupByLibrary.simpleMessage("Chest PIN code"),
        "closeChest": MessageLookupByLibrary.simpleMessage("Close the chest"),
        "closeChestNotificationContent": MessageLookupByLibrary.simpleMessage(
            "Click on the button down there to close it"),
        "closeChestNotificationTitle": MessageLookupByLibrary.simpleMessage(
            "You still have a chest opened"),
        "createANewChest":
            MessageLookupByLibrary.simpleMessage("Create a New Chest"),
        "createANewFolder":
            MessageLookupByLibrary.simpleMessage("Create a new folder"),
        "createTheNewChest":
            MessageLookupByLibrary.simpleMessage("Create the Chest"),
        "defineScheme":
            MessageLookupByLibrary.simpleMessage("Define the scheme"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAllChests":
            MessageLookupByLibrary.simpleMessage("Delete all the chests"),
        "detectedExportedFile": m2,
        "doNothing": MessageLookupByLibrary.simpleMessage("Do nothing"),
        "enterTheChestPassword": MessageLookupByLibrary.simpleMessage(
            "Please enter the password of this chest"),
        "enterTheChestScheme": MessageLookupByLibrary.simpleMessage(
            "Please enter the unlocking pattern of this chest"),
        "enterThePinCode": MessageLookupByLibrary.simpleMessage(
            "Please enter the pin code of this chest"),
        "errorChestNameShouldNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "The chest name must not be empty"),
        "errorChestPasswordMoreCharacters":
            MessageLookupByLibrary.simpleMessage(
                "The password must be at least 8 characters long"),
        "errorChestPasswordMoreDigits": MessageLookupByLibrary.simpleMessage(
            "The password must contain at least one digit"),
        "errorChestPasswordMoreLowercaseLetter":
            MessageLookupByLibrary.simpleMessage(
                "The password must contain at least one lowercase character"),
        "errorChestPasswordMoreUppercaseLetter":
            MessageLookupByLibrary.simpleMessage(
                "The password must contain at least one uppercase character"),
        "errorChestPasswordShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "The password must not be empty"),
        "errorChestPinCodeMoreCharacters": MessageLookupByLibrary.simpleMessage(
            "The chest PIN code should be at least 4 digits long"),
        "errorChestPinCodeShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "The chest PIN code shouldn\'t be empty"),
        "errorChestSchemeShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "The scheme must not be empty"),
        "errorDurationMustBeFormatted": MessageLookupByLibrary.simpleMessage(
            "The duration must be in the HH:MM format"),
        "errorDurationMustNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "The duration must not be empty"),
        "exportAsCleartext": MessageLookupByLibrary.simpleMessage(
            "Export as a clear file (not encrypted)"),
        "exportAsEncrypted":
            MessageLookupByLibrary.simpleMessage("Export as an encrypted file"),
        "exportedFileDescription": MessageLookupByLibrary.simpleMessage(
            "A file exported from the Life Chest app and needs to be unlocked to get more information about it."),
        "group": m3,
        "ignore": MessageLookupByLibrary.simpleMessage("Ignore"),
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "internalError": MessageLookupByLibrary.simpleMessage("Internal Error"),
        "lifeChestBulkSave":
            MessageLookupByLibrary.simpleMessage("Life Chest bulk file export"),
        "linkCopied": MessageLookupByLibrary.simpleMessage(
            "The link has been copied to your clipboard."),
        "loadingAudioTrack":
            MessageLookupByLibrary.simpleMessage("Loading audio track"),
        "loadingDocuments":
            MessageLookupByLibrary.simpleMessage("Loading document"),
        "loadingElements":
            MessageLookupByLibrary.simpleMessage("Loading elements"),
        "loadingImage": MessageLookupByLibrary.simpleMessage("Loading image"),
        "loadingVideo": MessageLookupByLibrary.simpleMessage("Loading video"),
        "lostDataContBeRecovered": MessageLookupByLibrary.simpleMessage(
            "This action is irreversible! All lost data can\'t be recovered."),
        "nameSortName":
            MessageLookupByLibrary.simpleMessage("Alphabetical order"),
        "newFolder": MessageLookupByLibrary.simpleMessage("New folder"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noChestsCreatedYet":
            MessageLookupByLibrary.simpleMessage("No chests created yet"),
        "noFilesCreatedYet":
            MessageLookupByLibrary.simpleMessage("No files added yet"),
        "notify": MessageLookupByLibrary.simpleMessage("Notify you"),
        "numberSortName":
            MessageLookupByLibrary.simpleMessage("First detected number"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pickFilesDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Pick the files you want to add"),
        "pickFolderDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Pick the folder you want to add"),
        "pinCode": MessageLookupByLibrary.simpleMessage("PIN code"),
        "playbackSpeed": MessageLookupByLibrary.simpleMessage("Playback speed"),
        "pleaseUseBiometrics": MessageLookupByLibrary.simpleMessage(
            "Please use your biometrics to unlock the chest"),
        "rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "savedToFolder": MessageLookupByLibrary.simpleMessage(
            "We successfully saved the file(s)"),
        "savedToFolderWarning": MessageLookupByLibrary.simpleMessage(
            "We successfully saved the file(s). WARNING! These encrypted files are more vulnerable in this format, do not publicly distribute them. Life Chest, its authors, or its contributors cannot be held liable for any divulged data."),
        "scheme": MessageLookupByLibrary.simpleMessage("Pattern"),
        "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
        "selected": m4,
        "sortBy": MessageLookupByLibrary.simpleMessage("Sort by..."),
        "subtitles": MessageLookupByLibrary.simpleMessage("Subtitles"),
        "unlockAbleBy": m5,
        "unlockChest": MessageLookupByLibrary.simpleMessage("Unlock the chest"),
        "unlockFile": MessageLookupByLibrary.simpleMessage("Unlock the file"),
        "unlockWizard": MessageLookupByLibrary.simpleMessage("Unlock wizard"),
        "useUnlockWizard":
            MessageLookupByLibrary.simpleMessage("Use the unlock wizard"),
        "validate": MessageLookupByLibrary.simpleMessage("Validate"),
        "welcomeNext": MessageLookupByLibrary.simpleMessage("Next"),
        "welcomePage1Content": MessageLookupByLibrary.simpleMessage(
            "Welcome to your Life Chest! Here, you will be able to create chests to store your data securely without compromising usability."),
        "welcomePage1Title":
            MessageLookupByLibrary.simpleMessage("Hello there!"),
        "welcomePage2Content": MessageLookupByLibrary.simpleMessage(
            "We use an encryption system called Chacha20, which means attempting to access your files without your password would take about 200 trillions of trillions of trillions times the age of the universe! And to prove it, we are 100% open-source!"),
        "welcomePage2Title": MessageLookupByLibrary.simpleMessage(
            "Your Security is Our Main Priority"),
        "welcomePage3Content": MessageLookupByLibrary.simpleMessage(
            "You\'ll see, it\'s fast, easy, and secure!"),
        "welcomePage3Title": MessageLookupByLibrary.simpleMessage(
            "Let\'s Create Your First Chest!"),
        "welcomeSkip": MessageLookupByLibrary.simpleMessage("Skip"),
        "whatShouldBeDoneAfterUnfocus": MessageLookupByLibrary.simpleMessage(
            "What should we do when the application is paused"),
        "wrongDevice": MessageLookupByLibrary.simpleMessage(
            "Wrong device, couldn\'t find the unlock data in the keystore"),
        "wrongPassword": MessageLookupByLibrary.simpleMessage("Wrong password"),
        "wrongPinCode": MessageLookupByLibrary.simpleMessage("Wrong PIN code"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
