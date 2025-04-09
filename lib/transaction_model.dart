import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String? category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return  {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {    
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }
}