import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../widgets/debt_text.dart';

/// The carnet: every customer with what they owe, and the total.
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Future<List<Customer>> _customers = _load();
  final _search = TextEditingController();

  Future<List<Customer>> _load() async =>
      (await sl<CustomerRepository>().getCustomers()).getOrElse((_) => []);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) {
      setState(() {
        _customers = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open('/customers/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.newCustomer),
      ),
      body: FutureBuilder<List<Customer>>(
        future: _customers,
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (all.isEmpty) {
            return EmptyState(
                icon: Icons.menu_book_outlined, title: l10n.noCustomers);
          }
          final owed = all
              .map((c) => c.debt)
              .where((d) => d > 0)
              .fold<int>(0, (a, b) => a + b);
          final query = _search.text.trim().toLowerCase();
          final customers = all
              .where((c) =>
                  c.name.toLowerCase().contains(query) ||
                  c.phone.contains(query))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                color: scheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined,
                      color: scheme.onErrorContainer),
                  title: Text(l10n.totalOwedByCustomers,
                      style: TextStyle(color: scheme.onErrorContainer)),
                  trailing: Text(formatDAForUi(owed),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onErrorContainer)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: l10n.searchCustomer,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, customer) in customers.indexed) ...[
                      if (index > 0) const Divider(height: 1),
                      ListTile(
                        title: Text(customer.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          if (customer.phone.isNotEmpty) customer.phone,
                          if (customer.overLimit) l10n.overLimitBadge,
                        ].join(' · ')),
                        trailing: DebtText(debt: customer.debt),
                        onTap: () => _open('/customers/${customer.id}'),
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
