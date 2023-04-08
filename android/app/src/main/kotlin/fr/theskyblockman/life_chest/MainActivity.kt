package fr.theskyblockman.life_chest

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager.LayoutParams
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel :MethodChannel? = null;


    override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(LayoutParams.FLAG_SECURE);
        super.onCreate(savedInstanceState)
        createNotificationChannel();
    }

    private fun createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.channel_name)
            val descriptionText = getString(R.string.channel_description)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel("theskyblockman.fr/notification_channel", name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,"theskyblockman.fr/channel")
        channel!!.setMethodCallHandler { call, result ->
            if (call.method == "createMediaNotification") {
                val builder = NotificationCompat.Builder(this, "theskyblockman.fr/notification_channel")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle("I love bananas!")
                    .setContentText("I really do like them!!!!!")
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                with(NotificationManagerCompat.from(this)) {
                    notify(0, builder.build())
                }
                result.success(true)
            }
        }
    }

    override fun onPause() {
        super.onPause()
        channel!!.invokeMethod("goBackToHome", null)
    }
}
