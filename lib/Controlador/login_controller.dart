// controlador/login_controller.dart
// ignore_for_file: await_only_futures, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Modelo/usuario.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor de GoogleSignIn (sin scopes innecesarios)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login con correo y contraseña
  Future<UsuarioModelo?> loginConCorreo(
    String correo,
    String contrasena,
  ) async {
    try {
      final UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      final User user = resultado.user!;
      return UsuarioModelo(uid: user.uid, correo: user.email!);
    } catch (e) {
      print("Error login correo: $e");
      return null;
    }
  }

  // Registro de usuario
  Future<UsuarioModelo?> registrarUsuario(
    String correo,
    String contrasena,
  ) async {
    try {
      final UserCredential resultado = await _auth
          .createUserWithEmailAndPassword(email: correo, password: contrasena);
      final User user = resultado.user!;
      return UsuarioModelo(uid: user.uid, correo: user.email!);
    } catch (e) {
      print("Error registro usuario: $e");
      return null;
    }
  }

  // Recuperar contraseña
  Future<void> recuperarContrasena(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
    } catch (e) {
      print("Error recuperar contraseña: $e");
      rethrow;
    }
  }

  // Login con Google
  Future<UsuarioModelo?> loginConGoogle() async {
    try {
      // 1. Inicia el flujo de login de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // usuario canceló

      // 2. Obtiene la autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crea la credencial de Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken: googleAuth.accessToken, // Elimina esta línea si no existe
      );

      // 4. Inicia sesión en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Después de iniciar sesión con Google
        final docRef = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid);
        final doc = await docRef.get();

        // Si el usuario no existe en Firestore, lo creamos
        if (!doc.exists) {
          await docRef.set({
            'nombre': user.displayName ?? 'Usuario',
            'correo': user.email,
            // Puedes agregar más campos si quieres
          });
        }

        return UsuarioModelo(uid: user.uid, correo: user.email!);
      }
      return null;
    } catch (e) {
      print("Error login Google: $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error cerrar sesión: $e");
    }
  }
}
