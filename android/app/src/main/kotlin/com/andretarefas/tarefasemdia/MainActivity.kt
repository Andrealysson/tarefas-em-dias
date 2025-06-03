package com.andretarefas.tarefasemdia

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Força a splash a permanecer visível por 1.5 segundos antes de renderizar o Flutter
        Handler(Looper.getMainLooper()).postDelayed({
            // Aqui poderia iniciar algo, mas como FlutterActivity já gerencia, apenas aguardamos
        }, 1500)
    }
}
