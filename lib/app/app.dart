import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/pnl_colors.dart';
import '../features/settings/application/appearance_controller.dart';
import 'router.dart';

class PipPalApp extends ConsumerWidget {
  const PipPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);
    final router = ref.watch(routerProvider);

    PnlColors pnl(Brightness b) =>
        (b == Brightness.dark ? PnlColors.dark : PnlColors.light).withOverrides(
          profit: appearance.profit,
          loss: appearance.loss,
          brightness: b,
        );

    return MaterialApp.router(
      title: 'PipPal',
      debugShowCheckedModeBanner: false,
      themeMode: appearance.mode,
      theme: AppTheme.light(pnl: pnl(Brightness.light)),
      darkTheme: AppTheme.dark(pnl: pnl(Brightness.dark)),
      routerConfig: router,
    );
  }
}
