import '../../core/session/session_cubit.dart';

/// Pages only the owner may open.
const ownerOnlyPaths = ['/more/shop', '/more/workers'];

/// Decides where someone may go. Returns the page to send them to
/// instead, or null when [location] is allowed:
/// - no owner yet -> the first-launch setup,
/// - nobody logged in -> the PIN screen,
/// - a worker asking for an owner page -> back to selling.
String? guardRoute(SessionState session, String location) {
  if (!session.hasOwner) return location == '/setup' ? null : '/setup';
  if (!session.isLoggedIn) return location == '/login' ? null : '/login';
  if (location == '/setup' || location == '/login') return '/sell';
  if (!session.isOwner && ownerOnlyPaths.any(location.startsWith)) {
    return '/sell';
  }
  return null;
}
