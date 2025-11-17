import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';

class Calendario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(title: Text('Calendario de eventos')),
      body: Center(),
    );
  }
}
