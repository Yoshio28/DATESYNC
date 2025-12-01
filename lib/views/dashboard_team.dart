import 'package:flutter/material.dart';
import 'package:datesync/model/NavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardTeam extends StatefulWidget {
  @override
  State<DashboardTeam> createState() => _DashboardTeamState();
}

class _DashboardTeamState extends State<DashboardTeam> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _addNewCollaborator() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    String status = 'activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Colaborador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: roleController,
              decoration: InputDecoration(labelText: 'Rol'),
            ),
            DropdownButton<String>(
              value: status,
              items: ['activo', 'inactivo'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  status = newValue!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  roleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, completa todos los campos.'),
                  ),
                );
                return;
              }

              final newDoc = FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc();
              await newDoc.set({
                'nombre': nameController.text,
                'correo': emailController.text,
                'rol': roleController.text,
                'estado': status,
                'uid': newDoc.id,
                'creado': DateTime.now(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Colaborador agregado')));
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
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
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: _addNewCollaborator,
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
                      final data = docs[index].data() as Map<String, dynamic>;
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
