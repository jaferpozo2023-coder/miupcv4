package mmeo.system.pne

import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        @Volatile var isVisible = false
            private set
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MiUpcAlertAudio.configure(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mi_upc/alert_audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "configure" -> {
                        // El aviso debe pasar por el servicio que ajusta el audio,
                        // incluso si una instalación previa habilitó el proxy de Play services.
                        try {
                            FirebaseMessaging.getInstance().setNotificationDelegationEnabled(false)
                                .addOnCompleteListener { task ->
                                    if (task.isSuccessful) result.success(null)
                                    else result.error("DELEGATION", "No se pudo configurar la recepción directa", null)
                                }
                        } catch (error: Exception) {
                            result.error("DELEGATION", "No se pudo configurar la recepción directa", null)
                        }
                    }
                    "prepare" -> {
                        MiUpcAlertAudio.prepare(this)
                        result.success(null)
                    }
                    "status" -> result.success(MiUpcAlertAudio.status(this))
                    else -> result.notImplemented()
                }
            }
    }

    override fun onResume() {
        super.onResume()
        isVisible = true
        MiUpcAlertAudio.configure(this)
    }

    override fun onPause() {
        isVisible = false
        super.onPause()
    }
}
