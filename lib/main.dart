// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Importa la función de inicialización de dependencias
import 'core/injection_container.dart' as di; // di = Dependency Injection
// Importa el BLoC
import 'features/route_optimization/presentation/bloc/route_bloc.dart';
// Importa la pantalla de inicio
import 'features/route_optimization/presentation/pages/input_screen.dart'; 

// 1. Inicializa el contenedor de inyección de dependencias
Future<void> main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de iniciar DI
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await di.init(); // Llama a la función init() para registrar todas las clases
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Usar MultiBlocProvider para proveer el RouteBloc
    // Se usa sl<RouteBloc>() para obtener la instancia registrada por GetIt
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<RouteBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PetWalk App',
        theme: ThemeData(
          primarySwatch: Colors.amber, // El color principal de tu UI
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // 3. Define la pantalla de inicio
        home: const InputScreen(), 
      ),
    );
  }
}