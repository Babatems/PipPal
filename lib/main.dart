import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dates and times follow the device locale (decision D27).
  Intl.defaultLocale = Intl.canonicalizedLocale(
    PlatformDispatcher.instance.locale.toString(),
  );
  await initializeDateFormatting();
  runApp(const ProviderScope(child: PipPalApp()));
}
