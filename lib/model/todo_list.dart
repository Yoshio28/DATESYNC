import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskController {
  final List<String> asignados = ['Juan', 'María', 'Pedro'];
  final List<String> estados = ['Pendiente', 'En Progreso', 'Completado'];
  final List<String> prioridades = ['Alta', 'Media', 'Baja'];

  Future<void> updateEstado(String docId, String newEstado) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).update({
      'estado': newEstado,
    });
  }

  Future<void> updatePrioridad(String docId, String newPrioridad) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).update({
      'prioridad': newPrioridad,
    });
  }

  Future<void> addNewTask({
    required String tarea,
    required String asignado,
    required String estado,
    required String prioridad,
    required String descripcion,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await FirebaseFirestore.instance.collection('tareas').add({
      'tarea': tarea,
      'asignado': asignado,
      'estado': estado,
      'prioridad': prioridad,
      'descripcion': descripcion,
      'startTime': startTime,
      'endTime': endTime,
      'creado': DateTime.now(),
    });
  }

  Future<void> deleteTask(String docId) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).delete();
  }

  void editTask(BuildContext context, String docId, Map<String, dynamic> data) {
    String tarea = data['tarea'] ?? '';
    String asignado = data['asignado'] ?? asignados[0];
    String estado = data['estado'] ?? estados[0];
    String prioridad = data['prioridad'] ?? prioridades[0];
    String descripcion = data['descripcion'] ?? '';
    DateTime? startTime = data['startTime'] != null
        ? (data['startTime'] as Timestamp).toDate()
        : null;
    DateTime? endTime = data['endTime'] != null
        ? (data['endTime'] as Timestamp).toDate()
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Editar Tarea'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tarea'),
                    controller: TextEditingController(text: tarea),
                    onChanged: (value) => tarea = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    controller: TextEditingController(text: descripcion),
                    onChanged: (value) => descripcion = value,
                    maxLines: 3,
                  ),
                  DropdownButton<String>(
                    value: asignado,
                    items: asignados.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => asignado = value!),
                  ),
                  DropdownButton<String>(
                    value: estado,
                    items: estados.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => estado = value!),
                  ),
                  DropdownButton<String>(
                    value: prioridad,
                    items: prioridades.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => prioridad = value!),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startTime ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            startTime ?? DateTime.now(),
                          ),
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
                    child: Text(
                      'Inicio (opcional): ${startTime?.toString() ?? 'No asignado'}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endTime ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            endTime ?? DateTime.now(),
                          ),
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
                    child: Text(
                      'Fin (opcional): ${endTime?.toString() ?? 'No asignado'}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (tarea.isNotEmpty) {
                    FirebaseFirestore.instance
                        .collection('tareas')
                        .doc(docId)
                        .update({
                          'tarea': tarea,
                          'asignado': asignado,
                          'estado': estado,
                          'prioridad': prioridad,
                          'descripcion': descripcion,
                          'startTime': startTime,
                          'endTime': endTime,
                        });
                    Navigator.pop(context);
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showTaskDetails(BuildContext context, Map<String, dynamic> data) {
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Tarea'),
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

  void showAddTaskDialog(BuildContext context) {
    String tarea = '';
    String descripcion = '';
    String asignado = asignados[0];
    String estado = estados[0];
    String prioridad = prioridades[0];
    DateTime? startTime;
    DateTime? endTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Agregar Tarea'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tarea'),
                    onChanged: (value) => tarea = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    onChanged: (value) => descripcion = value,
                    maxLines: 3,
                  ),
                  DropdownButton<String>(
                    value: asignado,
                    items: asignados.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => asignado = value!),
                  ),
                  DropdownButton<String>(
                    value: estado,
                    items: estados.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => estado = value!),
                  ),
                  DropdownButton<String>(
                    value: prioridad,
                    items: prioridades.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => prioridad = value!),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()),
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
                    child: Text(
                      'Inicio (opcional): ${startTime?.toString() ?? 'No asignado'}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()),
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
                    child: Text(
                      'Fin (opcional): ${endTime?.toString() ?? 'No asignado'}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (tarea.isNotEmpty) {
                    addNewTask(
                      tarea: tarea,
                      asignado: asignado,
                      estado: estado,
                      prioridad: prioridad,
                      descripcion: descripcion,
                      startTime: startTime,
                      endTime: endTime,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Agregar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Icon getEstadoIcon(String estado) {
    switch (estado) {
      case 'Completado':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'En Progreso':
        return Icon(
          Icons.hourglass_top,
          color: const Color.fromARGB(255, 139, 155, 0),
        );
      default:
        return Icon(Icons.cancel, color: Colors.red);
    }
  }

  Icon getPrioridadIcon(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return Icon(Icons.priority_high, color: Colors.red);
      case 'Media':
        return Icon(Icons.flag, color: const Color.fromARGB(255, 189, 170, 1));
      default:
        return Icon(Icons.low_priority, color: Colors.green);
    }
  }
}
