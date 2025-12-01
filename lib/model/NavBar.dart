import 'dart:async';
import 'package:datesync/auth/login.dart';
import 'package:datesync/model/configuracion.dart';
import 'package:datesync/views/ayuda.dart';
import 'package:datesync/views/calendario.dart';
import 'package:datesync/views/dashboard_analisis.dart';
import 'package:datesync/views/dashboard_inicio.dart';
import 'package:datesync/views/dashboard_tareas.dart';
import 'package:datesync/views/dashboard_team.dart';
import 'package:datesync/views/perfil_usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Yoshio'),
            accountEmail: Text('yoshiosama@gmail.com'),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilUsuario()),
                );
              },
              child: CircleAvatar(
                child: Image.network(
                  'https://www.gamespot.com/a/uploads/screen_kubrick/1624/16240817/4223910-huohuo-chibi-1.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                image: NetworkImage(
                  'https://img.freepik.com/vector-gratis/fondo-onda-forma-cortada-papel-abstracto_474888-4649.jpg?semt=ais_incoming&w=740&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Dashboardinicio()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text('Actividades'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardTareas()),
              );
            },
            trailing: Container(
              color: Colors.redAccent,
              width: 20,
              height: 20,
              child: Center(
                child: Text(
                  '8',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today_sharp),
            title: Text('Horario'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Calendario()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_sharp),
            title: Text('Analisis'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardAnalisis()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Equipo de trabajo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardTeam()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuracion'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Configuracion()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Centro de ayuda'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Ayuda()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Cerrar sesion'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (Route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
