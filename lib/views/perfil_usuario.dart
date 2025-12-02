import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:datesync/model/NavBar.dart';

class PerfilUsuario extends StatefulWidget {
  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl; // Para URLs de Firebase (si existe)
  String? _localImagePath; // Ruta local de la imagen

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
                    'rol': 'usuario', // Valor por defecto para rol
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
            _imageUrl = data["foto"] ?? user.photoURL ?? "";
            _localImagePath = data["fotoLocal"] ?? "";

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
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    _localImagePath != null &&
                                        _localImagePath!.isNotEmpty
                                    ? FileImage(File(_localImagePath!))
                                    : NetworkImage(_imageUrl ?? "")
                                          as ImageProvider,
                                backgroundColor: Colors.grey.shade200,
                              ),
                              GestureDetector(
                                onTap: _pickAndSaveImage,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.teal,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
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
                            leading: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.teal,
                            ),
                            title: Text(
                              "Rol",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              data["rol"] ?? "Sin rol",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Divider(),
                          ElevatedButton(
                            onPressed: () =>
                                _showChangePasswordDialog(context, user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text("Cambiar Contraseña"),
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

  // Función para seleccionar y guardar imagen localmente
  Future<void> _pickAndSaveImage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Seleccionar de galería'),
            onTap: () => _selectAndSaveImage(ImageSource.gallery, user),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Tomar foto'),
            onTap: () => _selectAndSaveImage(ImageSource.camera, user),
          ),
        ],
      ),
    );
  }

  Future<void> _selectAndSaveImage(ImageSource source, User user) async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${user.uid}.jpg';
      final localPath = path.join(directory.path, fileName);

      final file = File(image.path);
      await file.copy(localPath);

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .update({'fotoLocal': localPath});

      setState(() {
        _localImagePath = localPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de perfil guardada localmente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar imagen: $e')));
    }
  }

  // Función para mostrar diálogo de cambiar contraseña
  void _showChangePasswordDialog(BuildContext context, User user) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Nueva Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text == confirmPasswordController.text &&
                  passwordController.text.isNotEmpty) {
                try {
                  await user.updatePassword(passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña cambiada exitosamente')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Las contraseñas no coinciden o están vacías',
                    ),
                  ),
                );
              }
            },
            child: Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}
