// ignore: unused_import
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUtil {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String nome,
    required String senha,
    // File? fotoPerfil,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: senha);
    await _firebaseAuth.currentUser!.sendEmailVerification();
    await userCredential.user!.updateDisplayName(nome);
    // await userCredential.user!.updatePhotoURL(fotoPerfil?.path);
    // Reload the user to reflect the changes
    await userCredential.user!.reload();
    // Get fresh reference to ensure displayName is updated globally
    await _firebaseAuth.currentUser?.reload();
  }

  Future<UserCredential> logUserIn({
    required String email,
    required String senha,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<UserCredential> reauthUser({
    required String email,
    required String senha,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: senha,
    );
    return await _firebaseAuth.currentUser!.reauthenticateWithCredential(
      credential,
    );
  }

  Future<void> deleteUser() async {
    final uid = _firebaseAuth.currentUser!.uid;
    await db.collection('users').doc(uid).delete();
    await _firebaseAuth.currentUser!.delete();
  }

  Future<String> emailRedefSenha(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Email de mudança de senha enviado, cheque sua caixa de entrada";
    } catch (e) {
      return "Acorreu um erro $e";
    }
  }
}
