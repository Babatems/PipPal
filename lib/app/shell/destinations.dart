import '../../core/widgets/pip_icons.dart';

/// The four tab destinations, in shell-branch order.
enum AppDestination {
  dashboard('Dashboard', '/dashboard', PipGlyph.dashboard),
  journal('Journal', '/journal', PipGlyph.journal),
  calendar('Calendar', '/calendar', PipGlyph.calendar),
  analytics('Analytics', '/analytics', PipGlyph.analytics);

  const AppDestination(this.label, this.path, this.glyph);

  final String label;
  final String path;
  final PipGlyph glyph;
}
