import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../core/session/session_cubit.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/presentation/pages/failed_logins_page.dart';

/// Which bottom tab is visible. The Sell tab listens to it to switch the
/// camera off while another tab is open.
final currentTabIndex = ValueNotifier<int>(0);

/// The frame around the 5 main tabs, with the bottom navigation bar.
class AppShell extends StatefulWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StatefulNavigationShell get shell => widget.shell;

  @override
  void initState() {
    super.initState();
    // The shell is built again after every login.
    WidgetsBinding.instance.addPostFrameCallback((_) => _warnOwner());
  }

  /// Tells the owner about wrong codes typed since their last login.
  Future<void> _warnOwner() async {
    if (!context.read<SessionCubit>().state.isOwner) return;
    final attempts =
        await sl<UserRepository>().getFailedLogins(unseenOnly: true);
    if (attempts.isEmpty || !mounted) return;
    await showFailedLoginsWarning(context, attempts,
        onSeeAll: () => context.push('/more/security'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Keep the shared tab index right after a login or a redirect too.
    if (currentTabIndex.value != shell.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => currentTabIndex.value = shell.currentIndex);
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) {
          currentTabIndex.value = index;
          // Tapping the open tab again goes back to its first screen.
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: l10n.navSell,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.navStock,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: l10n.navAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
