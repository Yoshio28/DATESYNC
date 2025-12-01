import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datesync/views/dashboard_inicio.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<void> _crearDocumentoUsuario(User user) async {
    final userDoc = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'nombre': user.displayName ?? '',
        'correo': user.email,
        'foto': user.photoURL ?? '',
        'telefono': user.phoneNumber ?? '',
        'uid': user.uid,
        'creado': DateTime.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constrains, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset('lib/assets/img/logo.png'),
              );
            },
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _crearDocumentoUsuario(user);
                }
              }),
            ],
          );
        }

        final user = snapshot.data!;
        _crearDocumentoUsuario(user);

        return Dashboardinicio();
      },
    );
  }
}
