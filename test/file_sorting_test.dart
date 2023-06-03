import 'package:life_chest/file_explorer/file_explorer.dart';
import 'package:life_chest/file_explorer/file_sort_methods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('File sorting test', () {
    Map<String, Map<String, String>> testFiles = {
      'testIdentifier1': {'name': '../myfileName.txt'},
      'testIdentifier2': {'name': 'myasecondfileName.txt'}
    };

    expect(
        FileExplorerState.sortMap(FileSortMethod.name, testFiles),
        equals({
          'testIdentifier2': {'name': 'myasecondfileName.txt'},
          'testIdentifier1': {'name': '../myfileName.txt'}
        }));
  });
}
