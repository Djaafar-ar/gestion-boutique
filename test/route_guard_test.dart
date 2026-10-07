import 'package:billing_app/config/routes/route_guard.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const owner = AppUser(id: 'o', name: 'Karim', role: UserRole.owner);
  const worker = AppUser(id: 'w', name: 'Amine', role: UserRole.worker);

  test('first launch always goes to the setup', () {
    const session = SessionState(hasOwner: false);
    expect(guardRoute(session, '/sell'), '/setup');
    expect(guardRoute(session, '/login'), '/setup');
    expect(guardRoute(session, '/setup'), isNull);
    // A worker's phone joins the owner's shop instead.
    expect(guardRoute(session, '/join'), isNull);
    expect(guardRoute(session, '/scanner'), isNull);
  });

  test('nobody logged in: only the PIN screen', () {
    const session = SessionState(hasOwner: true);
    expect(guardRoute(session, '/sell'), '/login');
    expect(guardRoute(session, '/more/workers'), '/login');
    expect(guardRoute(session, '/login'), isNull);
  });

  test('after logging in, setup and login lead to selling', () {
    const session = SessionState(hasOwner: true, user: worker);
    expect(guardRoute(session, '/login'), '/sell');
    expect(guardRoute(session, '/setup'), '/sell');
  });

  test('a worker can sell, edit products and see their profile', () {
    const session = SessionState(hasOwner: true, user: worker);
    for (final path in [
      '/sell',
      '/sell/checkout',
      '/sell/history',
      '/stock',
      '/stock/add',
      '/stock/edit/p1',
      '/more',
      '/more/profile',
    ]) {
      expect(guardRoute(session, path), isNull, reason: path);
    }
  });

  test('a worker cannot open owner pages', () {
    const session = SessionState(hasOwner: true, user: worker);
    expect(guardRoute(session, '/more/shop'), '/sell');
    expect(guardRoute(session, '/more/workers'), '/sell');
    expect(guardRoute(session, '/more/workers/new'), '/sell');
    expect(guardRoute(session, '/payments'), '/sell');
    expect(guardRoute(session, '/more/notifications'), '/sell');
  });

  test('a worker can use the carnet and suppliers', () {
    const session = SessionState(hasOwner: true, user: worker);
    for (final path in [
      '/customers',
      '/customers/new',
      '/customers/c1',
      '/suppliers',
      '/suppliers/s1',
      '/alerts',
    ]) {
      expect(guardRoute(session, path), isNull, reason: path);
    }
  });

  test('the owner can open everything', () {
    const session = SessionState(hasOwner: true, user: owner);
    expect(guardRoute(session, '/more/shop'), isNull);
    expect(guardRoute(session, '/more/workers/w'), isNull);
    expect(guardRoute(session, '/payments'), isNull);
  });

  // Phase 8: the figures and the backups stay with the owner; a new phone
  // may restore a backup before any account exists.
  test('Google Sheet: workers see the sending only', () {
    const asWorker = SessionState(hasOwner: true, user: worker);
    expect(guardRoute(asWorker, '/more/sheet'), isNull);
    for (final path in [
      '/more/sheet/live',
      '/more/sheet/report',
      '/more/backup',
      '/restore',
    ]) {
      expect(guardRoute(asWorker, path), '/sell', reason: path);
    }
    const asOwner = SessionState(hasOwner: true, user: owner);
    expect(guardRoute(asOwner, '/more/sheet/live'), isNull);
    expect(guardRoute(asOwner, '/restore'), isNull);
    const newPhone = SessionState(hasOwner: false);
    expect(guardRoute(newPhone, '/restore'), isNull);
    expect(guardRoute(newPhone, '/more/backup'), '/setup');
  });
}
