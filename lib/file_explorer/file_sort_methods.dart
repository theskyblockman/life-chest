import 'package:flutter/material.dart';
import 'package:life_chest/file_explorer/explorer_data.dart';
import 'package:life_chest/generated/l10n.dart';

/// The file sorter class with some util methods
class FileSortMethod {
  static final FileSortMethod name = FileSortMethod((context) {
    return S.of(context).nameSortName;
  },
      (oldMap) => oldMap
        ..sort((a, b) {
          return a.name.compareTo(b.name);
        }),
      'by_name');

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
  },
      (oldMap) => oldMap
        ..sort((a, b) {
          return (_getFirstInteger(a.name) ?? -1)
              .compareTo(_getFirstInteger(b.name) ?? -1);
        }),
      'by_number');

  static final FileSortMethod random = FileSortMethod((context) {
    return S.of(context).randomSortName;
  }, (oldMap) => oldMap..shuffle(), 'randomly');

  static final List<FileSortMethod> values = [name, number, random];

  static FileSortMethod? fromID(String id) {
    for (FileSortMethod method in values) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  final String Function(BuildContext context) getDisplayName;
  final List<MapEntry<String, dynamic>> Function(
      List<MapEntry<String, dynamic>> oldMap) sort;
  final String id;

  const FileSortMethod(this.getDisplayName, this.sort, this.id);
}
