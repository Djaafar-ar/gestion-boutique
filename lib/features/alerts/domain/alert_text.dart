import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/money.dart';
import 'alert.dart';

/// What an alert says, and which page it opens.
class AlertText {
  final String title;
  final String body;

  /// The page that deals with it.
  final String route;
  final IconData icon;

  /// Red for problems to fix now, orange for warnings, blue for news.
  final AlertLevel level;

  const AlertText(this.title, this.body, this.route, this.icon, this.level);
}

enum AlertLevel { urgent, warning, info }

/// The words for an alert, in the language of [l10n]. Used in the Alertes
/// tab and in phone notifications, so both always say the same thing.
AlertText describeAlert(
    AppLocalizations l10n, AlertType type, Map<String, dynamic> data) {
  String text(String key) => '${data[key] ?? '?'}';
  int number(String key) => (data[key] as num?)?.toInt() ?? 0;
  String amount(String key) => formatDAForUi(number(key));
  String date(String key) {
    final value = DateTime.tryParse(text(key));
    return value == null ? '?' : formatDate(value);
  }

  final productRoute = '/stock/product/${text('productId')}';
  switch (type) {
    case AlertType.lowStock:
      final quantity = number('quantity');
      if (quantity < 0) {
        return AlertText(
            l10n.alertNegativeStockTitle(text('product')),
            l10n.alertNegativeStockBody(-quantity),
            productRoute,
            Icons.remove_shopping_cart_outlined,
            AlertLevel.urgent);
      }
      if (quantity == 0) {
        return AlertText(
            l10n.alertOutOfStockTitle(text('product')),
            l10n.alertOutOfStockBody,
            productRoute,
            Icons.remove_shopping_cart_outlined,
            AlertLevel.urgent);
      }
      return AlertText(
          l10n.alertLowStockTitle(text('product')),
          l10n.alertLowStockBody(quantity, number('threshold')),
          productRoute,
          Icons.inventory_2_outlined,
          AlertLevel.warning);
    case AlertType.expiringSoon:
      return AlertText(
          l10n.alertExpiringTitle(text('product')),
          l10n.alertExpiringBody(number('remaining'), date('date')),
          productRoute,
          Icons.event_outlined,
          AlertLevel.warning);
    case AlertType.expired:
      return AlertText(
          l10n.alertExpiredTitle(text('product')),
          l10n.alertExpiredBody(number('remaining'), date('date')),
          productRoute,
          Icons.event_busy_outlined,
          AlertLevel.urgent);
    case AlertType.pendingPayment:
      return AlertText(
          l10n.alertPaymentTitle,
          l10n.alertPaymentBody(text('by'), amount('amount'), text('supplier')),
          '/payments',
          Icons.fact_check_outlined,
          AlertLevel.warning);
    case AlertType.newDelivery:
      return AlertText(
          l10n.alertDeliveryTitle,
          l10n.alertDeliveryBody(
              text('by'), number('quantity'), text('product')),
          productRoute,
          Icons.local_shipping_outlined,
          AlertLevel.info);
    case AlertType.overCreditLimit:
      return AlertText(
          l10n.alertCreditTitle(text('customer')),
          l10n.alertCreditBody(amount('debt'), amount('limit')),
          '/customers/${text('customerId')}',
          Icons.menu_book_outlined,
          AlertLevel.warning);
    case AlertType.failedLogins:
      return AlertText(
          l10n.alertPinTitle,
          l10n.alertPinBody(number('count'), text('name')),
          '/more/security',
          Icons.shield_outlined,
          AlertLevel.urgent);
    case AlertType.returnMade:
      final route = data['saleId'] == null
          ? '/sell/history'
          : '/sell/history/${text('saleId')}';
      return switch (data['kind']) {
        'exchange' => AlertText(
            l10n.alertExchangeTitle,
            l10n.alertExchangeBody(
                text('by'), amount('amount'), amount('taken')),
            route,
            Icons.swap_horiz,
            AlertLevel.info),
        'noReceipt' => AlertText(
            l10n.alertReturnTitle,
            l10n.alertReturnNoReceiptBody(text('by'), amount('amount')),
            route,
            Icons.assignment_return_outlined,
            AlertLevel.warning),
        _ => AlertText(
            l10n.alertReturnTitle,
            l10n.alertReturnBody(
                text('by'), number('number'), amount('amount')),
            route,
            Icons.assignment_return_outlined,
            AlertLevel.info),
      };
  }
}

/// The name of an alert type in the notification settings.
String alertTypeName(AppLocalizations l10n, AlertType type) => switch (type) {
      AlertType.lowStock => l10n.typeLowStock,
      AlertType.expiringSoon => l10n.typeExpiringSoon,
      AlertType.expired => l10n.typeExpired,
      AlertType.pendingPayment => l10n.pendingPaymentsTitle,
      AlertType.newDelivery => l10n.typeNewDelivery,
      AlertType.overCreditLimit => l10n.typeOverCreditLimit,
      AlertType.failedLogins => l10n.alertPinTitle,
      AlertType.returnMade => l10n.typeReturnMade,
    };
