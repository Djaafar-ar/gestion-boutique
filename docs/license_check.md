# License check: what is left from the original project

The project started from **Dinesh-Sowndar/flutter_billing_app** (first
commit `b66f634`, 2026-10-05). That repository has **no LICENSE file**.
Without a license, the author keeps all rights: we may not legally copy,
change or share their code. To be free to use, sell or publish the app,
every part written by that author must be rewritten by us.

Measured on 2026-10-08 with `git blame -w -M -C` (it follows lines that
were moved or copied), not counting generated files and translations.

## How much is left

| Part | Lines still from the original | Of all lines |
|---|---|---|
| App code (`lib/`) | about **2 660** | 28 400 (**about 9 %**) |
| Platform/template files (`android/`, `ios/`, `web/`, `.metadata`, `analysis_options.yaml`, `.gitignore`, `pubspec.yaml`) | about 1 750 | most of these files |
| `README.md` | 101 | all of it |
| Images | Android, iOS and web app icons, launch images | all unchanged |

Many of the 2 660 lines are very small (imports, brackets, one-line
calls) that any Flutter app has. The real original work is concentrated
in these files:

| File | Original lines / total |
|---|---|
| `lib/features/billing/presentation/pages/home_page.dart` (Caisse screen) | 308 / 476 |
| `lib/features/shop/presentation/pages/shop_details_page.dart` | 147 / 251 |
| `lib/features/product/presentation/pages/product_list_page.dart` | 129 / 303 |
| `lib/features/settings/presentation/bloc/printer_bloc.dart` | 123 / 132 |
| `lib/core/utils/printer_helper.dart` | 103 / 124 |
| `lib/features/billing/presentation/pages/checkout_page.dart` | 99 / 701 |
| `lib/features/billing/presentation/bloc/billing_bloc.dart` | 76 / 178 |
| `lib/features/product/presentation/bloc/product_bloc.dart` | 73 / 90 |
| `lib/features/billing/presentation/pages/scanner_page.dart` | 72 / 89 |
| `lib/features/product/presentation/pages/add_product_page.dart` | 70 / 131 |
| `lib/features/product/data/repositories/product_repository_impl.dart` | 65 / 256 |
| `lib/core/service_locator.dart` | 62 / 258 |
| `lib/features/product/domain/usecases/product_usecases.dart` | 57 / 60 |
| `lib/features/product/presentation/pages/edit_product_page.dart` | 54 / 88 |
| `lib/features/settings/presentation/bloc/printer_state.dart`, `printer_event.dart`, `printer_repository*.dart` | about 140 |
| `lib/features/shop/presentation/bloc/*`, `shop/domain/*` | about 150 |
| `lib/features/product/presentation/bloc/product_event.dart`, `product_state.dart` | 57 / 83 |
| `lib/core/theme/app_theme.dart`, `core/widgets/primary_button.dart`, `input_label.dart`, `core/utils/app_validators.dart`, `core/error/failure.dart`, `core/usecase/usecase.dart` | about 120 |
| `lib/main.dart`, `config/routes/app_routes.dart` | about 80 |
| `lib/core/database/hive_importer.dart` (reads the old app's data format) | 49 / 257 |

Everything else (database, stock, sales saving, users and PINs,
suppliers, customers, returns, alerts, statistics, Wi-Fi sync, Google
Sheet, backups, the Bluetooth scanner, all the tests) was written in
this project.

## Plan to replace it (not done yet)

1. **Templates and images (easy, low risk).** Create a fresh empty app
   with `flutter create` (Flutter's own templates are BSD licensed, not
   the author's), copy its `ios/`, `web/` and launcher icons, keep our
   `android/` changes (key rotation, permissions, Kotlin scanner), and
   make our own app icon. Remove `ios/` and `web/` completely if the app
   stays Android only.
2. **README.** Write a new one from PLAN.md.
3. **Screens, one at a time, with the tests as a safety net:** rewrite
   from our own description, without looking at the old code line by line:
   - Caisse (`home_page.dart`) and the camera scanner page;
   - product list, add and edit product pages;
   - shop details page;
   - checkout page (the remaining original parts).
4. **Logic:** new BLoCs for products, cart (billing), shop and printer;
   new printer helper (it uses the `print_bluetooth_thermal` package,
   which has its own license); simpler product repository and use cases;
   small shared widgets, theme, validators.
5. **Hive importer:** it only reads the old app's file format once. After
   the last phone has updated, remove it together with the `hive`
   packages (already planned in Phase 9).
6. **Check again** with the same `git blame` command: the goal is 0
   original lines (except trivial ones like `import` lines), then add our
   own LICENSE file.

Rough size: about 2 700 lines to rewrite, mostly screens. It fits in
Phase 9 next to the printer work, because the printer and Caisse screens
change there anyway.
