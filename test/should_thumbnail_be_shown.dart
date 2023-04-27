import 'package:test/test.dart';
import 'package:life_chest/file_explorer/file_explorer.dart';

void main() {
  test('See if the thumbnails system works as intended (like a file explorer)', () {
    expect(FileExplorerState.shouldThumbnailBeShown('Test file', ''), isTrue);
    expect(FileExplorerState.shouldThumbnailBeShown('Test folder/Test file', ''), isFalse);
    expect(FileExplorerState.shouldThumbnailBeShown('Test folder/Test file', 'Test folder 2'), isFalse);
    expect(FileExplorerState.shouldThumbnailBeShown('Test folder/Test file', 'Test folder'), isTrue);
  });
}