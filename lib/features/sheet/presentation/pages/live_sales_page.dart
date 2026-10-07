import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/cloud_jobs.dart';
import '../../data/sheet_client.dart';
import 'sheet_page.dart';

/// Owner, away from the shop: today's sales of every phone, refreshed
/// every 30 seconds while the screen is open.
class LiveSalesPage extends StatefulWidget {
  const LiveSalesPage({super.key});

  @override
  State<LiveSalesPage> createState() => _LiveSalesPageState();
}

class _LiveSalesPageState extends State<LiveSalesPage> {
  static const every = Duration(seconds: 30);

  final _live = sl<CloudJobs>().live;
  late final Stream<List<LiveSaleRow>> _today = _live.watchToday();
  Timer? _timer;
  bool _checking = false;
  DateTime? _checkedAt;
  SheetError? _error;

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(every, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    SheetError? error;
    try {
      await _live.checkLocal();
      await _live.checkSheet();
    } on SheetException catch (e) {
      error = e.error;
    } catch (_) {
      error = SheetError.server;
    }
    try {
      await _live.announce();
    } catch (_) {
      // The list is shown anyway.
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _error = error;
      if (error == null) _checkedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveSalesTitle),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _checking ? null : _check,
            icon: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<List<LiveSaleRow>>(
        stream: _today,
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <LiveSaleRow>[];
          final sales = rows.where((r) => r.kind == 'sale').toList();
          final revenue = rows.fold(0, (sum, r) => sum + r.total);
          final perSeller = <String, (int, int)>{};
          for (final r in rows) {
            final (count, total) = perSeller[r.seller] ?? (0, 0);
            perSeller[r.seller] =
                (count + (r.kind == 'sale' ? 1 : 0), total + r.total);
          }
          final sellers = perSeller.entries.toList()
            ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.liveToday,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(formatDAForUi(revenue),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Text(l10n.liveSalesCount(sales.length)),
                      if (sellers.isNotEmpty) ...[
                        const Divider(height: 24),
                        for (final MapEntry(key: name, value: (count, total))
                            in sellers)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(children: [
                              Expanded(
                                  child: Text(name.isEmpty ? '—' : name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500))),
                              Text(l10n.liveSalesCount(count),
                                  style: TextStyle(
                                      color: scheme.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Text(formatDAForUi(total)),
                            ]),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  [
                    if (_checkedAt != null)
                      l10n.liveCheckedAt(formatTime(_checkedAt!)),
                    l10n.liveNote,
                  ].join('\n'),
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(sheetErrorText(l10n, _error!),
                      style: TextStyle(color: scheme.error)),
                ),
              if (rows.isEmpty)
                EmptyState(icon: Icons.bolt, title: l10n.liveEmpty)
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (final (i, row) in rows.indexed) ...[
                      if (i > 0) const Divider(height: 1),
                      _LiveTile(row: row),
                    ],
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LiveTile extends StatelessWidget {
  final LiveSaleRow row;
  const _LiveTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isReturn = row.kind == 'return';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isReturn ? scheme.errorContainer : scheme.primaryContainer,
        child: Icon(isReturn ? Icons.undo : Icons.shopping_bag_outlined,
            size: 20,
            color:
                isReturn ? scheme.onErrorContainer : scheme.onPrimaryContainer),
      ),
      title: Text(
          isReturn
              ? l10n.liveReturn(row.ticket)
              : l10n.liveSaleTicket(row.ticket),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${row.seller} · ${formatTime(row.at)}'),
      trailing: Text(formatDAForUi(row.total),
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isReturn ? scheme.error : null)),
    );
  }
}
