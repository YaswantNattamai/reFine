import 'package:isar/isar.dart';

part 'widget_config.g.dart';

@collection
class WidgetConfig {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String widgetType; // "timetable", "workout", "motivation"

  double height = 250.0;
  int position = 0;
  bool isVisible = true;
}
