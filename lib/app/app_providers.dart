import 'dart:ui';

import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

//Locale is nullable to allow ref is null.
//This is because we want to set the locale to null when the user logs out,
//so that the app will use the system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);