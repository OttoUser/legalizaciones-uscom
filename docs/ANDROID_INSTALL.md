# Android

Use `flutter run --dart-define=API_BASE_URL=https://api.ejemplo.com/api` para desarrollo. Compile con `flutter build apk --release --dart-define=API_BASE_URL=https://api.ejemplo.com/api`. Con USB/depuración activa use `flutter install`.

Para instalación manual, copie `build/app/outputs/flutter-apk/app-release.apk`, permita instalación desde fuentes externas cuando Android lo solicite e instale. En emulador, ejecute `flutter run`. Tras `flutter pub get`, ejecute `dart run flutter_launcher_icons` y `dart run flutter_native_splash:create`.
