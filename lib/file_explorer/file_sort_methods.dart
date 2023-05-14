import 'package:flutter/material.dart';
import 'package:life_chest/generated/l10n.dart';

/// The file sorter class with some util methods
class FileSortMethod {
  static final FileSortMethod name = FileSortMethod((context) {
    return S.of(context).nameSortName;
  }, (a, b) {
    return a.compareTo(b);
  }, 'by_name');

  static int? _getFirstInteger(String stringToSearchIn) {
    if (!stringToSearchIn.contains(RegExp(r'\d'))) {
      return null;
    } else {
      String currentlyConstructedInteger = '';
      for (String searchableCharacter in stringToSearchIn
          .substring(stringToSearchIn.indexOf(RegExp(r'\d')))
          .characters) {
        if (searchableCharacter.contains(RegExp(r'\d'))) {
          currentlyConstructedInteger += searchableCharacter;
        } else {
          break;
        }
      }
      return int.parse(currentlyConstructedInteger);
    }
  }

  static final FileSortMethod number = FileSortMethod((context) {
    return S.of(context).numberSortName;
  }, (a, b) {
    return (_getFirstInteger(a) ?? -1).compareTo(_getFirstInteger(b) ?? -1);
  }, 'by_number');

  static final List<FileSortMethod> values = [name, number];

  static FileSortMethod? fromID(String id) {
    for (FileSortMethod method in values) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  final String Function(BuildContext context) getDisplayName;
  final int Function(String a, String b) sort;
  final String id;

  const FileSortMethod(this.getDisplayName, this.sort, this.id);
}
