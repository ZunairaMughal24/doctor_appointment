import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUpPatient({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final doctorDoc = await firestore.collection('doctors').doc(uid).get();
      if (doctorDoc.exists) {
        return UserModel.fromFirestore(doctorDoc.data()!, uid);
      }

      final userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data()!, uid);
      }

      throw const AuthException('User profile not found.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed.');
    }
  }

  @override
  Future<UserModel> signUpPatient({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final model = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.patient,
      );
      await firestore.collection('users').doc(uid).set(model.toFirestore());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed.');
    }
  }

  @override
  Future<UserModel> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await firestore.collection('doctors').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'doctor',
        'speciality': speciality,
        'experience': experience,
        'number': phoneNumber,
        'location': location,
        'availability': availability,
        'services': services,
        'description': '',
        'rating': 4.5,
      });
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.doctor,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Doctor sign up failed.');
    }
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    final uid = firebaseUser.uid;

    final doctorDoc = await firestore.collection('doctors').doc(uid).get();
    if (doctorDoc.exists) {
      return UserModel.fromFirestore(doctorDoc.data()!, uid);
    }

    final userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc.data()!, uid);
    }
    return null;
  }
}
