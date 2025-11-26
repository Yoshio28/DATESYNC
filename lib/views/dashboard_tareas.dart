// dashboard_tareas.dart
import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:datesync/model/todo_list.dart';

class DashboardTareas extends StatefulWidget {
  @override
  State<DashboardTareas> createState() => _DashboardTareasState();
}

class _DashboardTareasState extends State<DashboardTareas> {
  List<List<String>> toDoList = [
    ['Design UI', 'Juan', 'Pendiente', 'Alta'],
    ['Centro de pagos', 'María', 'En Progreso', 'Media'],
    ['Validaciones de identidad', 'Pedro', 'Completado', 'Baja'],
  ];

  final List<String> asignados = ['Juan', 'María', 'Pedro'];
  final List<String> estados = ['Pendiente', 'En Progreso', 'Completado'];
  final List<String> prioridades = ['Alta', 'Media', 'Baja'];

  void updateEstado(int index, String newEstado) {
    setState(() {
      toDoList[index][2] = newEstado;
    });
  }

  void updatePrioridad(int index, String newPrioridad) {
    setState(() {
      toDoList[index][3] = newPrioridad;
    });
  }

  void _addNewTask(
    String tarea,
    String asignado,
    String estado,
    String prioridad,
  ) {
    setState(() {
      toDoList.add([tarea, asignado, estado, prioridad]);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    String tarea = '';
    String asignado = asignados[0];
    String estado = estados[0];
    String prioridad = prioridades[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Tarea'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Tarea'),
                  onChanged: (value) => tarea = value,
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
                  _addNewTask(tarea, asignado, estado, prioridad);
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Sprints'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (BuildContext context, index) {
          return TodoList(
            tarea: toDoList[index][0],
            asignado: toDoList[index][1],
            estado: toDoList[index][2],
            prioridad: toDoList[index][3],
            onEstadoChanged: (newEstado) => updateEstado(index, newEstado),
            onPrioridadChanged: (newPrioridad) =>
                updatePrioridad(index, newPrioridad),
          );
        },
      ),
    );
  }
}
