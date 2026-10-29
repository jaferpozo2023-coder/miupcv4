# Notificaciones push MI UPC

La app recibe FCM desde un servicio global. Con la app abierta muestra una tarjeta
institucional sobre la pantalla actual, reproduce `assets/audio/alerta.mp3` y
activa vibración. El usuario puede cerrar el aviso o abrir el mensaje. Si llega
`idDgoAlertasMovilCiu`, «Ver alerta» abre el módulo y carga ese identificador.
Las alertas ciudadanas permanecen hasta una acción; los avisos generales duran
12 segundos. Los avisos simultáneos se encolan y los mensajes FCM repetidos se
descartan durante la sesión.

Android usa `mi_upc_alertas_v2` en segundo plano y
`mi_upc_primer_plano_v2` en primer plano. Ambos tienen sonido personalizado y el
patrón de vibración `[0, 250, 120, 350]` en milisegundos. El segundo canal tiene
importancia normal para que la tarjeta de la app sea el único banner en pantalla.
El audio utiliza `USAGE_ALARM`. Se eleva temporalmente el volumen de alarma al
máximo y se restaura después de 8 segundos; el volumen multimedia no se cambia.
Se conserva un cambio de volumen que el usuario haga durante la reproducción.
El volumen anterior se guarda para restaurarlo al reabrir la app si el sistema
termina el proceso antes de la restauración.

El receptor nativo prepara el audio aunque Flutter no esté en ejecución. Para
mensajes `notification`, un servicio que hereda los callbacks de FlutterFire
selecciona el canal v2 antes de que Firebase publique el aviso automático,
incluso si el servidor indica un canal antiguo. Los mensajes solo `data` recibidos
sin actividad se publican desde Android; Dart no repite esa publicación.

En el menú lateral, **Sonido de alertas** muestra el estado de los permisos,
permite solicitar acceso a No molestar y ofrece **Probar sonido**. El acceso se
concede en los ajustes del sistema. Al volver a la app se actualiza `bypassDnd`.
La excepción del canal se aplica al modo prioritario de No molestar. Los modos
de bloqueo total, las políticas del dispositivo, los canales bloqueados y los
permisos revocados siguen bajo control del sistema.

El audio proporcionado dura aproximadamente 3,8 segundos. Android incluye una
copia exacta del MP3. iOS incluye el mismo audio convertido a WAV PCM de 16 bits,
estéreo, 22,05 kHz. Para sustituirlo se deben actualizar estos recursos:

- `assets/audio/alerta.mp3`
- `android/app/src/main/res/raw/alerta.mp3`
- `ios/Runner/alerta.wav`

Si se cambia el sonido o patrón en Android, usar una nueva versión del ID del
canal en el servicio, manifiesto y servidor: Android no permite cambiar estas
propiedades de un canal ya creado.

## Configuración del servidor FCM

El backend que envía las notificaciones no está incluido en este repositorio.
Para recibir avisos con sonido también con la app minimizada o cerrada, enviar
un mensaje FCM HTTP v1 con `notification`, prioridad alta en Android y el sonido
de APNs indicado a continuación:

```json
{
  "message": {
    "token": "TOKEN_DEL_DISPOSITIVO",
    "notification": {
      "title": "Nueva alerta ciudadana",
      "body": "Se ha registrado una alerta en su sector."
    },
    "data": {
      "idDgoAlertasMovilCiu": "123"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "mi_upc_alertas_v2",
        "sound": "alerta",
        "icon": "ic_notification",
        "color": "#195BA6"
      }
    },
    "apns": {
      "headers": {
        "apns-push-type": "alert",
        "apns-priority": "10"
      },
      "payload": {
        "aps": {
          "sound": "alerta.wav"
        }
      }
    }
  }
}
```

También se admiten mensajes `data` con `titulo`/`cuerpo` o `title`/`body`.
En segundo plano se genera una notificación local solamente si FCM no ha
incluido `notification`, para evitar avisos y sonidos duplicados. Android lo
realiza desde el receptor nativo e iOS desde el handler de Dart. Los mensajes
solo de datos dependen de las restricciones de entrega del sistema; para avisos
visibles con la app cerrada usar el ejemplo con `notification`.

