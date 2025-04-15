import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Transaction> _transactions = [];

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  BalanceCard(transactions: _transactions),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Recurring spendings:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  SubscriptionsReminder(transactions: _transactions),
                  SizedBox(height: 50),
                  SfCalendar(
                    headerStyle: CalendarHeaderStyle(
                      backgroundColor: Colors.transparent,
                    ),
                    view: CalendarView.month,
                    todayHighlightColor: Colors.indigo,
                    monthViewSettings: MonthViewSettings(
                      agendaItemHeight: 30,
                      showAgenda: true,
                      agendaViewHeight: 50,
                      showTrailingAndLeadingDates: false,
                      numberOfWeeksInView: 5,
                      monthCellStyle: MonthCellStyle(
                        todayBackgroundColor: Colors.indigo,
                        todayTextStyle: TextStyle(color: Colors.indigo),
                      ),
                    ),
                    headerHeight: 30,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final List<Transaction> transactions;

  const BalanceCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.indigo,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available balance',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            TotalBalance(transactions: transactions),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalBalance extends StatelessWidget {
  const TotalBalance({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    double balance = 0;
    for (var tx in transactions) {
      if (tx.category == 'income') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return Text(
      '\$${balance.toStringAsFixed(2)}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 35,
        color: Colors.white,
      ),
    );
  }
}

class SubscriptionsReminder extends StatelessWidget {
  const SubscriptionsReminder({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final recurringTransactions =
        transactions
            .where((tx) => tx.category == 'monthly' || tx.category == 'annual')
            .toList();

    if (recurringTransactions.isEmpty) {
      return Text('No current recurring payments on the way');
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: recurringTransactions.length,
        itemBuilder: (context, index) {
          final tx = recurringTransactions[index];
          return Card(
            child: ListTile(
              title: Text(tx.title),
              subtitle: Text(
                '${tx.date.day.toString()}-${tx.date.month.toString()}-${tx.date.year.toString()} ${tx.date.hour.toString()}:${tx.date.minute.toString()}:${tx.date.second.toString()} | type: ${tx.category.toString()}',
              ),
              trailing: Text(
                '\$${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
