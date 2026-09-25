# Luxeva Mobile (Cupertino Native)

Aplicación móvil nativa de ultra-lujo para **Luxeva Private Banking**, desarrollada en **Flutter** con el sistema de diseño nativo **Apple Cupertino**, paleta negro obsidiana (`#09090B`) y oro champán (`#CBBD93`).

---

## Características Principales

- **Diseño Nativo iOS Cupertino**:
  - `CupertinoApp`, `CupertinoTabBar`, `CupertinoNavigationBar`, `CupertinoTextField`.
  - Tarjeta física digital de tungsteno con chip metálico, brillos y CVV dinámico.
  - Soporte háptico (`HapticFeedback`) al interactuar, cambiar de pestaña o copiar datos SPEI.
  - Integración con **Face ID / Touch ID** (`local_auth`).
- **Motor Bancario Oficial**:
  - Consulta en tiempo real de saldo institucional y bitácora de operaciones vía `https://luxeva.daniellimon.uk`.
  - Fondeo SPEI oficial Banxico con Spin by OXXO (CLABE `7289 6900 0044 9893 06` y concepto dinámico `LX-XXXXXX`).
  - Transferencias de capital interbancarias inmediatas.
- **Compilación en la Nube con GitHub Actions**:
  - Compilación automática de **iOS (.ipa)** en macOS runner.
  - Compilación automática de **Android (.apk)** en Ubuntu runner.
  - Descargables listos en la pestaña de *Actions* o *Releases* con cada commit a `main`.

---

## Estructura del Código

- `lib/theme/luxeva_theme.dart`: Paleta de colores, decoraciones vítreas y estilos de texto.
- `lib/models/models.dart`: Modelos tipados de `UserSession`, `TransactionItem` y `SpeiDetails`.
- `lib/services/api_service.dart`: Conexión de red resiliente, biometría y persistencia.
- `lib/widgets/luxury_card.dart`: Tarjeta metálica con chip y token de seguridad.
- `lib/screens/login_screen.dart`: Acceso al Club Privado con Face ID.
- `lib/screens/signup_screen.dart`: Apertura de cuenta digital.
- `lib/screens/home_vault_screen.dart`: Bóveda principal con patrimonio líquido y bitácora.
- `lib/screens/deposit_screen.dart`: Acreditación de capital SPEI Banxico.
- `lib/screens/transfer_screen.dart`: Dispersión de fondos.
- `lib/screens/cards_screen.dart`: Gestión de instrumentos y bloqueo preventivo.
- `lib/screens/account_screen.dart`: Titular acreditado y cierre de sesión.
- `.github/workflows/build.yml`: Pipeline de CI/CD para compilación de binarios.
