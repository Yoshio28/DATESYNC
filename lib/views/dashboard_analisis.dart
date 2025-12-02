import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardAnalisis extends StatefulWidget {
  @override
  _DashboardAnalisisState createState() => _DashboardAnalisisState();
}

class _DashboardAnalisisState extends State<DashboardAnalisis> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: Text('Analisis'),
          backgroundColor: const Color.fromARGB(255, 1, 231, 181),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade200, Colors.blue.shade300],
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
      appBar: AppBar(
        title: Text('Analisis'),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tareas')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: Text('No hay tareas para analizar.')),
                  );
                }

                int pendiente = 0, enProgreso = 0, completado = 0;
                int alta = 0, media = 0, baja = 0;

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final estado = data['estado'] ?? 'Pendiente';
                  final prioridad = data['prioridad'] ?? 'Media';

                  if (estado == 'Pendiente')
                    pendiente++;
                  else if (estado == 'En Progreso')
                    enProgreso++;
                  else if (estado == 'Completado')
                    completado++;

                  if (prioridad == 'Alta')
                    alta++;
                  else if (prioridad == 'Media')
                    media++;
                  else if (prioridad == 'Baja')
                    baja++;
                }

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Estados de Tareas',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: pendiente.toDouble(),
                                        title: '$pendiente',
                                        color: Colors.red,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: enProgreso.toDouble(),
                                        title: '$enProgreso',
                                        color: Colors.yellow,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: completado.toDouble(),
                                        title: '$completado',
                                        color: Colors.green,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        titlePositionPercentageOffset: 0.5,
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 50,
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend('En espera', Colors.red),
                                  SizedBox(width: 10),
                                  _buildLegend('Proceso', Colors.yellow),
                                  SizedBox(width: 10),
                                  _buildLegend('Completo', Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Prioridades de Tareas',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: alta.toDouble(),
                                        title: '$alta',
                                        color: Colors.red,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: media.toDouble(),
                                        title: '$media',
                                        color: Colors.yellow,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: baja.toDouble(),
                                        title: '$baja',
                                        color: Colors.green,
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        titlePositionPercentageOffset: 0.5,
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 50,
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend('Alta', Colors.red),
                                  SizedBox(width: 16),
                                  _buildLegend('Media', Colors.yellow),
                                  SizedBox(width: 16),
                                  _buildLegend('Baja', Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.teal.shade800),
        ),
      ],
    );
  }
}
