# covid_notify

Aplicación móvil que consulta datos de COVID-19 por país desde una API pública, los muestra en pantalla y envía una **notificación local** con el resumen.

Proyecto del taller *Consumo de API COVID y notificaciones locales* de la materia **Desarrollo móvil**.

<!--
Capturas de pantalla (descomenta estas líneas después de subir las imágenes a la carpeta screenshots/):

![Pantalla principal](screenshots/home.png)
![Notificación](screenshots/notificacion.png)
-->

## Funcionalidades

- Consulta la API pública [disease.sh](https://disease.sh) mediante peticiones HTTP (sin clave ni registro).
- Convierte el JSON de la respuesta en un modelo de Dart.
- Muestra los datos del país elegido: casos y muertes acumulados, casos y muertes del día, recuperados y fecha de actualización.
- Envía una notificación local con el resumen del país.
- Maneja los estados de carga y de error, con un botón **Reintentar**.

### Ampliaciones incluidas

- Bandera del país con `Image.network` (campo `countryInfo.flag`).
- Lista de países cargada desde la API (`/v3/covid-19/countries`), con una lista fija de respaldo si falla.
- Notificación expandida con `BigTextStyleInformation`.
- Fecha y números formateados con el paquete `intl`.
- Interfaz separada en widgets reutilizables (`DataCard`, `StatTile`).
- Diseño propio: fondo con degradado, colores por tipo de dato y mensaje de confirmación al notificar.

## Tecnologías

| Herramienta | Uso |
|---|---|
| Flutter (SDK 3.22 o superior) y Dart | Aplicación |
| [`http`](https://pub.dev/packages/http) `^1.2.0` | Peticiones HTTP |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) `^19.0.0` | Notificaciones locales |
| [`intl`](https://pub.dev/packages/intl) `^0.19.0` | Formato de fecha y números |
| API [disease.sh](https://disease.sh) | Datos de COVID-19 |

## Estructura del proyecto

```
lib/
├── main.dart                   # Interfaz principal, selector de país y botón de notificación
├── covid_data.dart             # Modelo CovidData (JSON a objeto Dart)
├── covid_api.dart              # Servicio HTTP: fetchCountry y fetchCountries
├── notification_service.dart   # Inicialización, permiso y envío de notificaciones
├── data_card.dart              # Widgets DataCard y StatTile, y formatos con intl
└── app_background.dart         # Fondo decorativo de la aplicación
```

El modelo y los servicios están separados de la interfaz.

## Requisitos previos

- Flutter SDK 3.22 o superior, con `flutter doctor` sin errores en la parte de Android.
- Android Studio o Visual Studio Code con las extensiones de Flutter y Dart.
- Un emulador Android (API 33 o superior) o un teléfono con depuración USB.
- Conexión a internet.

## Instalación y ejecución

1. Clona el repositorio:

   ```bash
   git clone https://github.com/ianguatame/Taller-Consumo-de-API.git
   cd Taller-Consumo-de-API
   ```

2. Instala las dependencias:

   ```bash
   flutter pub get
   ```

3. Abre un emulador Android (o conecta un teléfono) y verifica que Flutter lo detecte:

   ```bash
   flutter devices
   ```

4. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

   El primer build de Gradle puede tardar varios minutos.

> **Importante:** las versiones del `pubspec.yaml` deben quedar tal como están. No uses `flutter pub add flutter_local_notifications`, porque instalaría una versión más nueva del plugin con una API distinta a la de este código. Debe quedar en `^19.0.0`.

> Las notificaciones locales funcionan en Android. Si ejecutas la app en Chrome (web), los datos se muestran, pero la notificación no aparece.

## Configuración de Android

Estos cambios ya están hechos en el proyecto. Se documentan por si se necesita recrear la configuración.

### 1. Permisos (`android/app/src/main/AndroidManifest.xml`)

Dentro de `<manifest>` y antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

- `INTERNET` es necesario para que la app funcione en modo release.
- `POST_NOTIFICATIONS` es obligatorio desde Android 13.

### 2. Desugaring de Java (`android/app/build.gradle.kts`)

Dentro de los bloques que ya existen:

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## Cómo funciona

1. Al abrir la app, `main()` inicializa el servicio de notificaciones y pide el permiso al usuario (Android 13 o superior).
2. `HomePage` carga la lista de países desde la API y consulta los datos del país seleccionado con `fetchCountry`.
3. La respuesta JSON se convierte en un objeto `CovidData`.
4. La interfaz muestra la carga, el error o los datos, mediante un `FutureBuilder`.
5. Al pulsar **Enviar notificación**, `NotificationService.show` crea la notificación en el canal `covid_channel`, con el resumen del país y el detalle completo al desplegarla. El id de la notificación es fijo, así que cada una nueva reemplaza a la anterior.

## API utilizada

Endpoint por país:

```
https://disease.sh/v3/covid-19/countries/colombia
```

| Campo | Significado |
|---|---|
| `country` | Nombre del país |
| `cases` | Casos acumulados |
| `todayCases` | Casos del día |
| `deaths` | Muertes acumuladas |
| `todayDeaths` | Muertes del día |
| `recovered` | Recuperados acumulados |
| `updated` | Fecha de actualización (milisegundos desde 1970) |
| `countryInfo.flag` | URL de la bandera del país |

> Los datos de COVID-19 ya no se actualizan como antes. El campo `updated` puede mostrar una fecha reciente aunque las cifras sean históricas, porque el servidor renueva su caché. El objetivo del proyecto es el consumo de APIs, no mostrar cifras actuales.

## Pruebas

1. Al abrir la app debe aparecer el permiso de notificaciones. Aceptarlo.
2. Cambiar de país en el selector y verificar que los datos y la bandera cambian.
3. Pulsar **Enviar notificación** y revisar la notificación en la barra superior del dispositivo. Al desplegarla se ve el detalle completo.
4. Activar el modo avión, pulsar **Reintentar** y verificar que aparece el mensaje de error.

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| Error de compilación mencionando *desugaring* | No se habilitó `coreLibraryDesugaring` | Revisar la configuración de `build.gradle.kts` |
| Error de compilación en `initialize` o `show` | Plugin de notificaciones con versión mayor a 19 | Dejar `^19.0.0` en `pubspec.yaml` y ejecutar `flutter pub get` |
| Error por versiones de Java o Kotlin | Se reemplazó el bloque `compileOptions` completo | Conservar los valores originales y agregar solo `isCoreLibraryDesugaringEnabled = true` |
| La notificación no aparece | Permiso denegado, ausente, o app ejecutada en web | Revisar los ajustes de la app en el dispositivo y probar en Android |
| La app abre sin datos en release | Falta el permiso `INTERNET` | Revisar el `AndroidManifest.xml` |
| Error 404 al consultar | Nombre de país no reconocido por la API | Usar nombres en inglés (`Spain`, `USA`) |
| Pantalla en blanco al cargar | Excepción no mostrada | Revisar la consola de `flutter run` |

## Autor

Ian Guatame