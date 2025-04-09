import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

const List<String> list = <String>[
  'onetime',
  'monthly',
  'annual',
  'income',
]; // FOR DROPDOWN

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<Transaction> _transactions = [];
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();

  List<Transaction> _filteredTransactions = [];

  String? selectedValue;

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromHive();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addTransaction() async {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;
    final enteredCategory = selectedValue;
    //print(enteredCategory);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || selectedValue == null)
      return;

    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: enteredTitle,
      amount: enteredAmount,
      date: DateTime.now(),
      category: enteredCategory,
    );
    //print(newTx.category);

    final box = Hive.box<Transaction>('transactions');
    await box.add(newTx);

    setState(() {
      _transactions.add(newTx);
      _filterTransactions();
    });

    _titleController.clear();
    _amountController.clear();
  }

  // void _deleteTransaction(String id) async {
  //   final box = Hive.box<Transaction>('transactions');
  //   final index = _transactions.indexWhere((tx) => tx.id == id);

  //   if (index != -1) {
  //     await box.deleteAt(index);
  //     setState(() {
  //       _transactions.removeAt(index);
  //       _filterTransactions();
  //     });
  //   }
  // }

  void _onSearchChanged() {
    _filterTransactions();
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions =
          _transactions.where((tx) {
            return tx.title.toLowerCase().contains(query) ||
                tx.amount.toString().contains(query);
          }).toList();
    });
  }

  void _loadTransactionsFromHive() {
    final box = Hive.box<Transaction>('transactions');
    setState(() {
      _transactions.clear();
      _transactions.addAll(box.values);
      _filteredTransactions = List.from(_transactions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('transactions'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth < 700 ? constraints.maxWidth : 700,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'title',
                            contentPadding: EdgeInsets.only(left: 15),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          controller: _titleController,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'amount',
                            contentPadding: EdgeInsets.only(left: 15),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                backgroundColor: Colors.transparent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            items:
                                list
                                    .map(
                                      (String item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            value: selectedValue,
                            onChanged: (String? value) {
                              setState(() {
                                selectedValue = value;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: FilledButton(
                            onPressed: _addTransaction,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.indigo,
                            ),
                            child: Text(
                              'add transaction',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20, top: 50),
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'search transactions...',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            FocusScope.of(context).unfocus();
                                          },
                                          icon: Icon(Icons.clear),
                                        ),
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ValueListenableBuilder<Box<Transaction>>(
                            valueListenable:
                                Hive.box<Transaction>(
                                  'transactions',
                                ).listenable(),
                            builder: (context, box, _) {
                              final allTransactions = box.values.toList();

                              final filtered =
                                  _searchController.text.isEmpty
                                      ? allTransactions
                                      : allTransactions.where((tx) {
                                        final query =
                                            _searchController.text
                                                .toLowerCase();
                                        return tx.title.toLowerCase().contains(
                                              query,
                                            ) ||
                                            tx.amount.toString().contains(
                                              query,
                                            );
                                      }).toList();

                              if (filtered.isEmpty) {
                                return Center(
                                  child: Text(
                                    'no transactions found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final tx = filtered[index];
                                  return Card(
                                    margin: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      bottom: 10,
                                    ),
                                    child: ListTile(
                                      title: Text(tx.title),
                                      subtitle: Text(
                                        '${tx.date.day.toString()}-${tx.date.month.toString()}-${tx.date.year.toString()} ${tx.date.hour.toString()}:${tx.date.minute.toString()}:${tx.date.second.toString()} | type: ${tx.category.toString()}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${tx.amount.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            onPressed: () {
                                              final keyToDelete = box.keys
                                                  .elementAt(index);
                                              box.delete(keyToDelete);
                                            },
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
