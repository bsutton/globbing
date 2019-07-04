import "dart:io";
import "package:globbing/glob_filter.dart";
import "package:globbing/glob_lister.dart";
import "package:path/path.dart" as pathos;
import "package:test/test.dart";

void main() {
  _testExclude();
  _testInclude();
}

void _testExclude() {
  test("GlobFilter.exclude()", () {
    {
      var appRoot = Directory.current.path;
      appRoot = appRoot.replaceAll("\\", "/");
      var pattern = appRoot + "/lib/**/*.dart";
      var lister = _getLister(pattern);
      var list = lister.list(Directory.current.path);
      var isDirectory = (String path) => Directory(path).existsSync();
      var criteria = appRoot + "/**/src/glob_*.dart";
      var filter = GlobFilter(criteria,
          isDirectory: isDirectory, isWindows: Platform.isWindows);
      var result = filter.exclude(list);
      result.sort((a, b) => a.compareTo(b));
      result = result.map((e) => pathos.basename(e)).toList();
      var expected = ["globbing.dart"];
      expect(result, expected);
    }
  });
}

void _testInclude() {
  test("GlobFilter.include()", () {
    {
      var appRoot = Directory.current.path;
      appRoot = appRoot.replaceAll("\\", "/");
      var pattern = appRoot + "/lib/**/*.dart";
      var lister = _getLister(pattern);
      var list = lister.list(Directory.current.path);
      var isDirectory = (String path) => Directory(path).existsSync();
      var criteria = appRoot + "/**/src/glob_*.dart";
      var filter = GlobFilter(criteria,
          isDirectory: isDirectory, isWindows: Platform.isWindows);
      var result = filter.include(list);
      result.sort((a, b) => a.compareTo(b));
      result = result.map((e) => pathos.basename(e)).toList();
      var expected = [
        "glob_filter.dart",
        "glob_lister.dart",
        "glob_parser.dart"
      ];
      expect(result, expected);
    }
  });
}

GlobLister _getLister(String pattern) {
  var exists = (String path) {
    return FileStat.statSync(path).type != FileSystemEntityType.notFound;
  };

  var isDirectory = (String path) {
    return FileStat.statSync(path).type == FileSystemEntityType.directory;
  };

  var list = (String path, bool followLinks) {
    return Directory(path)
        .listSync(followLinks: followLinks)
        .map((e) => e.path)
        .toList();
  };

  var lister = GlobLister(pattern,
      exists: exists,
      isDirectory: isDirectory,
      isWindows: Platform.isWindows,
      list: list);

  return lister;
}
