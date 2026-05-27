import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUtil {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> registerUser({
    required String email,
    required String nome,
    required String senha,
    // File? fotoPerfil,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: senha);
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
}
