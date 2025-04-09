import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String hivePath =
      Platform.isAndroid || Platform.isIOS
          ? (await getApplicationDocumentsDirectory()).path
          : Directory.current.path;

  await Hive.initFlutter(hivePath); // Will work on all platforms

  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');

  runApp(const ExpenseTracker());
}

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PageNavigation(), // 👈 Use new page here
    );
  }
}
