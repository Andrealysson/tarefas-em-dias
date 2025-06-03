import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tarefas_em_dia/models/task.dart';

class CalendarScreen extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay) onDateSelected;
  final List<Task> tasks;

  const CalendarScreen({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDateSelected,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar data'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                onDateSelected(selectedDay);
                Navigator.of(context).pop();
              },
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                markersAlignment: Alignment.bottomCenter,
                markersMaxCount: 1,
              ),
              eventLoader: (day) {
                return tasks
                    .where(
                      (task) =>
                          task.createdAt.year == day.year &&
                          task.createdAt.month == day.month &&
                          task.createdAt.day == day.day,
                    )
                    .toList();
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox.shrink();

                  final hasCompleted = events.any(
                    (e) => (e as Task).isCompleted,
                  );
                  final hasPending = events.any(
                    (e) => !(e as Task).isCompleted,
                  );

                  Color color;
                  if (hasCompleted && hasPending) {
                    color = Colors.orange;
                  } else if (hasCompleted) {
                    color = Colors.green;
                  } else {
                    color = Colors.red;
                  }

                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
