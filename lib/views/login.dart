import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
class login extends StatelessWidget {
 const login({super.key});
 @override
 Widget build(BuildContext context) {
 return StreamBuilder<User?>(
 stream: FirebaseAuth.instance.authStateChanges(),
 builder: (context, snapshot) {
 if (!snapshot.hasData) {
 return const SignInScreen();
 }
 return const Center(child: Text("Página Login, usuario autenticado"),);
 },
 );
 } 