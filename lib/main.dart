import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'widgets/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  if (Platform.isAndroid) {
    
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https:
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZleG5ieHpleGRvdmxkZ2NvaGFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwMzEwNzcsImV4cCI6MjA2NjYwNzA3N30.ahA_VbQCTTkEf1aCfg3FrTG93aFZ_Mv5-cY_MopJU9s',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => NoteViewModel()),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
