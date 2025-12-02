import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamController {
  Future<void> addCollaborator({
    required String name,
    required String email,
    required String role,
    required String password,
    required String status,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'nombre': name,
            'correo': email,
            'rol': role,
            'estado': status,
            'uid': userCredential.user!.uid,
            'creado': DateTime.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Colaborador agregado y usuario creado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> editCollaborator({
    required String docId,
    required String name,
    required String email,
    required String role,
    required String status,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(docId).update(
        {'nombre': name, 'correo': email, 'rol': role, 'estado': status},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Colaborador editado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al editar: $e')));
    }
  }

  Future<void> deleteCollaborator({
    required String docId,
    required BuildContext context,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Colaborador eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  void showAddCollaboratorDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String status = 'activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Colaborador'),
        content: SingleChildScrollView(
          child: Column(
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
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
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
                  status = newValue!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty ||
                  roleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }
              addCollaborator(
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
                role: roleController.text,
                status: status,
                context: context,
              );
              Navigator.pop(context);
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void showEditCollaboratorDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: data['nombre'],
    );
    final TextEditingController emailController = TextEditingController(
      text: data['correo'],
    );
    final TextEditingController roleController = TextEditingController(
      text: data['rol'],
    );
    String status = data['estado'] ?? 'activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Colaborador'),
        content: SingleChildScrollView(
          child: Column(
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
                  status = newValue!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              editCollaborator(
                docId: docId,
                name: nameController.text,
                email: emailController.text,
                role: roleController.text,
                status: status,
                context: context,
              );
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void showActionsDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acciones para ${data['nombre']}'),
        content: Text('¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showEditCollaboratorDialog(context, docId, data);
            },
            child: Text('Editar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDeleteConfirmation(context, docId);
            },
            child: Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar este colaborador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              deleteCollaborator(docId: docId, context: context);
              Navigator.pop(context);
            },
            child: Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
