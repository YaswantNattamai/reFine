import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentDateProvider = StreamProvider<DateTime>((ref) {
  DateTime getMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  final controller = StreamController<DateTime>();
  controller.add(getMidnight());

  // Check every 10 seconds if the date has changed
  final timer = Timer.periodic(const Duration(seconds: 10), (_) {
    final current = getMidnight();
    if (!controller.isClosed) {
      controller.add(current);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream.distinct();
});
