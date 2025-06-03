import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas_em_dia/models/task.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tarefas_em_dia/widgets/task_tile.dart';
import 'package:tarefas_em_dia/screens/calendar_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _loadTasks().then((_) {
      _verificarETocarNotificacao();
    });
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _verificarETocarNotificacao() {
    final pendentes = _tasks.where((t) => !t.isCompleted).toList();

    if (pendentes.isNotEmpty) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'tarefas_channel',
          title: 'Você tem tarefas pendentes',
          body: 'Não se esqueça de concluir suas tarefas de hoje!',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }
  }

  String _formatarDataCompleta(DateTime data) {
    const diasSemana = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];

    final nomeDia = diasSemana[data.weekday % 7];
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    return '$nomeDia, $dia/$mes/$ano';
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('taskList', jsonEncode(taskList));
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('taskList');
    if (data != null) {
      final decoded = jsonDecode(data) as List<dynamic>;
      setState(() {
        _tasks.clear();
        _tasks.addAll(decoded.map((e) => Task.fromJson(e)));
      });
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      return task.createdAt.year == day.year &&
          task.createdAt.month == day.month &&
          task.createdAt.day == day.day;
    }).toList();
  }

  void _addTask() {
    final text = _taskController.text;
    if (text.isNotEmpty) {
      final task = Task(title: text, createdAt: _selectedDay ?? DateTime.now());
      setState(() {
        _tasks.add(task);
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _editTask(BuildContext context, Task taskToEdit) {
    final controller = TextEditingController(text: taskToEdit.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Digite o novo texto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final int taskIndex = _tasks.indexOf(taskToEdit);
              if (taskIndex != -1) {
                setState(() {
                  _tasks[taskIndex] = Task(
                    title: controller.text,
                    isCompleted: taskToEdit.isCompleted,
                    createdAt: taskToEdit.createdAt,
                  );
                });
                _saveTasks();
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removeTask(Task taskToRemove) {
    setState(() {
      _tasks.remove(taskToRemove);
    });
    _saveTasks();
  }

  void _toggleComplete(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveTasks();
  }

  void _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalendarScreen(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          onDateSelected: (selectedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = selectedDay;
            });
          },
          tasks: _tasks,
        ),
      ),
    );

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _selectDate(context);
                          },
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Selecionar Data',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8), // espaço entre botão e texto

                      // Agora o texto usa só o espaço que sobrar
                      Flexible(
                        child: Text(
                          _selectedDay != null
                              ? _formatarDataCompleta(_selectedDay!)
                              : 'Nenhuma data',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            hintText: 'Adicione uma nova tarefa',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount:
                        _getTasksForDay(_selectedDay ?? DateTime.now()).length,
                    itemBuilder: (context, index) {
                      final task = _getTasksForDay(
                        _selectedDay ?? DateTime.now(),
                      )[index];
                      return TaskTile(
                        task: task,
                        onDelete: () => _removeTask(task),
                        onToggleComplete: () => _toggleComplete(task),
                        onEdit: () => _editTask(context, task),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
