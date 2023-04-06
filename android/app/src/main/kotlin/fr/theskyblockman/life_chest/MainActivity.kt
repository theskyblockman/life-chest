package fr.theskyblockman.life_chest

import android.os.Bundle
import android.view.WindowManager.LayoutParams
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(LayoutParams.FLAG_SECURE);
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "theskyblockman.fr/channel"
        ).setMethodCallHandler { call, result ->
            if (call.method == "createMediaNotification") {
                println("Sent the notification")
                val builder = NotificationCompat.Builder(this, "theskyblockman.fr/channel")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle("I love bananas!")
                    .setContentText("I really do like them!!!!!")
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                with(NotificationManagerCompat.from(this)) {
                    notify(0, builder.build());
                }
                result.success(true)
            }
        }
    }
}
