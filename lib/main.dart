import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'tarefas_channel',
        channelName: 'Tarefas Pendentes',
        channelDescription: 'Notificações para lembrar tarefas não concluídas',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
