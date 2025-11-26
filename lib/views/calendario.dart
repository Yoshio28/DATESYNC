import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  List<Appointment> _appointments = getAppointments();
  CalendarView _actualView = CalendarView.week;
  CalendarController _calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String vista) {
              switch (vista) {
                case 'vista_diaria':
                  _calendarController.view = CalendarView.day;
                  break;
                case 'vista_semanal':
                  _calendarController.view = CalendarView.week;
                  break;
                case 'vista_mensual':
                  _calendarController.view = CalendarView.month;
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'vista_diaria',
                child: Text('vista diaria'),
              ),
              PopupMenuItem<String>(
                value: 'vista_semanal',
                child: Text('vista semanal'),
              ),
              PopupMenuItem<String>(
                value: 'vista_mensual',
                child: Text('vista mensual'),
              ),
            ],
          ),
        ],
      ),
      body: SfCalendar(
        controller: _calendarController,
        view: _actualView,
        initialDisplayDate: DateTime.now(),
        dataSource: MeetingDataSource(_appointments),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String subject = '';
    DateTime startTime = DateTime.now();
    DateTime endTime = DateTime.now().add(Duration(hours: 1));
    String recurrence = 'Evento unico';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Sprint a Asignar'),
                  onChanged: (value) => subject = value,
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startTime,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2080),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          startTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text('Inicio: ${startTime.toString()}'),
                ),

                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endTime,
                      firstDate: DateTime(20),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          endTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text('Fin: ${endTime.toString()}'),
                ),
                DropdownButton<String>(
                  value: recurrence,
                  items: ['Evento unico', 'Diaria', 'Semanal', 'Mensual'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => recurrence = value!),
                ),
                DropdownButton<Color>(
                  value: selectedColor,
                  items:
                      [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                      ].map((Color color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Container(width: 20, height: 20, color: color),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => selectedColor = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String? recurrenceRule;
                if (recurrence == 'Diaria')
                  recurrenceRule = 'FREQ=DAILY;COUNT=30';
                else if (recurrence == 'Semanal')
                  recurrenceRule = 'FREQ=WEEKLY;COUNT=4';
                else if (recurrence == 'Mensual')
                  recurrenceRule = 'FREQ=MONTHLY;COUNT=1';

                Appointment newAppointment = Appointment(
                  startTime: startTime,
                  endTime: endTime,
                  subject: subject,
                  color: selectedColor,
                  recurrenceRule: recurrenceRule,
                );

                setState(() {
                  _appointments.add(newAppointment);
                });

                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

// A mejorar
List<Appointment> getAppointments() {
  List<Appointment> meetings = <Appointment>[];
  final DateTime today = DateTime.now();
  final DateTime startTime = DateTime(
    today.year,
    today.month,
    today.day,
    9,
    0,
    0,
  );
  final DateTime endTime = startTime.add(const Duration(hours: 1));

  meetings.add(
    Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: 'Daily Meeting',
      color: Colors.blue,
      recurrenceRule: 'FREQ=DAILY;COUNT=30',
    ),
  );
  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
