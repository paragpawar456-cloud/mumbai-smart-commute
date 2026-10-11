# Setup

Everything here is free. No credit card is needed at any step.

## 1. Tools on your laptop

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable 3.47.x) and Android Studio with the Flutter plugin.
2. Clone the repo, then `flutter pub get`.
3. `cp config/dev.example.json config/dev.json`. Fill it in after steps 2 and 3.

## 2. Firebase Authentication (Spark plan)

1. [console.firebase.google.com](https://console.firebase.google.com) → **Add project** (Google Analytics optional). Stay on the **Spark** plan.
2. **Build → Authentication → Get started → Sign-in method**: enable **Email/Password** and **Google**.
3. **Project settings → General → Your apps → Add app → Android**, package name `com.mumbaismartcommute.mumbai_smart_commute`. Download `google-services.json` (do **not** commit it) and copy these values into `config/dev.json`:

| config/dev.json | google-services.json |
|---|---|
| `FIREBASE_API_KEY` | `client[0].api_key[0].current_key` |
| `FIREBASE_APP_ID` | `client[0].client_info.mobilesdk_app_id` |
| `FIREBASE_PROJECT_ID` | `project_info.project_id` |
| `FIREBASE_MESSAGING_SENDER_ID` | `project_info.project_number` |

4. For Google sign-in, add your signing SHA-1 under the Android app in Project settings (`cd android && ./gradlew signingReport`).
5. Under **Project settings → General**, copy the **Web API Key**. The backend needs it in step 3.

## 3. Google Sheet + Apps Script backend

1. Create a new Google Sheet named `Mumbai Smart Commute DB`. Keep it private: never share it or publish it.
2. **Extensions → Apps Script**. Create one script file per `.gs` file in `backend/apps-script/` with the same names (`Code`, `Auth`, `Db`, `Guard`, `Validate`, `Handlers`, `Schema`) and paste the contents. Open **Project Settings → Show "appsscript.json"**, then paste `backend/apps-script/appsscript.json`.
   (Alternatively, use [clasp](https://github.com/google/clasp): `clasp clone <scriptId>` into `backend/apps-script`, then `clasp push`.)
3. **Project Settings → Script properties → Add**: `FIREBASE_WEB_API_KEY` = the Web API Key from step 2.5.
4. In the editor, pick `setupSheets` and click **Run**, then approve the permissions. All tabs appear in the Sheet.
5. **Deploy → New deployment → Web app**: *Execute as* **Me**, *Who has access* **Anyone**. Copy the `/exec` URL into `BACKEND_URL` in `config/dev.json`.
6. Each time you change the code: **Deploy → Manage deployments → Edit → Version: New version** (keeps the same URL).
7. Make yourself an admin: sign in to the app once, then in the `Users` tab change your row's `role` to `admin`. The server only trusts this column, never the app.

Check it works: open the app, go to **Profile**, and **Server status** should say *Connected*.

## 4. Run and build

```bash
flutter run --dart-define-from-file=config/dev.json            # on a phone or emulator
flutter test && (cd backend && npm test)                         # tests
flutter build apk --release --split-per-abi --dart-define-from-file=config/prod.json
# output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (most phones)
```

### The free APK from GitHub

Every push to `main` runs **Actions → CI** and attaches `mumbai-smart-commute-apk`. To bake your config into that APK, add a repository secret `APP_CONFIG_JSON` containing the whole `config/prod.json`.

### Same signature for every build (so testers can update)

```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias msc
base64 -w0 release.jks    # paste into secret ANDROID_KEYSTORE_BASE64
```

Add secrets `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`msc`) and `ANDROID_KEY_PASSWORD`. For local builds, put the file at `android/app/release.jks` and create `android/key.properties`:

```
storeFile=release.jks
storePassword=...
keyAlias=msc
keyPassword=...
```

Back up the keystore. If you lose it, testers must uninstall before installing a new build.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Profile says "Server not configured" | `BACKEND_URL` empty, or you ran without `--dart-define-from-file` |
| Server status "Could not reach the server" | Deployment access must be **Anyone**; redeploy a new version after code edits |
| Sign-in "not configured" | One of the four `FIREBASE_*` values is empty |
| Every private call fails with `unauthenticated` | `FIREBASE_WEB_API_KEY` script property missing or from another project |
| `Missing tab ...; run setupSheets()` | Run `setupSheets` once from the Apps Script editor |
| Google sign-in fails on device | Add the SHA-1 of the key that signed the APK in Firebase |
