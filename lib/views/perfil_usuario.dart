import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datesync/model/NavBar.dart';

class PerfilUsuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: Text("Perfil de usuario"),
          backgroundColor: const Color.fromARGB(255, 1, 231, 181),
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text("No hay un usuario autenticado")),
      );
    }

    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text("Perfil de usuario"),
        backgroundColor: const Color.fromARGB(255, 1, 231, 181),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("usuarios")
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error al cargar datos: ${snapshot.error}",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(user.uid)
                  .set({
                    'nombre': user.displayName ?? '',
                    'correo': user.email ?? '',
                    'foto': user.photoURL ?? '',
                    'telefono': user.phoneNumber ?? '',
                    'uid': user.uid,
                    'creado': DateTime.now(),
                  })
                  .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Documento creado. Recarga la pantalla."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  })
                  .catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al crear documento: $error"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });

              return Center(
                child: Text(
                  "Creando datos del usuario...",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                              user.photoURL ?? data["foto"] ?? "",
                            ),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            data["nombre"] ?? "Sin nombre",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.email, color: Colors.teal),
                            title: Text(
                              "Correo Electrónico",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              user.email ?? "Correo no disponible",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.cake, color: Colors.teal),
                            title: Text(
                              "Edad",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              data["edad"] ?? "No registrado",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Spacer(),

                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 231, 181),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text("Cerrar sesión", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
