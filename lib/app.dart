import 'package:flutter/material.dart';

import 'presentation/connection/connection_flow_screen.dart';
import 'presentation/theme/app_theme.dart';

class PulsoApp extends StatelessWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulso',
      debugShowCheckedModeBanner: false,
      theme: buildPulsoTheme(),
      home: const ConnectionFlowScreen(),
    );
  }
}
