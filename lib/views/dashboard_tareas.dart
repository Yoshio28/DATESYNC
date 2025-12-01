import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardTareas extends StatefulWidget {
  @override
  State<DashboardTareas> createState() => _DashboardTareasState();
}

class _DashboardTareasState extends State<DashboardTareas> {
  final List<String> asignados = ['Juan', 'María', 'Pedro'];
  final List<String> estados = ['Pendiente', 'En Progreso', 'Completado'];
  final List<String> prioridades = ['Alta', 'Media', 'Baja'];

  void updateEstado(String docId, String newEstado) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).update({
      'estado': newEstado,
    });
  }

  void updatePrioridad(String docId, String newPrioridad) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).update({
      'prioridad': newPrioridad,
    });
  }

  void _addNewTask(
    String tarea,
    String asignado,
    String estado,
    String prioridad,
    String descripcion,
    DateTime? startTime,
    DateTime? endTime,
  ) async {
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

  void _deleteTask(String docId) async {
    await FirebaseFirestore.instance.collection('tareas').doc(docId).delete();
  }

  void _editTask(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
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

  void _showTaskDetails(BuildContext context, Map<String, dynamic> data) {
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

  void _showAddTaskDialog(BuildContext context) {
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
                  // Selectores de fecha opcionales
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
                    _addNewTask(
                      tarea,
                      asignado,
                      estado,
                      prioridad,
                      descripcion,
                      startTime,
                      endTime,
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: Text('Sprints'),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade300, Colors.blue.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Text("No hay un usuario autenticado"),
        ),
      );
    }

    return Scaffold(
      drawer: Navbar(),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Sprints'),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tareas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay tareas registradas.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final tarea = data['tarea'] ?? 'Sin tarea';
              final asignado = data['asignado'] ?? 'Sin asignado';
              final estado = data['estado'] ?? 'Pendiente';
              final prioridad = data['prioridad'] ?? 'Media';

              Icon estadoIcon;
              switch (estado) {
                case 'Completado':
                  estadoIcon = Icon(Icons.check_circle, color: Colors.green);
                  break;
                case 'En Progreso':
                  estadoIcon = Icon(
                    Icons.hourglass_top,
                    color: const Color.fromARGB(255, 139, 155, 0),
                  );
                  break;
                default:
                  estadoIcon = Icon(Icons.cancel, color: Colors.red);
              }

              Icon prioridadIcon;
              switch (prioridad) {
                case 'Alta':
                  prioridadIcon = Icon(Icons.priority_high, color: Colors.red);
                  break;
                case 'Media':
                  prioridadIcon = Icon(
                    Icons.flag,
                    color: const Color.fromARGB(255, 189, 170, 1),
                  );
                  break;
                default:
                  prioridadIcon = Icon(Icons.low_priority, color: Colors.green);
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [estadoIcon, SizedBox(height: 4), prioridadIcon],
                  ),
                  title: Text('$tarea - $asignado'),
                  subtitle: Text('Estado: $estado | Prioridad: $prioridad'),
                  onTap: () => _showTaskDetails(context, data),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTask(context, doc.id, data),
                        tooltip: 'Editar tarea',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Eliminar Tarea'),
                              content: Text(
                                '¿Estás seguro de que quieres eliminar esta tarea?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteTask(doc.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Eliminar tarea',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
