import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/loss.dart';
import '../../domain/repositories/stock_repository.dart';
import 'record_loss_page.dart';

/// Recorded losses with the money lost. The owner sees everyone's,
/// a worker only their own.
class LossesPage extends StatefulWidget {
  const LossesPage({super.key});

  @override
  State<LossesPage> createState() => _LossesPageState();
}

class _LossesPageState extends State<LossesPage> {
  late Future<List<Loss>> _losses;

  @override
  void initState() {
    super.initState();
    _losses = _load();
  }

  Future<List<Loss>> _load() async {
    final session = context.read<SessionCubit>().state;
    final result = await sl<StockRepository>()
        .getLosses(userId: session.isOwner ? null : session.user?.id);
    return result.getOrElse((_) => []);
  }

  Future<void> _add() async {
    await context.push('/stock/loss');
    if (mounted) {
      setState(() {
        _losses = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lossesTitle)),
      body: FutureBuilder<List<Loss>>(
        future: _losses,
        builder: (context, snapshot) {
          final losses = snapshot.data;
          if (losses == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (losses.isEmpty) {
            return EmptyState(
                icon: Icons.inventory_outlined, title: l10n.lossesEmpty);
          }
          final total = losses.fold<int>(0, (sum, l) => sum + l.value);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                color: scheme.errorContainer,
                child: ListTile(
                  leading:
                      Icon(Icons.trending_down, color: scheme.onErrorContainer),
                  title: Text(l10n.lossesTotal(formatDAForUi(total)),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onErrorContainer)),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, loss) in losses.indexed) ...[
                      if (index > 0) const Divider(),
                      ListTile(
                        title: Text('${loss.quantity} × ${loss.productName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          loss.fromReturn
                              ? '${lossReasonLabel(l10n, loss.reason)} (${l10n.lossFromReturn})'
                              : lossReasonLabel(l10n, loss.reason),
                          if (loss.note != null) loss.note!,
                          '${loss.userName ?? l10n.unknownUser} · ${formatDateTime(loss.at)}',
                        ].join('\n')),
                        isThreeLine: true,
                        trailing: Text(formatDAForUi(loss.value),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.error)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.report_outlined),
        label: Text(l10n.recordLoss),
      ),
    );
  }
}
