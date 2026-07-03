import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id id = Isar.autoIncrement;

  double wallpaperUnlockedThreshold = 0.8; // e.g. 80% tasks done
  bool quoteEnabled = true;
  String? selectedWallpaperPath;
  bool defaultLauncher = false;
  List<String> favoriteApps = [];
}
