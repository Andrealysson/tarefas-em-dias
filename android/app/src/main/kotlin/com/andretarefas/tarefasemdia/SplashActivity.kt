package com.andretarefas.tarefasemdia

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class SplashActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setTheme(R.style.LaunchTheme)

        val intent = Intent(this, MainActivity::class.java)
        startActivity(intent)
        finish()
    }
}
