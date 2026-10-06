import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import 'debt_text.dart';

/// A sheet to pick a customer by name or phone, or create a new one.
Future<Customer?> pickCustomer(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CustomerPickerSheet(),
  );
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet();

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _search = TextEditingController();
  final Future<List<Customer>> _customers = sl<CustomerRepository>()
      .getCustomers()
      .then((r) => r.getOrElse((_) => []));

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final created = await context.push<Customer>('/customers/new');
    if (created != null && mounted) Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _search.text.trim().toLowerCase();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: l10n.searchCustomer,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: Text(l10n.newCustomer),
            onTap: _create,
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: _customers,
              builder: (context, snapshot) {
                final customers = (snapshot.data ?? [])
                    .where((c) =>
                        c.name.toLowerCase().contains(query) ||
                        c.phone.contains(query))
                    .toList();
                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle:
                          customer.phone.isEmpty ? null : Text(customer.phone),
                      trailing: DebtText(debt: customer.debt),
                      onTap: () => Navigator.pop(context, customer),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
