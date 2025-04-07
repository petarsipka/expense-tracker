import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory dir = Directory.current;
  Hive.init(dir.path);
  
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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  void _addTransaction() async {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) return;

    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: enteredTitle,
      amount: enteredAmount,
      date: DateTime.now(),
    );

    final box = Hive.box<Transaction>('transactions');
    await box.add(newTx);
    

    setState(() {
      _transactions.add(newTx);
    });

    _titleController.clear();
    _amountController.clear();
  }

  double get _totalExpense {
    return _transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _totalBalance {
    return 200 - _totalExpense;
  }

  void _deleteTransaction(String id) async {
    final box = Hive.box<Transaction>('transactions');

    final index = _transactions.indexWhere((tx) => tx.id == id);

    if(index != -1) {
      await box.deleteAt(index);
      setState(() {
      _transactions.removeAt(index);
      
      });
    }
  }

  void _clearAllTransactions() async {
    final box = Hive.box<Transaction>('transactions');
    await box.clear();
    
    setState(() {
      _transactions.clear();
    });
  }

  void _loadTransactionsFromHive() {
    final box = Hive.box<Transaction>('transactions');

    setState(() {
      _transactions.clear();
      _transactions.addAll(box.values);
    });
  }


  @override
  void initState() {
    super.initState();
    _loadTransactionsFromHive();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Tracker')),
      body: Column(
        children: [
          // Total balance card
          Card(
            elevation: 5,
            margin: EdgeInsets.only(left: 50, right: 50, bottom: 20),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${_totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total expense card
          Card(
            elevation: 5,
            margin: EdgeInsets.only(left: 50, right: 50),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expense',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${_totalExpense.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Input fields
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _addTransaction,
                      child: Text('Add Transaction'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _clearAllTransactions,
                      child: Text('Clear all'),
                    ),
                  ],
                ),            
              ],
            ),
          ),
          // Transactions
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final tx = _transactions[index];
                return Card(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                  child: ListTile(
                    title: Text(tx.title),
                    subtitle: Text(tx.date.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: IconButton(
                            onPressed: () => _deleteTransaction(tx.id),
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
