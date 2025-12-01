import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:datesync/views/calendario.dart';
import 'package:datesync/views/dashboard_analisis.dart';
import 'package:datesync/views/dashboard_completo_tarea.dart';
import 'package:datesync/views/dashboard_tareas.dart';
import 'package:datesync/views/dashboard_team.dart';
import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';

class Dashboardinicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(Icons.home, size: 30),
      Icon(Icons.work, size: 30),
      Icon(Icons.calendar_month, size: 30),
      Icon(Icons.analytics, size: 30),
      Icon(Icons.people, size: 30),
    ];
    return Scaffold(
      drawer: Navbar(),
      backgroundColor: const Color.fromARGB(255, 161, 150, 150),
      appBar: AppBar(
        title: Text('Inicio'),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [
            _cajones(
              context,
              'Sprints',
              const Color.fromARGB(255, 97, 146, 146),
              DashboardTareas(),
            ),
            _cajones(
              context,
              'Calendario',
              const Color.fromARGB(255, 51, 134, 86),
              Calendario(),
            ),
            _cajones(
              context,
              'Analisis',
              const Color.fromARGB(255, 4, 71, 35),
              DashboardAnalisis(),
            ),
            _cajones(
              context,
              'Equipo de trabajo',
              const Color.fromARGB(255, 0, 8, 2),
              DashboardTeam(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.blue.shade300,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        height: 60,
        items: items,
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
