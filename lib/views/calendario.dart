import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datesync/model/calendarController.dart';

class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarView _actualView = CalendarView.week;
  CalendarController _calendarController = CalendarController();
  final CalendarControllerHelper _helper = CalendarControllerHelper();
  List<Map<String, dynamic>> taskData = [];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: Text('Agenda'),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text("No hay un usuario autenticado")),
      );
    }

    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tareas')
            .where('startTime', isNotEqualTo: null)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Appointment> appointments = [];
          taskData.clear();
          if (snapshot.hasData) {
            for (int index = 0; index < snapshot.data!.docs.length; index++) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              if (data['startTime'] != null && data['endTime'] != null) {
                taskData.add(data);
                appointments.add(
                  Appointment(
                    id: index.toString(),
                    startTime: (data['startTime'] as Timestamp).toDate(),
                    endTime: (data['endTime'] as Timestamp).toDate(),
                    subject: data['tarea'] ?? 'Sin título',
                    color: Color(data['color'] ?? Colors.blue.value),
                    recurrenceRule: data['recurrenceRule'],
                  ),
                );
              }
            }
          }

          return SfCalendar(
            controller: _calendarController,
            view: _actualView,
            initialDisplayDate: DateTime.now(),
            dataSource: MeetingDataSource(appointments),
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment) {
                int index = int.parse(details.appointments!.first.id);
                _helper.showEventDetails(context, taskData[index]);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _helper.showAddEventDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
