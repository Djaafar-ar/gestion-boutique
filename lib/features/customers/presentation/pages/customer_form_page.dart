import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

/// Add or edit a customer. Closes with the saved [Customer], so the
/// checkout can use a customer created on the spot.
class CustomerFormPage extends StatefulWidget {
  final Customer? customer;

  const CustomerFormPage({super.key, this.customer});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.customer?.name);
  late final _phone = TextEditingController(text: widget.customer?.phone);
  late final _note = TextEditingController(text: widget.customer?.note);
  late final _limit = TextEditingController(
      text: widget.customer?.creditLimit == null
          ? ''
          : centimesToInput(widget.customer!.creditLimit!));
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final result = await sl<CustomerRepository>().saveCustomer(
      id: widget.customer?.id,
      name: _name.text,
      phone: _phone.text,
      note: _note.text,
      creditLimit: _limit.text.trim().isEmpty ? null : parseDA(_limit.text),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (customer) {
        showAppSnack(context, l10n.savedLabel, kind: SnackKind.success);
        context.pop(customer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwner = context.watch<SessionCubit>().state.isOwner;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.customer == null ? l10n.newCustomer : l10n.editCustomer)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputLabel(text: l10n.nameLabel),
            TextFormField(
              controller: _name,
              autofocus: widget.customer == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: l10n.customerNameHint),
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
            InputLabel(text: l10n.creditLimitLabel),
            TextFormField(
              controller: _limit,
              enabled: isOwner,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0,00',
                suffixText: 'DA',
                helperText:
                    isOwner ? l10n.creditLimitHelp : l10n.creditLimitOwnerOnly,
              ),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                final value = parseDA(v);
                return value == null || value < 0 ? l10n.amountInvalid : null;
              },
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
