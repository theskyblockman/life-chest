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
      "${count} ${Intl.plural(count, one: 'fichier sélectionné', other: 'fichiers sélectionnés')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("À propos..."),
        "addFiles":
            MessageLookupByLibrary.simpleMessage("Ajouter des fichiers"),
        "appLegalese": MessageLookupByLibrary.simpleMessage(
            "L\'application \"Life Chest\" a été crée par Theskyblockman avec du ❤️ et un 🖥️ sous la licence MIT, ©️ 2023 Haroun El Omri"),
        "areYouSure": MessageLookupByLibrary.simpleMessage("Êtes-vous sûr?"),
        "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "chestName": MessageLookupByLibrary.simpleMessage("Nom du coffre"),
        "chestPassword":
            MessageLookupByLibrary.simpleMessage("Mot de passe du coffre"),
        "closeChest": MessageLookupByLibrary.simpleMessage("Fermer le coffre"),
        "closeChestNotificationContent": MessageLookupByLibrary.simpleMessage(
            "Appuiez sur le bouton ci-dessous pour le fermer"),
        "closeChestNotificationTitle": MessageLookupByLibrary.simpleMessage(
            "Vous avez toujours un coffre d\'ouvert"),
        "createANewChest":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau coffre"),
        "createANewFolder":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau dossier"),
        "createTheNewChest":
            MessageLookupByLibrary.simpleMessage("Créer le coffre"),
        "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "deleteAllChests":
            MessageLookupByLibrary.simpleMessage("Supprimer tous les coffres"),
        "doNothing": MessageLookupByLibrary.simpleMessage("Ne rien faire"),
        "enterTheChestPassword": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer le mot de passe de ce coffre"),
        "errorChestNameShouldNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "Le nom du coffre ne dois pas être vide"),
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
        "errorDurationMustBeFormatted": MessageLookupByLibrary.simpleMessage(
            "La durée doit être au format HH:MM"),
        "errorDurationMustNotBeEmpty": MessageLookupByLibrary.simpleMessage(
            "La durée ne doit pas être vide"),
        "loadingAudioTrack": MessageLookupByLibrary.simpleMessage(
            "Chargement de la piste audio"),
        "loadingDocuments":
            MessageLookupByLibrary.simpleMessage("Chargement du document"),
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
            "Aucun fichiers ajoutés pour le moment"),
        "notify": MessageLookupByLibrary.simpleMessage("Vous notifier"),
        "numberSortName":
            MessageLookupByLibrary.simpleMessage("Premier nombre détecté"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "pickFilesDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Choisissez les fichiers que vous voulez ajouter"),
        "pickFolderDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Choisissez le dossier que vous voulez ajouter"),
        "rename": MessageLookupByLibrary.simpleMessage("Renommer"),
        "selectAll": MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
        "selected": m0,
        "shouldEnterAirplaneMode": MessageLookupByLibrary.simpleMessage(
            "Activer le mode avion lorsque le coffre s\'ouvre"),
        "sortBy": MessageLookupByLibrary.simpleMessage("Trier par..."),
        "validate": MessageLookupByLibrary.simpleMessage("Valider"),
        "welcomeNext": MessageLookupByLibrary.simpleMessage("Suivant"),
        "welcomePage1Content": MessageLookupByLibrary.simpleMessage(
            "Bienvenue dans votre coffre de vie ! Ici, vous pourrez créer des coffres pour stocker vos données en toute sécurité sans compromettre l\'utilisation."),
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
        "yes": MessageLookupByLibrary.simpleMessage("Oui")
      };
}
