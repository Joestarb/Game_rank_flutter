import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Devuelve un mapa mínimo con los datos públicos del usuario
/// keys posibles: nombre, email
final userProfileProvider =
    StreamProvider.family<Map<String, String>?, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null) return null;
    final nombre = (data['nombre'] as String?)?.trim();
    final email = (data['email'] as String?)?.trim();
    return {
      if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
      if (email != null && email.isNotEmpty) 'email': email,
    };
  });
});
