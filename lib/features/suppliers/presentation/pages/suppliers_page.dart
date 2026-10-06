import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../widgets/supplier_widgets.dart';

/// Every supplier with what the shop still owes them.
class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  late Future<List<Supplier>> _suppliers = _load();
  late Future<int> _pending = sl<SupplierRepository>().pendingCount();

  Future<List<Supplier>> _load() async =>
      (await sl<SupplierRepository>().getSuppliers()).getOrElse((_) => []);

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) {
      setState(() {
        _suppliers = _load();
        _pending = sl<SupplierRepository>().pendingCount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOwner = context.watch<SessionCubit>().state.isOwner;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suppliersTitle),
        actions: [
          if (isOwner)
            FutureBuilder<int>(
              future: _pending,
              builder: (context, snapshot) => IconButton(
                tooltip: l10n.pendingPaymentsTitle,
                onPressed: () => _open('/payments'),
                icon: Badge(
                  isLabelVisible: (snapshot.data ?? 0) > 0,
                  label: Text('${snapshot.data ?? 0}'),
                  child: const Icon(Icons.fact_check_outlined),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open('/suppliers/new'),
        icon: const Icon(Icons.add_business_outlined),
        label: Text(l10n.newSupplier),
      ),
      body: FutureBuilder<List<Supplier>>(
        future: _suppliers,
        builder: (context, snapshot) {
          final suppliers = snapshot.data;
          if (suppliers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (suppliers.isEmpty) {
            return EmptyState(
                icon: Icons.local_shipping_outlined, title: l10n.noSuppliers);
          }
          final owed = suppliers
              .map((s) => s.balance)
              .where((b) => b > 0)
              .fold<int>(0, (a, b) => a + b);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                color: scheme.secondaryContainer,
                child: ListTile(
                  leading: Icon(Icons.account_balance_outlined,
                      color: scheme.onSecondaryContainer),
                  title: Text(l10n.totalOwedToSuppliers,
                      style: TextStyle(color: scheme.onSecondaryContainer)),
                  trailing: Text(formatDAForUi(owed),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSecondaryContainer)),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, supplier) in suppliers.indexed) ...[
                      if (index > 0) const Divider(height: 1),
                      ListTile(
                        title: Text(supplier.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          if (supplier.phone.isNotEmpty) supplier.phone,
                          if (supplier.pending > 0)
                            l10n.pendingAmount(formatDAForUi(supplier.pending)),
                        ].join(' · ')),
                        trailing:
                            SupplierBalanceText(balance: supplier.balance),
                        onTap: () => _open('/suppliers/${supplier.id}'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
