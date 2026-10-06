import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

/// A sheet to pick a supplier, or create a new one.
Future<Supplier?> pickSupplier(BuildContext context) {
  return showModalBottomSheet<Supplier>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _SupplierPickerSheet(),
  );
}

class _SupplierPickerSheet extends StatefulWidget {
  const _SupplierPickerSheet();

  @override
  State<_SupplierPickerSheet> createState() => _SupplierPickerSheetState();
}

class _SupplierPickerSheetState extends State<_SupplierPickerSheet> {
  final _search = TextEditingController();
  final Future<List<Supplier>> _suppliers = sl<SupplierRepository>()
      .getSuppliers()
      .then((r) => r.getOrElse((_) => []));

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final created = await context.push<Supplier>('/suppliers/new');
    if (created != null && mounted) Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _search.text.trim().toLowerCase();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: l10n.searchSupplier,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: Text(l10n.newSupplier),
            onTap: _create,
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Supplier>>(
              future: _suppliers,
              builder: (context, snapshot) {
                final suppliers = (snapshot.data ?? [])
                    .where((s) => s.name.toLowerCase().contains(query))
                    .toList();
                return ListView.builder(
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text(supplier.name),
                      subtitle:
                          supplier.phone.isEmpty ? null : Text(supplier.phone),
                      onTap: () => Navigator.pop(context, supplier),
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
