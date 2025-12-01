import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarControllerHelper {
  void showEventDetails(BuildContext context, Map<String, dynamic> data) {
    final tarea = data['tarea'] ?? 'Sin tarea';
    final asignado = data['asignado'] ?? 'Sin asignado';
    final estado = data['estado'] ?? 'Pendiente';
    final prioridad = data['prioridad'] ?? 'Media';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final startTime = data['startTime'] != null
        ? (data['startTime'] as Timestamp).toDate()
        : null;
    final endTime = data['endTime'] != null
        ? (data['endTime'] as Timestamp).toDate()
        : null;
    final recurrenceRule = data['recurrenceRule'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Evento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tarea: $tarea',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Descripción: $descripcion'),
              SizedBox(height: 8),
              Text('Asignado: $asignado'),
              SizedBox(height: 8),
              Text('Estado: $estado'),
              SizedBox(height: 8),
              Text('Prioridad: $prioridad'),
              if (startTime != null) ...[
                SizedBox(height: 8),
                Text('Inicio: $startTime'),
              ],
              if (endTime != null) ...[
                SizedBox(height: 8),
                Text('Fin: $endTime'),
              ],
              if (recurrenceRule != null) ...[
                SizedBox(height: 8),
                Text('Recurrencia: $recurrenceRule'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> addEvent({
    required String subject,
    required DateTime startTime,
    required DateTime endTime,
    required Color color,
    String? recurrenceRule,
  }) async {
    await FirebaseFirestore.instance.collection('tareas').add({
      'tarea': subject,
      'startTime': startTime,
      'endTime': endTime,
      'color': color.value,
      'recurrenceRule': recurrenceRule,
      'estado': 'Pendiente',
      'prioridad': 'Media',
      'asignado': 'Usuario',
      'descripcion': '',
      'creado': DateTime.now(),
    });
  }

  void showAddEventDialog(BuildContext context) {
    String subject = '';
    DateTime startTime = DateTime.now();
    DateTime endTime = DateTime.now().add(Duration(hours: 1));
    String recurrence = 'Evento unico';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
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
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
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
                        firstDate: DateTime(2020),
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
                    items: ['Evento unico', 'Diaria', 'Semanal', 'Mensual'].map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
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
                            child: Container(
                              width: 20,
                              height: 20,
                              color: color,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedColor = value!),
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
                onPressed: () async {
                  String? recurrenceRule;
                  if (recurrence == 'Diaria')
                    recurrenceRule = 'FREQ=DAILY;COUNT=30';
                  else if (recurrence == 'Semanal')
                    recurrenceRule = 'FREQ=WEEKLY;COUNT=4';
                  else if (recurrence == 'Mensual')
                    recurrenceRule = 'FREQ=MONTHLY;COUNT=1';

                  await addEvent(
                    subject: subject,
                    startTime: startTime,
                    endTime: endTime,
                    color: selectedColor,
                    recurrenceRule: recurrenceRule,
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Agregar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
