import 'package:flutter/material.dart';

// ── TRANSACTION ──────────────────────────────────────────────
class Transaction {
  final String id;
  final String type;
  final String cat;
  final String desc;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.cat,
    required this.desc,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'cat': cat,
        'desc': desc,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'],
        type: j['type'],
        cat: j['cat'],
        desc: j['desc'],
        amount: j['amount'].toDouble(),
        date: DateTime.parse(j['date']),
      );
}

// ── CATEGORY ─────────────────────────────────────────────────
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<Category> kCategories = [
  Category(id: 'food', name: 'Food', icon: Icons.fastfood, color: Color(0xFFff5252)),
  Category(id: 'travel', name: 'Travel', icon: Icons.directions_car, color: Color(0xFFffb830)),
  Category(id: 'shop', name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFF8b5cf6)),
  Category(id: 'health', name: 'Health', icon: Icons.medical_services, color: Color(0xFF4a9eff)),
  Category(id: 'bills', name: 'Bills', icon: Icons.bolt, color: Color(0xFF00d4a0)),
  Category(id: 'ent', name: 'Fun', icon: Icons.movie, color: Color(0xFFf97316)),
  Category(id: 'salary', name: 'Salary', icon: Icons.work, color: Color(0xFF22c55e)),
  Category(id: 'other', name: 'Other', icon: Icons.inventory_2, color: Color(0xFF94a3b8)),
];

Category catById(String id) =>
    kCategories.firstWhere((c) => c.id == id, orElse: () => kCategories.last);

// ── GOAL ─────────────────────────────────────────────────────
class Goal {
  String name;
  String icon;
  double target;
  double saved;
  double monthly;

  Goal({
    required this.name,
    required this.icon,
    required this.target,
    required this.saved,
    required this.monthly,
  });

  double get percent => (saved / target).clamp(0, 1);
  int get monthsLeft => ((target - saved) / monthly).ceil();

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'target': target,
        'saved': saved,
        'monthly': monthly,
      };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        name: j['name'],
        icon: j['icon'],
        target: j['target'].toDouble(),
        saved: j['saved'].toDouble(),
        monthly: j['monthly'].toDouble(),
      );
}

// ── PARTIAL PAYMENT ───────────────────────────────────────────
// Har partial payment ka record — amount, exact dateTime, aur optional note
class PartialPayment {
  final double amount;
  final DateTime dateTime;
  final String? note; // ✅ NEW: Optional note for each payment

  PartialPayment({
    required this.amount,
    required this.dateTime,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
      };

  factory PartialPayment.fromJson(Map<String, dynamic> j) => PartialPayment(
        amount: j['amount'].toDouble(),
        dateTime: DateTime.parse(j['dateTime']),
        note: j['note'],
      );
}

// ── PERSON TRANSACTION ────────────────────────────────────────
class PersonTxn {
  String desc;
  double amount;
  DateTime date;           // Jab transaction hua (date + time)
  bool settled;
  DateTime? settledDate;   // Jab fully settle hua (date + time)

  // Har partial payment ka history
  List<PartialPayment> partialPayments;

  PersonTxn({
    required this.desc,
    required this.amount,
    required this.date,
    this.settled = false,
    this.settledDate,
    List<PartialPayment>? partialPayments,
  }) : partialPayments = partialPayments ?? [];

  // Total paid = sum of all partial payments
  double get paidAmount =>
      partialPayments.fold(0, (s, p) => s + p.amount);

  double get remaining => amount.abs() - paidAmount;
  bool get isPartial => paidAmount > 0 && !settled;

  Map<String, dynamic> toJson() => {
        'desc': desc,
        'amount': amount,
        'date': date.toIso8601String(),
        'settled': settled,
        'settledDate': settledDate?.toIso8601String(),
        'partialPayments': partialPayments.map((p) => p.toJson()).toList(),
      };

  factory PersonTxn.fromJson(Map<String, dynamic> j) => PersonTxn(
        desc: j['desc'],
        amount: j['amount'].toDouble(),
        date: DateTime.parse(j['date']),
        settled: j['settled'] ?? false,
        settledDate: j['settledDate'] != null
            ? DateTime.parse(j['settledDate'])
            : null,
        partialPayments: j['partialPayments'] != null
            ? (j['partialPayments'] as List)
                .map((p) => PartialPayment.fromJson(p))
                .toList()
            : [],
      );
}

// ── PERSON ───────────────────────────────────────────────────
class Person {
  String id;
  String name;
  String relation;
  Color color;
  List<PersonTxn> transactions;

  Person({
    required this.id,
    required this.name,
    required this.relation,
    required this.color,
    required this.transactions,
  });

  double get balance =>
      transactions.where((t) => !t.settled).fold(
        0,
        (s, t) => s + (t.amount >= 0 ? t.remaining : -t.remaining),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
        'color': color.value,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Person.fromJson(Map<String, dynamic> j) => Person(
        id: j['id'],
        name: j['name'],
        relation: j['relation'],
        color: Color(j['color']),
        transactions: (j['transactions'] as List)
            .map((t) => PersonTxn.fromJson(t))
            .toList(),
      );
}