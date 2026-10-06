import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../core/session/session_cubit.dart';
import '../../core/widgets/coming_soon_page.dart';
import '../../core/widgets/empty_state.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/pages/pending_payments_page.dart';
import '../../features/suppliers/presentation/pages/supplier_detail_page.dart';
import '../../features/suppliers/presentation/pages/supplier_form_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/billing/presentation/pages/return_page.dart';
import '../../features/stock/presentation/pages/add_delivery_page.dart';
import '../../features/stock/presentation/pages/losses_page.dart';
import '../../features/stock/presentation/pages/product_detail_page.dart';
import '../../features/stock/presentation/pages/record_loss_page.dart';
import '../../features/billing/presentation/pages/sale_detail_page.dart';
import '../../features/billing/presentation/pages/sales_history_page.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/setup_page.dart';
import '../../features/users/domain/entities/app_user.dart';
import '../../features/users/presentation/pages/failed_logins_page.dart';
import '../../features/users/presentation/pages/profile_page.dart';
import '../../features/users/presentation/pages/user_form_page.dart';
import '../../features/users/presentation/pages/workers_page.dart';
import 'app_shell.dart';
import 'route_guard.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/sell',
  redirect: (context, state) =>
      guardRoute(sl<SessionCubit>().state, state.matchedLocation),
  // Check the rules again whenever someone logs in or out.
  refreshListenable: _StreamListenable(sl<SessionCubit>().stream),
  routes: [
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/sell',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'checkout',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const CheckoutPage(),
              ),
              GoRoute(
                path: 'history',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const SalesHistoryPage(),
                routes: [
                  GoRoute(
                    path: ':saleId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        SaleDetailPage(saleId: state.pathParameters['saleId']!),
                    routes: [
                      GoRoute(
                        path: 'return',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            ReturnPage(saleId: state.pathParameters['saleId']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stock',
            builder: (context, state) => const ProductListPage(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AddProductPage(),
              ),
              GoRoute(
                path: 'product/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    ProductDetailPage(productId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'delivery',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    AddDeliveryPage(productId: state.extra as String?),
              ),
              GoRoute(
                path: 'loss',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    RecordLossPage(productId: state.extra as String?),
              ),
              GoRoute(
                path: 'losses',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const LossesPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  final product = state.extra as Product? ??
                      context
                          .read<ProductBloc>()
                          .state
                          .products
                          .where((p) => p.id == id)
                          .firstOrNull;
                  if (product == null) return const _ProductMissingPage();
                  return EditProductPage(product: product);
                },
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const ComingSoonPage.stats(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const ComingSoonPage.alerts(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/more',
            builder: (context, state) => const MorePage(),
            routes: [
              GoRoute(
                path: 'shop',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ShopDetailsPage(),
              ),
              GoRoute(
                path: 'profile',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'security',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const FailedLoginsPage(),
              ),
              GoRoute(
                path: 'workers',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const WorkersPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const UserFormPage(),
                  ),
                  GoRoute(
                    path: ':userId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        UserFormPage(user: state.extra as AppUser?),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ScannerPage(),
    ),
    // Customers and suppliers sit above the tabs, so they can be opened
    // from anywhere (More tab, checkout, stock delivery...).
    GoRoute(
      path: '/customers',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CustomersPage(),
      routes: [
        GoRoute(
          path: 'new',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const CustomerFormPage(),
        ),
        GoRoute(
          path: ':id',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              CustomerDetailPage(customerId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) =>
                  CustomerFormPage(customer: state.extra as Customer?),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/suppliers',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SuppliersPage(),
      routes: [
        GoRoute(
          path: 'new',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const SupplierFormPage(),
        ),
        GoRoute(
          path: ':id',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              SupplierDetailPage(supplierId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) =>
                  SupplierFormPage(supplier: state.extra as Supplier?),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/payments',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PendingPaymentsPage(),
    ),
  ],
);

class _ProductMissingPage extends StatelessWidget {
  const _ProductMissingPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProduct)),
      body: EmptyState(
          icon: Icons.search_off_rounded, title: l10n.productsNoMatch),
    );
  }
}

/// Lets the router listen to the session: each change re-runs [guardRoute].
class _StreamListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
