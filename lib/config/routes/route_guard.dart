import '../../core/session/session_cubit.dart';

/// Pages only the owner may open.
const ownerOnlyPaths = [
  '/more/shop',
  '/more/workers',
  '/more/security',
  '/more/notifications',
  '/more/sheet/live',
  '/more/sheet/report',
  '/more/backup',
  '/restore',
  '/payments',
];

/// Decides where someone may go. Returns the page to send them to
/// instead, or null when [location] is allowed:
/// - no owner yet -> the first-launch setup,
/// - nobody logged in -> the PIN screen,
/// - a worker asking for an owner page -> back to selling.
String? guardRoute(SessionState session, String location) {
  // Before an owner exists: create the shop, join one (scanning the
  // owner's code), or restore a backup (new phone).
  if (!session.hasOwner) {
    return const ['/setup', '/join', '/scanner', '/restore'].contains(location)
        ? null
        : '/setup';
  }
  if (!session.isLoggedIn) return location == '/login' ? null : '/login';
  if (location == '/setup' || location == '/login' || location == '/join') {
    return '/sell';
  }
  if (!session.isOwner && ownerOnlyPaths.any(location.startsWith)) {
    return '/sell';
  }
  return null;
}
