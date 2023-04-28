package com.moko.bxp.button.d.flutter;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.moko.support.d.DMokoSupport;
import com.moko.support.d.MokoBleScanner;
import com.moko.support.d.OrderTaskAssembler;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        DMokoSupport mokoSupport = DMokoSupport.getInstance();
        mokoSupport.init(this.getApplicationContext());

        MokoBleScanner mokoBleScanner = new MokoBleScanner();
        mokoBleScanner.createEventChannel(flutterEngine);
        mokoBleScanner.createMethodChannel(flutterEngine);

        mokoSupport.createEventChannel(flutterEngine);
        mokoSupport.createMethodChannel(flutterEngine);

        OrderTaskAssembler orderTaskAssembler = new OrderTaskAssembler();
        orderTaskAssembler.createMethodChannel(flutterEngine);
    }
}
