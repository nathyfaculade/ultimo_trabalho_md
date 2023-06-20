import 'package:flutter/material.dart';
import 'package:turismo_app/pages/filtro_page.dart';
import 'package:turismo_app/pages/lista_turismo_page.dart';

void main() {
  runApp(const AppTurismo());
}

class AppTurismo extends StatelessWidget {
  const AppTurismo({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Pontos Turisticos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: ListaTurismoPage(),
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
      },
    );
  }
}
