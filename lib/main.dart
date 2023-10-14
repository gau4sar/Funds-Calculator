import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:funds_calculator/screens/FundsListPage.dart';
import 'package:funds_calculator/screens/ViewModel/FundViewModel.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load the .env file

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FundViewModel>(
          create: (context) => FundViewModel(), // Initialize your provider here
        ),
        // Add other providers if needed
      ],
      child: MaterialApp(
        title: 'Your App',
        home: FundsListPage(), // Your initial screen
      ),
    );
  }
}