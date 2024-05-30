import 'package:flutter/material.dart';
import 'package:mosnad_3/database/mock_data_helper.dart';

// import 'database/my_database.dart';

void main() async {
  // await MyDatabase.open();
  await MockDataHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Container(),
    );
  }
}
