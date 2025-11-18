import 'package:datesync/views/dashboard_analisis.dart';
import 'package:datesync/views/dashboard_completo_tarea.dart';
import 'package:datesync/views/dashboard_tareas.dart';
import 'package:datesync/views/dashboard_team.dart';
import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';

class Dashboardinicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(title: Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [
            _cajones(context, 'Sprints', Colors.deepPurple, DashboardTareas()),
            _cajones(
              context,
              'Calendario',
              const Color.fromARGB(255, 224, 135, 2),
              DashboardCompletoTarea(),
            ),
            _cajones(
              context,
              'Analisis',
              const Color.fromARGB(255, 0, 136, 64),
              DashboardAnalisis(),
            ),
            _cajones(
              context,
              'Equipo de trabajo',
              const Color.fromARGB(255, 5, 5, 183),
              DashboardTeam(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cajones(
    BuildContext context,
    String titulo,
    Color color,
    Widget pantalla,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            titulo,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
