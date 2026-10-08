# Working rules for this project

The owner is a Flutter beginner: explain in simple words and short sentences.

## How we work
- Work phase by phase, following `PLAN.md`.
- After each phase:
  1. run `flutter analyze` (0 issues) and `flutter test` (all pass), and fix every error;
  2. commit with a clear message, then remind the owner to back up the
     code: `.\tool\backup_code.ps1` (a dated .zip copied to the USB stick
     or Google Drive folder they chose; it never contains keys or
     passwords);
  3. explain in simple words what to test on the phones or the emulator;
  4. **stop and wait** for the owner's OK before the next phase.

## Phones and data (very important)
- Never ask the owner to uninstall the app or wipe data to fix a problem.
- To update the phones, always use `adb install -r` (keeps the data).
  Never use `flutter install`: it uninstalls the app first and erases it.
  adb is at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`.
- The app ID is `dz.gestionboutique.pos` (name on the phone: "Gestion
  Boutique"). Commands (PowerShell, `$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"`):
  - list phones: `& $adb devices`
  - install or update: `& $adb -s PHONE_CODE install -r build\app\outputs\flutter-apk\app-release.apk`
  - start the app: `& $adb -s PHONE_CODE shell monkey -p dz.gestionboutique.pos -c android.intent.category.LAUNCHER 1`
  - stop it (to test a crash): `& $adb -s PHONE_CODE shell am force-stop dz.gestionboutique.pos`
  - The old test app `com.example.billing_app` (before the ID change) is
    a separate app. Its data does not move by itself: make a backup in
    it, then restore it on the first screen of the new app.
- Build release APKs with `.\tool\build_release.ps1` (not a plain
  `flutter build apk --release`). It signs the APK so it can update the
  apps already on the phones (key rotation from the old key to the
  release key). See "Release signing" in `PLAN.md`.
- ▶ Run in Android Studio (`flutter run`) is safe on a phone that has the
  app: every build (debug too) is signed with the release key and the
  rotation proof by `android/app/build.gradle.kts`, so Flutter never has
  to uninstall the app. Without `android/key.properties` a debug build
  stops on purpose (`-PallowOtherKey=true` only for a phone without the
  app).

## Tools
- Keep Java 21.
- Do not move the Flutter SDK: it stays in
  `C:\Users\Medvich\Desktop\new\flutter`.

## App rules
- Receipts are always in French. Currency is DA, written "1 250,00 DA".
- The app is in Arabic (right to left), French and English.
- Profit, buying prices and the total customer debt stay hidden from
  workers.

## Code and GitHub
- No GitHub and no remote: never push the code anywhere. The code is
  backed up with `.\tool\backup_code.ps1` only.

## Secrets
- Never commit keystores (`*.jks`, `*.keystore`), `key.properties`,
  passwords or shop secrets. They live in `C:\Users\Medvich\keys\`.
