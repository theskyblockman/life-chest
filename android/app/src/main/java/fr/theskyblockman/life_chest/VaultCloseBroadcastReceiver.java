package fr.theskyblockman.life_chest;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.core.app.NotificationManagerCompat;

import io.flutter.plugin.common.MethodChannel;

public class VaultCloseBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        MethodChannel channel = new MethodChannel(MainActivity.engine.getDartExecutor().getBinaryMessenger(),"theskyblockman.fr/channel");
        channel.invokeMethod("closeVault", null);
        NotificationManagerCompat.from(context).cancel(1);
    }
}
