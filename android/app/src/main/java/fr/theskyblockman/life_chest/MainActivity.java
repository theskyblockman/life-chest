package fr.theskyblockman.life_chest;

import static android.app.PendingIntent.*;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.ryanheise.audioservice.AudioServiceActivity;

import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends AudioServiceActivity {
    private MethodChannel channel;
    public static FlutterEngine engine;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
        super.onCreate(savedInstanceState);
    }

    @Override
    @SuppressWarnings("unchecked")
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        engine = flutterEngine;
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),"theskyblockman.fr/channel");

        channel.setMethodCallHandler((call, result) -> {
            if(Objects.equals(call.method, "sendVaultNotification")) {
                Map<String, String> args = (Map<String, String>) call.arguments;
                Intent tapIntent = new Intent(this, VaultCloseBroadcastReceiver.class);
                PendingIntent pendingTapIntent = getBroadcast(this, 0, tapIntent, FLAG_IMMUTABLE);
                NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "theskyblockman.fr/notification_channel")
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(args.get("notification_title"))
                        .setContentText(args.get("notification_content"))
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .addAction(R.mipmap.ic_launcher, args.get("notification_close_button_content"), pendingTapIntent);

                NotificationManagerCompat.from(this).notify(1, builder.build());
                result.success(true);
            }
        });
    }

    @Override
    protected void onPause() {
        channel.invokeMethod("goBackToHome", null);
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        NotificationManagerCompat.from(this).cancel(1);
    }
}