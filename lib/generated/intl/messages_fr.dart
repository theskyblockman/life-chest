// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "Nous avons détecté ${Intl.plural(count, one: 'un fichier', other: 'des fichiers')} provenant d\'un coffre. Pour accéder à ${Intl.plural(count, one: 'son', other: 'leur')} contenu, vous devez ${Intl.plural(count, one: 'le', other: 'les')} déverrouiller.";

  static String m1(group_id) => "Groupe n°${group_id}";

  static String m2(path) =>
      "Le(s) fichier(s) a/ont été sauvegardé(s) dans ${path}";

  static String m3(count) =>
      "${count} ${Intl.plural(count, one: 'fichier sélectionné', other: 'fichiers sélectionnés')}";

  static String m4(unlock_name) =>
      "Ce groupe peut être débloquer grâce à : {unlock_name).";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("À propos..."),
        "addFiles":
            MessageLookupByLibrary.simpleMessage("Ajouter des fichiers"),
        "appLegalese": MessageLookupByLibrary.simpleMessage(
            "L\'application \"Life Chest\" a été créée par Theskyblockman avec ❤️ et un 🖥️ sous la licence MIT, ©️ 2023 Haroun El Omri"),
        "areYouSure": MessageLookupByLibrary.simpleMessage("Êtes-vous sûr ?"),
        "biometrics":
            MessageLookupByLibrary.simpleMessage("Empreinte digitale"),
        "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "chestName": MessageLookupByLibrary.simpleMessage("Nom du coffre"),
        "chestPassword":
            MessageLookupByLibrary.simpleMessage("Mot de passe du coffre"),
        "chestPinCode":
            MessageLookupByLibrary.simpleMessage("Code PIN du coffre"),
        "closeChest": MessageLookupByLibrary.simpleMessage("Fermer le coffre"),
        "closeChestNotificationContent": MessageLookupByLibrary.simpleMessage(
            "Appuyez sur le bouton ci-dessous pour le fermer"),
        "closeChestNotificationTitle": MessageLookupByLibrary.simpleMessage(
            "Vous avez toujours un coffre ouvert"),
        "createANewChest":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau coffre"),
        "createANewFolder":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau dossier"),
        "createTheNewChest":
            MessageLookupByLibrary.simpleMessage("Créer le coffre"),
        "defineScheme":
            MessageLookupByLibrary.simpleMessage("Définir le modèle"),
        "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "deleteAllChests":
            MessageLookupByLibrary.simpleMessage("Supprimer tous les coffres"),
        "detectedExportedFile": m0,
        "doNothing": MessageLookupByLibrary.simpleMessage("Ne rien faire"),
        "enterTheChestPassword": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer le mot de passe de ce coffre"),
        "enterTheChestScheme": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer le modèle du coffre"),
        "enterThePinCode": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer le code PIN du coffre"),
        "errorChestNameShouldNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "Le nom du coffre ne doit pas être vide"),
        "errorChestPasswordMoreCharacters":
            MessageLookupByLibrary.simpleMessage(
                "Le mot de passe doit contenir au moins 8 caractères"),
        "errorChestPasswordMoreDigits": MessageLookupByLibrary.simpleMessage(
            "Le mot de passe doit contenir au moins un chiffre"),
        "errorChestPasswordMoreLowercaseLetter":
            MessageLookupByLibrary.simpleMessage(
                "Le mot de passe doit contenir au moins une lettre minuscule"),
        "errorChestPasswordMoreUppercaseLetter":
            MessageLookupByLibrary.simpleMessage(
                "Le mot de passe doit contenir au moins une lettre majuscule"),
        "errorChestPasswordShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "Le mot de passe ne doit pas être vide"),
        "errorChestPinCodeMoreCharacters": MessageLookupByLibrary.simpleMessage(
            "Le code PIN doit contenir au moins 4 caractères"),
        "errorChestPinCodeShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "Le code PIN ne doit pas être vide"),
        "errorChestSchemeShouldNotBeEmpty":
            MessageLookupByLibrary.simpleMessage(
                "Le schéma ne doit pas être vide"),
        "errorDurationMustBeFormatted": MessageLookupByLibrary.simpleMessage(
            "La durée doit être au format HH:MM"),
        "errorDurationMustNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "La durée ne doit pas être vide"),
        "exportAsCleartext": MessageLookupByLibrary.simpleMessage(
            "Exporter en tant que fichier lisible (fichier non encrypté)"),
        "exportAsEncrypted": MessageLookupByLibrary.simpleMessage(
            "Exporter en tant que fichier encrypté"),
        "exportedFileDescription": MessageLookupByLibrary.simpleMessage(
            "Um fichier exporté depuis Life Chest qui est encrypté et qui a donc besoin d\'être décrypté pour être lu."),
        "group": m1,
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorer"),
        "import": MessageLookupByLibrary.simpleMessage("Importer"),
        "lifeChestBulkSave": MessageLookupByLibrary.simpleMessage(
            "Sauvegarde de fichiers en masse"),
        "loadingAudioTrack": MessageLookupByLibrary.simpleMessage(
            "Chargement de la piste audio"),
        "loadingDocuments":
            MessageLookupByLibrary.simpleMessage("Chargement des documents"),
        "loadingElements":
            MessageLookupByLibrary.simpleMessage("Chargement des éléments"),
        "loadingImage":
            MessageLookupByLibrary.simpleMessage("Chargement de l\'image"),
        "nameSortName":
            MessageLookupByLibrary.simpleMessage("Ordre alphabétique"),
        "newFolder": MessageLookupByLibrary.simpleMessage("Nouveau dossier"),
        "no": MessageLookupByLibrary.simpleMessage("Non"),
        "noChestsCreatedYet": MessageLookupByLibrary.simpleMessage(
            "Aucun coffre créé pour le moment"),
        "noFilesCreatedYet": MessageLookupByLibrary.simpleMessage(
            "Aucun fichier ajouté pour le moment"),
        "notify": MessageLookupByLibrary.simpleMessage("Vous notifier"),
        "numberSortName":
            MessageLookupByLibrary.simpleMessage("Premier nombre détecté"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
        "pickFilesDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Choisissez les fichiers que vous voulez ajouter"),
        "pickFolderDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Choisissez le dossier que vous voulez ajouter"),
        "pinCode": MessageLookupByLibrary.simpleMessage("Code PIN"),
        "pleaseUseBiometrics": MessageLookupByLibrary.simpleMessage(
            "Veuillez utiliser votre empreinte digitale pour déverrouiller le coffre"),
        "rename": MessageLookupByLibrary.simpleMessage("Renommer"),
        "savedToFolder": m2,
        "scheme": MessageLookupByLibrary.simpleMessage("Modèle"),
        "selectAll": MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
        "selected": m3,
        "shouldEnterAirplaneMode": MessageLookupByLibrary.simpleMessage(
            "Activer le mode avion lorsque le coffre s\'ouvre"),
        "sortBy": MessageLookupByLibrary.simpleMessage("Trier par..."),
        "unlockAbleBy": m4,
        "unlockChest": MessageLookupByLibrary.simpleMessage(
            "Veuillez déverrouiller le coffre"),
        "unlockFile":
            MessageLookupByLibrary.simpleMessage("Déverrouiller le fichier"),
        "unlockWizard":
            MessageLookupByLibrary.simpleMessage("Assistant de déverrouillage"),
        "useUnlockWizard": MessageLookupByLibrary.simpleMessage(
            "Utiliser l\'assistant de déverrouillage"),
        "validate": MessageLookupByLibrary.simpleMessage("Valider"),
        "welcomeNext": MessageLookupByLibrary.simpleMessage("Suivant"),
        "welcomePage1Content": MessageLookupByLibrary.simpleMessage(
            "Bienvenue dans votre coffre de vie ! Ici, vous pourrez créer des coffres pour stocker vos données en toute sécurité sans compromettre leur utilisation."),
        "welcomePage1Title": MessageLookupByLibrary.simpleMessage("Bonjour !"),
        "welcomePage2Content": MessageLookupByLibrary.simpleMessage(
            "Nous utilisons un système de cryptage appelé Chacha20, donc essayer d\'accéder à vos fichiers sans votre mot de passe prendra environ 200 billions de billions de billions de fois l\'âge de l\'univers ! Et pour le prouver, nous sommes 100 % open-source !"),
        "welcomePage2Title": MessageLookupByLibrary.simpleMessage(
            "Ici, notre priorité principale est votre sécurité"),
        "welcomePage3Content": MessageLookupByLibrary.simpleMessage(
            "Vous verrez, c\'est rapide, facile et sécurisé !"),
        "welcomePage3Title": MessageLookupByLibrary.simpleMessage(
            "Créons votre premier coffre !"),
        "welcomeSkip": MessageLookupByLibrary.simpleMessage("Passer"),
        "whatShouldBeDoneAfterUnfocus": MessageLookupByLibrary.simpleMessage(
            "Que devons-nous faire si l\'application est mise en pause"),
        "wrongPassword":
            MessageLookupByLibrary.simpleMessage("Mauvais mot de passe"),
        "wrongPinCode":
            MessageLookupByLibrary.simpleMessage("Code PIN incorrect"),
        "yes": MessageLookupByLibrary.simpleMessage("Oui")
      };
}
