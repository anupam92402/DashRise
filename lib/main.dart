import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_cubit/game_cubit.dart';
import 'utils/routing/app_router.dart';
import 'utils/routing/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    DevicePreview(
      enabled: false,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit(),
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Chewy'),
        debugShowCheckedModeBanner: false,
        title: 'DashRise',
        initialRoute: RouteNames.welcomeScreen,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
