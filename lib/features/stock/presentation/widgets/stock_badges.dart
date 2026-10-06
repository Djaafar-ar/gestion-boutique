import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_format.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/stock_batch.dart';

/// The shop's "expires soon" number of days (3 if not set yet).
int expiryWarnDaysOf(BuildContext context) {
  final state = context.watch<ShopBloc>().state;
  return state is ShopLoaded ? state.shop.expiryWarnDays : 3;
}

/// Small coloured label.
class InfoBadge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const InfoBadge(
      {super.key,
      required this.text,
      required this.background,
      required this.foreground,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: foreground)),
        ],
      ),
    );
  }
}

/// "Stock: 12", orange when low, red when empty or below zero.
class StockBadge extends StatelessWidget {
  final int quantity;
  final int lowThreshold;

  const StockBadge(
      {super.key, required this.quantity, required this.lowThreshold});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (quantity <= 0) {
      return InfoBadge(
        text: quantity == 0 ? l10n.outOfStock : l10n.stockLabel(quantity),
        icon: Icons.remove_shopping_cart_outlined,
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      );
    }
    final low = lowThreshold > 0 && quantity <= lowThreshold;
    return InfoBadge(
      text: l10n.stockLabel(quantity),
      icon: low ? Icons.trending_down : null,
      background: low ? _orange(context).$1 : scheme.secondaryContainer,
      foreground: low ? _orange(context).$2 : scheme.onSecondaryContainer,
    );
  }
}

/// Expiry date coloured green / orange (soon) / red (expired).
class ExpiryBadge extends StatelessWidget {
  final DateTime? expiry;

  /// Shows the words "Expired" / "Expires soon" instead of the date.
  final bool showWords;

  const ExpiryBadge({super.key, required this.expiry, this.showWords = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = expiryStatusOf(expiry, warnDays: expiryWarnDaysOf(context));
    if (status == ExpiryStatus.none) {
      return InfoBadge(
        text: l10n.noExpiry,
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      );
    }
    final date = l10n.expiresOn(formatDate(expiry!));
    return switch (status) {
      ExpiryStatus.expired => InfoBadge(
          text: showWords ? '${l10n.expiredBadge} · $date' : date,
          icon: Icons.error_outline,
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer),
      ExpiryStatus.soon => InfoBadge(
          text: showWords ? '${l10n.expiresSoonBadge} · $date' : date,
          icon: Icons.schedule,
          background: _orange(context).$1,
          foreground: _orange(context).$2),
      _ => InfoBadge(
          text: date,
          icon: Icons.event_available,
          background: _green(context).$1,
          foreground: _green(context).$2),
    };
  }
}

/// Orange and green that stay readable in light and dark mode.
(Color, Color) _orange(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? (const Color(0xFF5C3B00), const Color(0xFFFFDDB3))
        : (const Color(0xFFFFE0B2), const Color(0xFF6B3E00));

(Color, Color) _green(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? (const Color(0xFF1B4D2A), const Color(0xFFB7F0C4))
        : (const Color(0xFFD7F5DD), const Color(0xFF1B5E20));
