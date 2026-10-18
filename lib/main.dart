import 'package:flutter/material.dart';
import 'package:sparks/app/app.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthCubit.instance.checkAuthStatus();
  runApp(const SparksApp());
}
