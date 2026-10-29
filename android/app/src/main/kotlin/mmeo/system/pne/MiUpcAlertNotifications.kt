package mmeo.system.pne

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject

/** Publicación inmediata desde FCM, sin esperar a Dart, red ni temporizadores. */
object MiUpcAlertNotifications {
    private val receivedIds = LinkedHashSet<String>()

    fun isApplicationForeground(context: Context): Boolean {
        if (context.getSystemService(KeyguardManager::class.java).isKeyguardLocked) return false
        return context.getSystemService(ActivityManager::class.java).runningAppProcesses
            ?.any { it.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND &&
                it.processName == context.packageName } == true
    }

    @Synchronized
    fun show(context: Context, message: RemoteMessage): Boolean {
        val startedAt = SystemClock.elapsedRealtime()
        val messageId = message.messageId
        if (messageId != null && receivedIds.contains(messageId)) return false
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return false
        fun text(value: String?) = value?.trim()?.takeIf { it.isNotEmpty() }
        val title = text(message.notification?.title) ?: text(message.data["titulo"])
            ?: text(message.data["title"]) ?: "MI UPC"
        val body = text(message.notification?.body) ?: text(message.data["cuerpo"])
            ?: text(message.data["body"]) ?: "Recibiste una nueva notificación."
        if (message.notification == null && listOf(
                "titulo", "title", "cuerpo", "body", "idDgoAlertasMovilCiu"
            ).none { !message.data[it].isNullOrBlank() }) return false

        val alertId = text(message.data["idDgoAlertasMovilCiu"])?.toIntOrNull()?.takeIf { it > 0 }
        val sentTime = message.sentTime.takeIf { it > 0 }?.toString() ?: "null"
        val key = messageId ?: "$sentTime|$title|$body|${alertId ?: "null"}"
        var id = 0
        key.forEach { id = (id * 31 + it.code) and 0x7fffffff }
        val payload = JSONObject().apply {
            put("title", title)
            put("body", body)
            put("notificationId", id)
            put("messageId", messageId ?: JSONObject.NULL)
            put("alertId", alertId ?: JSONObject.NULL)
        }.toString()
        // Formato del plugin local: gestiona tanto el toque como el arranque en frío.
        val launch = Intent(context, MainActivity::class.java)
            .setAction("SELECT_NOTIFICATION")
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra("notificationId", id)
            .putExtra("payload", payload)
        val contentIntent = PendingIntent.getActivity(
            context, id, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notification = NotificationCompat.Builder(context, MiUpcAlertAudio.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setColor(context.getColor(R.color.notification_color))
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            // Mismo tipo que en primer plano; evita la reducción por cooldown de avisos.
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
            .setVibrate(MiUpcAlertAudio.VIBRATION)
            .build()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            notification.sound = MiUpcAlertAudio.soundUri(context)
            notification.audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM).build()
        }

        // Elevar el volumen en el mismo recorrido que publica, no al recibir un broadcast previo.
        MiUpcAlertAudio.prepare(context)
        context.getSystemService(NotificationManager::class.java).notify(id, notification)
        if (messageId != null) {
            receivedIds.add(messageId)
            if (receivedIds.size > 100) receivedIds.remove(receivedIds.first())
        }
        Log.i("MiUpcPush", "Alerta publicada en ${SystemClock.elapsedRealtime() - startedAt} ms; " +
            "prioridad recibida=${message.priority}; edad del mensaje=" +
            (message.sentTime.takeIf { it > 0 }?.let { System.currentTimeMillis() - it } ?: -1) + " ms")
        return true
    }
}
