package com.myn.math_game

import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Kol žaidimas atidarytas, telefono ŠONINIAI garsumo mygtukai visada valdo
    // MEDIJOS (žaidimo) garsumą — net tyloje tarp garsų. Be šios eilutės Android
    // tyloje keičia SKAMBUČIO garsumą, ne žaidimo. iOS šito nereikia (ten audio
    // sesija „ambient" tai tvarko pati) — todėl tai teisinga Android pusė, ne lopas.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        volumeControlStream = AudioManager.STREAM_MUSIC
    }
}