En iOS se requiere la capacidad **Push Notifications** en el perfil de firma y
la clave APNs registrada en Firebase. El sonido está incluido en los recursos
del target Runner y `remote-notification` está habilitado en Info.plist.
El patrón de vibración de segundo plano lo controla iOS; en primer plano se
solicita también respuesta háptica cuando las notificaciones están autorizadas.

## Alertas críticas en iOS

La app aún no tiene confirmada la aprobación especial de Apple. La compilación
normal solicita alertas con sonido y reproduce `alerta.wav`, pero no puede
saltarse silencio, volumen bajo o Focus en segundo plano.

El código está preparado para alertas críticas con volumen `1.0`. Para activarlas
se requiere la aprobación de Apple, un perfil de firma con ese entitlement y la
autorización del usuario en el iPhone. Una vez disponibles:

1. Incorporar `com.apple.developer.usernotifications.critical-alerts = true` en
   `Runner.entitlements`; la plantilla `RunnerCriticalAlerts.entitlements.example`
   incluye esa configuración.
2. Compilar con `--dart-define=IOS_CRITICAL_ALERTS_ENABLED=true`.
3. Enviar desde APNs el objeto de sonido crítico (el backend no está en este repo):

```json
{
  "aps": {
    "sound": {"critical": 1, "name": "alerta.wav", "volume": 1.0},
    "interruption-level": "critical"
  }
}
```

El proyecto tiene **Push Notifications**, **Background Modes** y
`Runner.entitlements` configurados: APNs development para Debug y production
para Release/Profile. El entitlement crítico no se activa en la firma normal
para evitar una configuración que Apple aún no ha autorizado.

## Validación en dispositivo

Recompilar e instalar la app (hot reload no instala el recurso de sonido ni los
plugins). Autorizar las notificaciones y comprobar:

1. Con un formulario abierto, enviar el ejemplo: debe sonar y vibrar una vez,
   mostrar la tarjeta y mantener la pantalla hasta tocar «Ver alerta».
2. Minimizar la app y enviar otro aviso: debe aparecer la notificación del sistema
   con el tono MI UPC. Tocarla debe abrir el identificador recibido.
3. Cerrar la app normalmente y repetir; la navegación debe esperar a que finalice
   el splash. No usar «Forzar detención» de Android para esta comprobación.
4. Enviar dos alertas y verificar el contador y la siguiente tarjeta al cerrar.
5. En Android, abrir **Sonido de alertas**, permitir el acceso a No molestar y
   ejecutar **Probar sonido** con silencio y volumen de notificaciones bajo.
   Verificar que el volumen de alarma se eleva y vuelve a su valor anterior.
6. En iOS, eludir silencio y Focus solo se puede comprobar en un iPhone con la
   aprobación, el perfil y la autorización de alertas críticas activos.

No se puede garantizar la recepción con el dispositivo apagado, sin conexión,
con la app forzada a detenerse o con restricciones del fabricante. Los mensajes
solo de datos tampoco ofrecen la misma entrega en segundo plano que un aviso
visible del sistema.

## Comprobaciones realizadas

- Las 9 pruebas específicas de notificaciones pasan y los archivos nuevos no
  presentan incidencias en el analizador de Dart.
- El APK ARM64 compila y se instaló conservando los datos del Android conectado.
  El sistema muestra ambos canales v2 con `raw/alerta`, `USAGE_ALARM` y vibración.
  El acceso a No molestar todavía aparece sin conceder.
- iOS compila para simulador; `Runner.app` contiene el WAV idéntico al recurso.
  El Podfile corrige la ruta antigua de fuentes de `flutter_rotation_sensor`
  0.3.1, que impedía la compilación previa.
- La prueba audible en el Android quedó pendiente porque el teléfono estaba
  bloqueado. No había un iPhone conectado para una prueba física de APNs.
- La suite completa pasó 93 pruebas y conserva 4 fallos ajenos a estos cambios:
  uno del contrato de bandeja policial y tres que esperan el ambiente Desarrollo
  mientras la configuración actual usa Prueba.

Referencias: [recepción FCM en Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages),
[canales Android](https://developer.android.com/develop/ui/compose/notifications/channels)
y [flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications).
Las restricciones críticas están documentadas por [Apple](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions/criticalalert)
y el acceso prioritario por [Android](https://developer.android.com/reference/android/app/NotificationChannel#setBypassDnd(boolean)).
