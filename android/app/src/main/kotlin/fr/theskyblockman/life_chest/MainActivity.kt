package fr.theskyblockman.life_chest

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.view.WindowManager.LayoutParams

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(LayoutParams.FLAG_SECURE);
        super.onCreate(savedInstanceState)
    }
}
