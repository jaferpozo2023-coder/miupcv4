package mmeo.system.pne

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import kotlin.math.max

/** Prepara el sonido del sistema incluso cuando no existe un motor Flutter. */
object MiUpcAlertAudio {
    const val CHANNEL_ID = "mi_upc_alertas_v2"
    val VIBRATION = longArrayOf(0, 250, 120, 350)
    private val handler = Handler(Looper.getMainLooper())
    private var restore: Runnable? = null
    private const val PREFS = "mi_upc_alert_audio"
    // Incluye margen para la publicación de FCM y los 3,8 s del archivo.
    const val RESTORE_DELAY_MS = 8000L

    fun soundUri(context: Context): Uri =
        Uri.parse("android.resource://${context.packageName}/raw/alerta")

    fun configure(context: Context) {
        restoreStaleVolume(context)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(NotificationManager::class.java)
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        val channel = existing ?: NotificationChannel(
            CHANNEL_ID,
            "Alertas prioritarias MI UPC",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Alerta sonora MI UPC con volumen de alarma y vibración."
            setSound(soundUri(context), attributes)
            enableVibration(true)
            vibrationPattern = VIBRATION
        }
        // Se puede actualizar tras conceder acceso si el usuario no lo ha editado.
        if (manager.isNotificationPolicyAccessGranted) channel.setBypassDnd(true)
        manager.createNotificationChannel(channel)
    }

    @Synchronized
    fun prepare(context: Context) {
        configure(context)
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return
        val app = context.applicationContext
        val audio = app.getSystemService(AudioManager::class.java)
        if (audio.isVolumeFixed) return
        val prefs = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val previous = prefs.getInt("previousVolume", -1)
        val original = if (previous >= 0) previous else audio.getStreamVolume(AudioManager.STREAM_ALARM)
        val maximum = audio.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        try {
            prefs.edit()
                .putInt("previousVolume", original)
                .putInt("raisedVolume", max(1, maximum))
                .putLong("restoreAt", System.currentTimeMillis() + RESTORE_DELAY_MS)
                .apply()
            audio.setStreamVolume(AudioManager.STREAM_ALARM, max(1, maximum), 0)
            restore?.let { handler.removeCallbacks(it) }
            restore = Runnable { restoreVolume(app) }.also {
                handler.postDelayed(it, RESTORE_DELAY_MS)
            }
        } catch (error: SecurityException) {
            Log.w("MiUpcAlertAudio", "El sistema no permite ajustar el volumen de alarma", error)
            prefs.edit().clear().apply()
        }
    }

    private fun restoreStaleVolume(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val deadline = prefs.getLong("restoreAt", 0)
        if (deadline > 0 && System.currentTimeMillis() >= deadline) restoreVolume(context)
    }

    @Synchronized
    private fun restoreVolume(context: Context) {
        val audio = context.getSystemService(AudioManager::class.java)
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val original = prefs.getInt("previousVolume", -1)
        val raised = prefs.getInt("raisedVolume", -1)
        try {
            // Conservar un ajuste que el usuario haya hecho durante la reproducción.
            if (original >= 0 && audio.getStreamVolume(AudioManager.STREAM_ALARM) == raised) {
                audio.setStreamVolume(AudioManager.STREAM_ALARM, original, 0)
            }
        } catch (error: SecurityException) {
            Log.w("MiUpcAlertAudio", "No se pudo restaurar el volumen de alarma", error)
        } finally {
            prefs.edit().clear().apply()
            restore = null
        }
    }

    fun status(context: Context): Map<String, Boolean> {
        configure(context)
        val manager = context.getSystemService(NotificationManager::class.java)
        val channel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            manager.getNotificationChannel(CHANNEL_ID) else null
        return mapOf(
            "notificationsEnabled" to NotificationManagerCompat.from(context).areNotificationsEnabled(),
            "policyAccess" to manager.isNotificationPolicyAccessGranted,
            "bypassDnd" to (channel?.canBypassDnd() ?: false),
            "channelEnabled" to (channel == null || channel.importance != NotificationManager.IMPORTANCE_NONE),
            "soundEnabled" to (channel == null || channel.sound != null),
            "volumeFixed" to context.getSystemService(AudioManager::class.java).isVolumeFixed
        )
    }
}
