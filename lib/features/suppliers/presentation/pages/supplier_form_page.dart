import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

/// Add or edit a supplier. Closes with the saved [Supplier], so a
/// delivery can use a supplier created on the spot.
class SupplierFormPage extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormPage({super.key, this.supplier});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.supplier?.name);
  late final _phone = TextEditingController(text: widget.supplier?.phone);
  late final _note = TextEditingController(text: widget.supplier?.note);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final result = await sl<SupplierRepository>().saveSupplier(
      id: widget.supplier?.id,
      name: _name.text,
      phone: _phone.text,
      note: _note.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (supplier) {
        showAppSnack(context, l10n.savedLabel, kind: SnackKind.success);
        context.pop(supplier);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.supplier == null ? l10n.newSupplier : l10n.editSupplier)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputLabel(text: l10n.nameLabel),
            TextFormField(
              controller: _name,
              autofocus: widget.supplier == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: l10n.supplierNameHint),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 20),
            InputLabel(text: l10n.phoneOptionalLabel),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: l10n.phoneHint),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _save,
        isLoading: _saving,
        icon: Icons.check,
        label: l10n.commonSave,
      ),
    );
  }
}
