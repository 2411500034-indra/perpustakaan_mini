import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/api_book_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'views/home_crud_page.dart';
import 'views/login_register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PerpustakaanMiniApp());
}

class PerpustakaanMiniApp extends StatelessWidget {
  const PerpustakaanMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BookProvider>(create: (_) => BookProvider()),
        ChangeNotifierProvider<ApiBookProvider>(
          create: (_) => ApiBookProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Perpustakaan Mini',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authStateChanges = context.read<AuthProvider>().authStateChanges;

    return StreamBuilder(
      stream: authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Gagal memeriksa status autentikasi: ${snapshot.error}',
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == null
            ? const LoginRegisterPage()
            : const HomeCrudPage();
      },
    );
  }
}
