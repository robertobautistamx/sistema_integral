// controlador/login_controller.dart
// ignore_for_file: await_only_futures, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // Login con Google
  Future<UsuarioModelo?> loginConGoogle() async {
    try {
      // 1. Inicia el flujo de login de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // usuario canceló

      // 2. Obtiene la autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(googleAuth); // Para ver qué propiedades tiene

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
