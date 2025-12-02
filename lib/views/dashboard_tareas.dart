import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datesync/model/todo_list.dart';

class DashboardTareas extends StatefulWidget {
  @override
  State<DashboardTareas> createState() => _DashboardTareasState();
}

class _DashboardTareasState extends State<DashboardTareas> {
  final TaskController _controller = TaskController();

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
          child: Center(child: Text("No hay un usuario autenticado")),
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
            onPressed: () => _controller.showAddTaskDialog(context),
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

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controller.getEstadoIcon(estado),
                      SizedBox(height: 4),
                      _controller.getPrioridadIcon(prioridad),
                    ],
                  ),
                  title: Text('$tarea - $asignado'),
                  subtitle: Text('Estado: $estado | Prioridad: $prioridad'),
                  onTap: () => _controller.showTaskDetails(context, data),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _controller.editTask(context, doc.id, data),
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
                                    _controller.deleteTask(doc.id);
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
