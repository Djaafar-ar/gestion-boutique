import java.io.FileInputStream
import java.util.Properties

// Release signing key: android/key.properties (never committed). Without
// it, release builds fall back to the debug key, and debug builds stop
// (see "Same key for every build" below).
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dz.gestionboutique.pos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Needed by the notifications plugin (scheduled expiry reminders).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dz.gestionboutique.pos"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        // ▶ Run in Android Studio (flutter run) installs a debug build over
        // the app on the phone: it gets the release key too.
        debug {
            if (keyPropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        release {
            // tool/build_release.ps1 then adds the key rotation proof, so
            // the APK also updates the apps already installed on the phones.
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// ---------------------------------------------------------------------
// Same key for every build.
//
// Android only updates an app with an APK signed by the same key. When
// the key differs, "flutter run" (the ▶ Run button) uninstalls the app
// first, which ERASES the shop's data. So every APK (debug, profile,
// release) is signed like tool/build_release.ps1 does: with the release
// key plus the rotation proof (lineage) from the old key the phones first
// knew. The passwords are passed to apksigner through the environment,
// never on the command line.
// ---------------------------------------------------------------------

/** apksigner of the newest build-tools of the Android SDK. */
fun findApksigner(): File {
    val tools = File(android.sdkDirectory, "build-tools").listFiles()
        ?.filter { it.isDirectory }
        ?.maxWithOrNull(compareBy<File>(
            { it.name.split('.').getOrNull(0)?.toIntOrNull() ?: 0 },
            { it.name.split('.').getOrNull(1)?.toIntOrNull() ?: 0 },
            { it.name.split('.').getOrNull(2)?.toIntOrNull() ?: 0 }))
        ?: throw GradleException("Android build-tools not found.")
    val windows = System.getProperty("os.name").lowercase().contains("windows")
    return File(tools, if (windows) "apksigner.bat" else "apksigner")
}

fun signWithRotation(apk: File) {
    val p = keyProperties
    for (key in listOf("oldStoreFile", "oldKeyAlias", "oldPassword", "lineageFile")) {
        if (p.getProperty(key) == null) {
            throw GradleException("android/key.properties: $key is missing.")
        }
    }
    val signed = File(apk.parentFile, apk.nameWithoutExtension + "-rotated.apk")
    val command = mutableListOf<String>()
    val apksigner = findApksigner()
    if (apksigner.name.endsWith(".bat")) command += listOf("cmd", "/c")
    command += listOf(
        apksigner.absolutePath, "sign",
        "--ks", p.getProperty("oldStoreFile"), "--ks-key-alias", p.getProperty("oldKeyAlias"),
        "--ks-pass", "env:GB_OLD_PASS", "--key-pass", "env:GB_OLD_PASS",
        "--next-signer",
        "--ks", p.getProperty("storeFile"), "--ks-key-alias", p.getProperty("keyAlias"),
        "--ks-pass", "env:GB_STORE_PASS", "--key-pass", "env:GB_KEY_PASS",
        "--lineage", p.getProperty("lineageFile"),
        "--rotation-min-sdk-version", "28",
        "--v4-signing-enabled", "false",
        "--out", signed.absolutePath, apk.absolutePath,
    )
    val process = ProcessBuilder(command).redirectErrorStream(true).apply {
        environment()["GB_OLD_PASS"] = p.getProperty("oldPassword")
        environment()["GB_STORE_PASS"] = p.getProperty("storePassword")
        environment()["GB_KEY_PASS"] = p.getProperty("keyPassword")
    }.start()
    val output = process.inputStream.bufferedReader().readText()
    if (process.waitFor() != 0) {
        signed.delete()
        throw GradleException("apksigner failed:\n$output")
    }
    if (!apk.delete() || !signed.renameTo(apk)) {
        throw GradleException("Cannot replace ${apk.name} with the signed APK.")
    }
}

tasks.configureEach {
    if (name == "packageDebug" || name == "packageProfile" || name == "packageRelease") {
        doFirst {
            // Never install a debug build signed with another key: Flutter
            // would erase the app on the phone to put it in place.
            if (!keyPropertiesFile.exists() && name != "packageRelease" &&
                project.findProperty("allowOtherKey") != "true") {
                throw GradleException(
                    "android/key.properties is missing: this build would be signed with " +
                        "another key, and ▶ Run would ERASE the app's data on the phone. " +
                        "Put the release key back (see PLAN.md, Release signing), or build " +
                        "with -PallowOtherKey=true for a phone without the app.")
            }
        }
        doLast {
            if (!keyPropertiesFile.exists()) return@doLast
            outputs.files.asFileTree.matching { include("**/*.apk") }.forEach(::signWithRotation)
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
