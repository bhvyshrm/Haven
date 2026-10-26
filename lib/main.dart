import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/haven_theme.dart';
import 'core/state/haven_state.dart';
import 'features/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final havenState = HavenState();
  await havenState.init();

  runApp(
    ChangeNotifierProvider.value(value: havenState, child: const HavenApp()),
  );
}

class HavenApp extends StatelessWidget {
  const HavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();

    return MaterialApp(
      title: 'Haven',
      debugShowCheckedModeBanner: false,
      theme: HavenTheme.lightTheme,
      darkTheme: HavenTheme.darkTheme,
      themeMode: state.settings.themeMode,
      home: const MainShell(),
    );
  }
}
