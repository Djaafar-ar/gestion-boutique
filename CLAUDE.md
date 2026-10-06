# Working rules for this project

The owner is a Flutter beginner: explain in simple words and short sentences.

## How we work
- Work phase by phase, following `PLAN.md`.
- After each phase:
  1. run `flutter analyze` (0 issues) and `flutter test` (all pass), and fix every error;
  2. commit with a clear message;
  3. explain in simple words what to test on the phones or the emulator;
  4. **stop and wait** for the owner's OK before the next phase.

## Phones and data (very important)
- Never ask the owner to uninstall the app or wipe data to fix a problem.
- To update the phones, always use `adb install -r` (keeps the data).
  Never use `flutter install`: it uninstalls the app first and erases it.
  adb is at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`.
- Build release APKs with `.\tool\build_release.ps1` (not a plain
  `flutter build apk --release`). It signs the APK so it can update the
  apps already on the phones (key rotation from the old key to the
  release key). See "Release signing" in `PLAN.md`.

## Tools
- Keep Java 21.
- Do not move the Flutter SDK: it stays in
  `C:\Users\Medvich\Desktop\new\flutter`.

## App rules
- Receipts are always in French. Currency is DA, written "1 250,00 DA".
- The app is in Arabic (right to left), French and English.
- Profit, buying prices and the total customer debt stay hidden from
  workers.

## Secrets
- Never commit keystores (`*.jks`, `*.keystore`), `key.properties`,
  passwords or shop secrets. They live in `C:\Users\Medvich\keys\`.
