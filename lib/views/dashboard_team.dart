import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datesync/model/teamController.dart';

class DashboardTeam extends StatefulWidget {
  @override
  State<DashboardTeam> createState() => _DashboardTeamState();
}

class _DashboardTeamState extends State<DashboardTeam> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final TeamController _controller = TeamController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: Text('Equipo de trabajo'),
          backgroundColor: const Color.fromARGB(255, 1, 231, 181),
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text("No hay un usuario autenticado")),
      );
    }

    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text('Equipo de trabajo'),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar colaborador por nombre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _controller.showAddCollaboratorDialog(context),
              child: Text('Ingresar Nuevo Colaborador'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No hay colaboradores registrados.'),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['nombre']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['nombre'] ?? 'Sin nombre';
                      final email = data['correo'] ?? 'Sin correo';
                      final role = data['rol'] ?? 'Sin rol';
                      final status = data['estado'] ?? 'inactivo';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('$name - $role'),
                          subtitle: Text('Correo: $email\nEstado: $status'),
                          trailing: Icon(
                            status == 'activo'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: status == 'activo'
                                ? Colors.green
                                : Colors.red,
                          ),
                          onTap: () => _controller.showActionsDialog(
                            context,
                            doc.id,
                            data,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
