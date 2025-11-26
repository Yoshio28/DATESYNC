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
        appBar: AppBar(title: Text("Perfil de usuario")),
        body: Center(child: Text("No hay un usuario autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de usuario"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar datos: ${snapshot.error}"),
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
                    ),
                  );
                })
                .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al crear documento: $error")),
                  );
                });

            return Center(child: Text("Creando datos del usuario..."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    user.photoURL ?? data["foto"] ?? "",
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  data["nombre"] ?? "Sin nombre",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  user.email ?? "Correo no disponible",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text("Edad: ${data["edad"] ?? "No registrado"}"),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  child: Text("Cerrar sesión"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
