import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<UserCredential> login(String email, String senha) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );
  }

  // ================= TIPO USUÁRIO =================
  Future<String> getTipoUsuario(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return 'cliente';
    }

    final data = doc.data();

    return data?['role'] ?? 'cliente';
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================= USUÁRIO ATUAL =================
  User? get user => _auth.currentUser;
}