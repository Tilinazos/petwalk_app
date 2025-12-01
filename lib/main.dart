// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Importa la función de inicialización de dependencias
import 'core/injection_container.dart' as di; // di = Dependency Injection
// Importa el servicio de sesión
import 'core/services/session_service.dart';
// Importa el BLoC
import 'features/route_optimization/presentation/bloc/route_bloc.dart';
// Importa la pantalla de ingreso de nombre
import 'features/auth/presentation/pages/name_input_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<RouteBloc>(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => SessionService(),
        child: MaterialApp(
          title: 'PetWalk App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.amber,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const NameInputScreen(),
        ),
      ),
    );
  }
}