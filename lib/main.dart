import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/routes/app_routes.dart';
import 'core/l10n/app_localizations.dart';
import 'core/service_locator.dart' as di;
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'dart:async';

import 'features/alerts/presentation/alerts_cubit.dart';
import 'features/sync/data/sync_store.dart';
import 'features/sync/presentation/sync_cubit.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';
import 'features/settings/presentation/cubit/app_preferences_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  // Alerts are checked from the start, even on the PIN screen.
  di.sl<AlertsCubit>().start();
  // The hub (owner's phone) or the automatic syncs (worker's phone).
  unawaited(di.sl<SyncCubit>().start());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
            create: (context) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider<ShopBloc>(
            create: (context) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<BillingBloc>(create: (context) => di.sl<BillingBloc>()),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
        BlocProvider<AppPreferencesCubit>(
            create: (context) => di.sl<AppPreferencesCubit>()),
        // One session for the whole app; the router listens to it too.
        BlocProvider<SessionCubit>.value(value: di.sl<SessionCubit>()),
        BlocProvider<AlertsCubit>.value(value: di.sl<AlertsCubit>()),
        BlocProvider<SyncCubit>.value(value: di.sl<SyncCubit>()),
      ],
      child: _ReloadAfterSync(
          child: BlocBuilder<AppPreferencesCubit, AppPreferences>(
        builder: (context, prefs) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: prefs.themeMode,
            locale: prefs.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: resolveAppLocale,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      )),
    );
  }
}

/// Reloads the product list and the shop after rows arrived from another
/// phone, so new prices and stock show at once.
class _ReloadAfterSync extends StatefulWidget {
  final Widget child;
  const _ReloadAfterSync({required this.child});

  @override
  State<_ReloadAfterSync> createState() => _ReloadAfterSyncState();
}

class _ReloadAfterSyncState extends State<_ReloadAfterSync> {
  StreamSubscription<void>? _subscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscription = di.sl<SyncStore>().received.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.read<ProductBloc>().add(LoadProducts());
        context.read<ShopBloc>().add(LoadShopEvent());
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
