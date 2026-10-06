import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../domain/entities/loss.dart';
import '../../domain/entities/stock_batch.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/stock_math.dart';
import '../widgets/product_picker.dart';
import '../widgets/stock_badges.dart';

String lossReasonLabel(AppLocalizations l10n, LossReason reason) =>
    switch (reason) {
      LossReason.damaged => l10n.reasonDamaged,
      LossReason.expired => l10n.reasonExpired,
      LossReason.staff => l10n.reasonStaff,
      LossReason.stolen => l10n.reasonStolen,
      LossReason.other => l10n.reasonOther,
    };

/// "Déclarer une perte": damaged, expired, eaten by staff, stolen...
/// The items leave the stock and the money lost (at buying price) is shown.
class RecordLossPage extends StatefulWidget {
  final String? productId;

  const RecordLossPage({super.key, this.productId});

  @override
  State<RecordLossPage> createState() => _RecordLossPageState();
}

class _RecordLossPageState extends State<RecordLossPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1');
  final _note = TextEditingController();
  Product? _product;
  List<StockBatch> _batches = [];
  LossReason _reason = LossReason.damaged;

  /// Chosen batch, or null for "the one that expires first".
  String? _batchId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final id = widget.productId;
    if (id != null) {
      _choose(context
          .read<ProductBloc>()
          .state
          .products
          .where((p) => p.id == id)
          .firstOrNull);
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _choose(Product? product) async {
    if (product == null) return;
    setState(() {
      _product = product;
      _batches = [];
      _batchId = null;
    });
    final result = await sl<StockRepository>().getBatches(product.id);
    if (!mounted) return;
    setState(() {
      _batches = result
          .map((r) => r.batches.where((b) => b.remaining > 0).toList())
          .getOrElse((_) => []);
      _selectExpiredBatch();
    });
  }

  /// For "expired", the batch that is already out of date is chosen.
  void _selectExpiredBatch() {
    if (_reason != LossReason.expired) return;
    final expired = _batches
        .where((b) =>
            expiryStatusOf(b.expiryDate, warnDays: 0) == ExpiryStatus.expired)
        .firstOrNull;
    if (expired != null) _batchId = expired.deliveryId;
  }

  int get _quantityValue => int.tryParse(_quantity.text) ?? 0;

  int get _stock => _batches.fold(0, (sum, b) => sum + b.remaining);

  /// Money lost if saved now, with the same rule as the real save.
  int get _estimatedValue {
    final product = _product;
    if (product == null || _quantityValue <= 0) return 0;
    final plan = planTakeOut(BatchState(_batches, 0), _quantityValue,
        preferred: _batchId, fallbackCost: product.buyPrice);
    return averageCost(plan) * _quantityValue;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final product = _product;
    if (product == null) {
      showAppSnack(context, l10n.chooseProduct, kind: SnackKind.error);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final result = await sl<StockRepository>().recordLoss(
      productId: product.id,
      quantity: _quantityValue,
      reason: _reason,
      note: _note.text,
      deliveryId: _batchId,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (loss) {
        context.read<ProductBloc>().add(LoadProducts());
        showAppSnack(context, l10n.lossSaved(formatDA(loss.value)),
            kind: SnackKind.success);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final product = _product;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordLoss)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputLabel(text: l10n.columnProduct),
            Card(
              child: ListTile(
                leading:
                    Icon(Icons.inventory_2_outlined, color: scheme.primary),
                title: Text(product?.name ?? l10n.chooseProduct,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: product == null
                    ? null
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: StockBadge(
                            quantity: _stock,
                            lowThreshold: product.lowStockThreshold)),
                trailing: const Icon(Icons.search),
                onTap: () async => _choose(await pickProduct(context)),
              ),
            ),
            const SizedBox(height: 20),
            InputLabel(text: l10n.lossReasonLabel),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reason in LossReason.values)
                  ChoiceChip(
                    label: Text(lossReasonLabel(l10n, reason)),
                    selected: _reason == reason,
                    onSelected: (_) => setState(() {
                      _reason = reason;
                      _selectExpiredBatch();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            InputLabel(text: l10n.quantityLabel),
            TextFormField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                  ? l10n.quantityRequired
                  : null,
            ),
            if (product != null && _quantityValue > _stock)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.moreThanStock(_stock),
                    style: TextStyle(color: scheme.error, fontSize: 12)),
              ),
            if (_batches.length > 1) ...[
              const SizedBox(height: 20),
              InputLabel(text: l10n.lossBatchLabel),
              DropdownButtonFormField<String?>(
                key: ValueKey('batch-$_batchId-${_batches.length}'),
                initialValue: _batchId,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(l10n.lossBatchAuto)),
                  for (final batch in _batches)
                    DropdownMenuItem(
                      value: batch.deliveryId,
                      child: Text(batch.expiryDate == null
                          ? l10n.batchOptionNoDate(
                              formatDate(batch.receivedAt), batch.remaining)
                          : l10n.batchOption(
                              formatDate(batch.expiryDate!), batch.remaining)),
                    ),
                ],
                onChanged: (value) => setState(() => _batchId = value),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
            ),
            const SizedBox(height: 20),
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.lossValuePreview(formatDAForUi(_estimatedValue)),
                  style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _save,
        isLoading: _saving,
        icon: Icons.report_outlined,
        label: l10n.saveLoss,
      ),
    );
  }
}
