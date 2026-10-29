package mmeo.system.pne

import android.content.Intent
import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/** Conserva los callbacks de FlutterFire y muestra avisos en el hilo de FCM. */
class MiUpcFirebaseMessagingService : FlutterFirebaseMessagingService() {
    override fun handleIntent(intent: Intent) {
        val extras = intent.extras
        val message = if (extras == null) null else RemoteMessage(extras)
        if (message?.notification != null &&
            !MiUpcAlertNotifications.isApplicationForeground(this)) {
            try {
                MiUpcAlertNotifications.show(this, message)
                // FCM sigue confirmando/registrando el mensaje, sin un segundo aviso
                // automático ni descarga de imágenes antes de publicar la alerta.
                intent.putExtra("gcm.n.noui", "1")
            } catch (error: Exception) {
                Log.e("MiUpcPush", "Falló la publicación nativa; se usa el aviso de FCM", error)
                intent.putExtra("gcm.n.android_channel_id", MiUpcAlertAudio.CHANNEL_ID)
                intent.putExtra("gcm.n.sound2", "alerta")
            }
        }
        super.handleIntent(intent)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        if (message.notification == null &&
            !MiUpcAlertNotifications.isApplicationForeground(this)) {
            try {
                MiUpcAlertNotifications.show(this, message)
            } catch (error: Exception) {
                Log.e("MiUpcPush", "No se pudo publicar la alerta de datos", error)
            }
        }
    }
}
