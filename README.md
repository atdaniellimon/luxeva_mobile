# LUXEVA Private Wealth — Mobile (iOS & Android)

Aplicación móvil nativa en **Flutter** con diseño ultralujoso **Cupertino / Apple Human Interface Guidelines**, concebida para la banca privada y custodia institucional de **LUXEVA**.

---

## 🏛️ Filosofía de Diseño & Experiencia Nativa

- **Paleta Obsidian & Champagne Gold**:
  - `Obsidian Deep Background`: `#09090B`
  - `Card / Container Elevated`: `#131317` & `#18181E`
  - `Champagne Gold & Warm Accents`: `#CBBD93`, `#DFD4B3`, `#A69668`
  - `Borders`: Acabados sutiles dorados y microbordes de vidrio con desenfoque `BackdropFilter`.
- **Sensaciones Táctiles Hísticas**: `HapticFeedback.lightImpact()` y `mediumImpact()` en cada interacción (copiado de CLABE, pulsación de tarjetas, confirmación de transferencias).
- **Widgets Cupertino Nativos**: Modales `CupertinoActionSheet`, navegación de pestañas `CupertinoTabScaffold`, diálogos `CupertinoAlertDialog`, y controles `CupertinoSegmentedControl`.
- **Estructura Financiera**:
  - **Bóveda (Bóveda Privada)**: Tarjeta metálica grabada con chip EMV, saldo en tiempo real, movimientos y accesos rápidos.
  - **Patrimonio**: Desglose consolidado de liquidez inmediata, pagaré institucional a tasa TIIE+ y metales asignados.
  - **Fondear (SPEI Instantáneo)**: Cuenta CLABE Spin by OXXO (`728969000044989306`) a nombre de **Luxeva**, píldoras rápidas de importe, concepto dinámico y clave de rastreo Banxico.
  - **Dispersión SPEI**: Transferencias inmediatas hacia cualquier banco de México con validación de saldo.
  - **Bitácora**: Auditoría contable completa con filtrado por tipo de movimiento y desglose formal de comprobante.
  - **Titular**: Oficialía de cuenta, seguridad biométrica (Face ID / Touch ID) y cierre de sesión seguro.

---

## ⚡ Conexión con el Backend

La aplicación se comunica de forma predeterminada con:
- **Producción**: `https://luxeva.daniellimon.uk`
- **Fallback**: `http://api.luxeva.daniellimon.uk` o local `http://127.0.0.1:8000`

Mantiene sesiones encriptadas y persistentes localmente mediante `SharedPreferences`.

---

## ☁️ Compilación Automatizada en la Nube (GitHub Actions)

No necesitas instalar gigabytes de SDKs (Flutter, Xcode o Android Studio) en tu Mac ni consumir batería ni espacio en disco.

Cada vez que haces un `git push` a `main`, el flujo `.github/workflows/build.yml` compila automáticamente en los servidores de GitHub:

1. **Android**: Runner `ubuntu-latest` genera el archivo `app-release.apk`.
2. **iOS**: Runner `macos-14` con Apple Silicon compila y empaqueta el archivo `Luxeva-Release.ipa`.

### ¿Cómo descargar los ejecutables?
1. Ve a tu repositorio en GitHub: `https://github.com/<tu-usuario>/luxeva_mobile`
2. Haz clic en la pestaña **Actions**.
3. Selecciona la ejecución del último commit ("Build Luxeva Mobile").
4. Al final de la página, en la sección **Artifacts**, encontrarás:
   - 📦 `Luxeva-Android-Release-APK`
   - 🍏 `Luxeva-iOS-Release-IPA`

---

## 📲 Instalación en Dispositivos

### En iPhone (iOS):
- Descarga el archivo `Luxeva-Release.ipa`.
- Instálalo directamente utilizando:
  - **Sideloadly** o **AltStore** (gratis con tu Apple ID personal).
  - **TrollStore** (si tu versión de iOS lo soporta).
  - O mediante **Xcode > Devices & Simulators** si tienes cuenta de desarrollador.

### En Android:
- Descarga `app-release.apk`.
- Pásalo a tu teléfono o descárgalo directo desde Chrome en tu Android e instálalo permitiendo la instalación de fuentes desconocidas.

---

## 🚀 Subir cambios a GitHub

```bash
git add .
git commit -m "feat: native luxury cupertino app with cloud build workflow"
git push origin main
```
