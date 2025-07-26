import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromFirestore(doc.data()!);
    }
    return null;
  }
}
