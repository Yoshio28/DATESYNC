import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';

class DashboardTareas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(title: Text('Sprints')),
      body: Center(),
    );
  }
}
