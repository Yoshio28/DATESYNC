import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';

class DashboardCompletoTarea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(title: Text('Dashboard Completo')),
      body: Center(),
    );
  }
}
