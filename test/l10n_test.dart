import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/features/settings/presentation/cubit/app_preferences_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<(String, TextDirection)> render(
      WidgetTester tester, Locale locale) async {
    late String label;
    late TextDirection direction;
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        label = AppLocalizations.of(context).navSell;
        direction = Directionality.of(context);
        return const SizedBox();
      }),
    ));
    return (label, direction);
  }

  testWidgets('Arabic is written right-to-left', (tester) async {
    final (label, direction) = await render(tester, const Locale('ar'));
    expect(label, 'بيع');
    expect(direction, TextDirection.rtl);
  });

  testWidgets('French and English are left-to-right', (tester) async {
    expect(await render(tester, const Locale('fr')),
        ('Vendre', TextDirection.ltr));
    expect(
        await render(tester, const Locale('en')), ('Sell', TextDirection.ltr));
  });

  test('"follow the phone" falls back to French for other languages', () {
    const supported = [Locale('fr'), Locale('ar'), Locale('en')];
    expect(resolveAppLocale(const Locale('ar', 'DZ'), supported),
        const Locale('ar'));
    expect(resolveAppLocale(const Locale('de'), supported), const Locale('fr'));
    expect(resolveAppLocale(null, supported), const Locale('fr'));
  });
}
