# iOS

La compilación y firma nativas requieren macOS/Xcode. En Mac configure el Bundle Identifier en `ios/Runner.xcworkspace`, ejecute los generadores de icono/splash y use `flutter build ios` o `flutter run`. Para iPhone físico se necesita firma Apple; para distribución formal, cuenta Apple Developer. El simulador se administra desde Xcode.

Windows no puede compilar ni firmar iOS nativo. En Windows deje disponible la PWA: en iPhone abra Safari, use **Compartir → Agregar a pantalla de inicio**. Configure Railway con `--dart-define=API_BASE_URL=https://api.ejemplo.com/api`.
