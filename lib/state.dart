import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models/models.dart';
import 'theme.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();

  List<Transaction> transactions = [
    Transaction(id: '1', type: 'expense', cat: 'food', desc: 'Zomato Order', amount: 450, date: DateTime(2026, 4, 19)),
    Transaction(id: '2', type: 'expense', cat: 'travel', desc: 'Petrol', amount: 800, date: DateTime(2026, 4, 18)),
    Transaction(id: '3', type: 'income', cat: 'salary', desc: 'April Salary', amount: 80000, date: DateTime(2026, 4, 1)),
    Transaction(id: '4', type: 'expense', cat: 'shop', desc: 'Amazon Order', amount: 2300, date: DateTime(2026, 4, 17)),
    Transaction(id: '5', type: 'expense', cat: 'food', desc: 'Restaurant Dinner', amount: 1200, date: DateTime(2026, 4, 16)),
    Transaction(id: '6', type: 'expense', cat: 'bills', desc: 'Electricity Bill', amount: 1800, date: DateTime(2026, 4, 15)),
    Transaction(id: '7', type: 'expense', cat: 'health', desc: 'Gym Membership', amount: 2000, date: DateTime(2026, 4, 14)),
    Transaction(id: '8', type: 'expense', cat: 'ent', desc: 'Netflix, Hotstar', amount: 500, date: DateTime(2026, 4, 13)),
    Transaction(id: '9', type: 'expense', cat: 'travel', desc: 'Cab - Office', amount: 350, date: DateTime(2026, 4, 12)),
    Transaction(id: '10', type: 'expense', cat: 'food', desc: 'Swiggy', amount: 380, date: DateTime(2026, 4, 11)),
  ];

  List<Goal> goals = [
    Goal(name: 'iPhone 15', icon: '📱', target: 79900, saved: 12000, monthly: 500),
    Goal(name: 'Goa Trip', icon: '🏖️', target: 25000, saved: 8000, monthly: 2000),
    Goal(name: 'Emergency Fund', icon: '🛡️', target: 100000, saved: 35000, monthly: 5000),
  ];

  List<Person> people = [
    Person(id: '1', name: 'Raju Bhai', relation: 'Brother', color: kBlue, transactions: [
      PersonTxn(desc: 'Dinner split', amount: 1500, date: DateTime(2026, 4, 15, 20, 30)),
      PersonTxn(desc: 'Movie tickets', amount: 1000, date: DateTime(2026, 4, 10, 18, 0)),
    ]),
    Person(id: '2', name: 'Meena Di', relation: 'Sister', color: kPurple, transactions: [
      PersonTxn(desc: 'Borrowed for shopping', amount: -1200, date: DateTime(2026, 4, 17, 15, 45)),
    ]),
    Person(id: '3', name: 'Rahul Dost', relation: 'Friend', color: kGreen, transactions: [
      PersonTxn(desc: 'Petrol money', amount: 800, date: DateTime(2026, 4, 12, 11, 0)),
    ]),
    Person(id: '4', name: 'Ammi', relation: 'Mother', color: kAmber, transactions: [
      PersonTxn(
        desc: 'Grocery advance',
        amount: 500,
        date: DateTime(2026, 4, 8, 9, 0),
        settled: true,
        settledDate: DateTime(2026, 4, 9, 10, 30),
      ),
    ]),
  ];

  // ── ADD TRANSACTION WITH AUTO NET SETTLEMENT ─────────────────
  // Logic:
  //  - New txn add karo
  //  - Opposite sign ke unsettled txns se net karo
  //  - Jo fully cover ho jaye → auto-settle
  //  - Net remaining → new txn as replacement (agar kuch bacha)
  void addTransactionToPerson(String personId, PersonTxn txn) {
    final p = people.firstWhere((x) => x.id == personId);
    final now = DateTime.now();

    // New transaction pehle add karo
    p.transactions.add(txn);

    // Opposite sign ke unsettled transactions dhundho
    // e.g. naya txn negative hai → positive unsettled se net karo
    final oppositeTxns = p.transactions
        .where((t) => !t.settled && t != txn && t.amount.sign != txn.amount.sign)
        .toList();

    double newAmt = txn.amount.abs(); // naye txn ka remaining amount

    for (final old in oppositeTxns) {
      if (newAmt <= 0) break;

      final oldRemaining = old.amount.abs() - old.paidAmount;

      if (oldRemaining <= newAmt) {
        // Old txn fully cover ho gaya → auto-settle
        old.settled = true;
        old.settledDate = now;
        old.partialPayments.add(PartialPayment(
          amount: oldRemaining,
          dateTime: now,
        ));
        newAmt -= oldRemaining;
      } else {
        // Old txn partially cover hua
        old.partialPayments.add(PartialPayment(
          amount: newAmt,
          dateTime: now,
        ));
        newAmt = 0;
      }
    }

    // Naya txn ka jo amount pehle se settle ho gaya ushe mark karo
    final coveredByNew = txn.amount.abs() - newAmt;
    if (coveredByNew > 0) {
      if (newAmt <= 0) {
        // Naya txn bhi fully settle ho gaya (opposite ne cover kar liya)
        txn.settled = true;
        txn.settledDate = now;
        txn.partialPayments.add(PartialPayment(
          amount: txn.amount.abs(),
          dateTime: now,
        ));
      } else {
        // Naya txn partially settle hua
        txn.partialPayments.add(PartialPayment(
          amount: coveredByNew,
          dateTime: now,
        ));
      }
    }

    notifyListeners();
    _save();
  }

  // 2. Single transaction fully settle karo — settledDate = now with time
  void settleSingle(String personId, PersonTxn txn) {
    final p = people.firstWhere((x) => x.id == personId);
    final t = p.transactions.firstWhere((x) => x == txn);
    t.settled = true;
    t.settledDate = DateTime.now();
    notifyListeners();
    _save();
  }

  // 3. Partial settle — PartialPayment history mein save karo
  void partialSettle(String personId, PersonTxn txn, double amount, {String? note}) {
    final p = people.firstWhere((x) => x.id == personId);
    final t = p.transactions.firstWhere((x) => x == txn);

    t.partialPayments.add(PartialPayment(
      amount: amount,
      dateTime: DateTime.now(),
      note: note,
    ));

    // Agar total paid >= total amount → fully settle
    if (t.paidAmount >= t.amount.abs()) {
      t.settled = true;
      t.settledDate = DateTime.now();
    }

    notifyListeners();
    _save();
  }

  double get totalIncome =>
      transactions.where((t) => t.type == 'income').fold(0, (s, t) => s + t.amount);

  double get totalExpense =>
      transactions.where((t) => t.type == 'expense').fold(0, (s, t) => s + t.amount);

  double get totalReceive =>
      people.fold(0, (s, p) => s + (p.balance > 0 ? p.balance : 0));

  double get totalOwe =>
      people.fold(0, (s, p) => s + (p.balance < 0 ? p.balance.abs() : 0));

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      map[t.cat] = (map[t.cat] ?? 0) + t.amount;
    }
    return map;
  }

  void addTransaction(Transaction t) {
    transactions.insert(0, t);
    notifyListeners();
    _save();
  }

  void addGoal(Goal g) {
    goals.add(g);
    notifyListeners();
    _save();
  }

  void addToGoal(int index, double amount) {
    goals[index].saved = (goals[index].saved + amount).clamp(0, goals[index].target);
    notifyListeners();
    _save();
  }

  void deleteGoal(int index) {
    goals.removeAt(index);
    notifyListeners();
    _save();
  }

  void addPerson(Person p) {
    people.add(p);
    notifyListeners();
    _save();
  }

  void settleAll(String personId) {
    final p = people.firstWhere((x) => x.id == personId);
    final now = DateTime.now();
    for (final t in p.transactions) {
      if (!t.settled) {
        t.settled = true;
        t.settledDate = now;
      }
    }
    notifyListeners();
    _save();
  }

  String newId() => _uuid.v4();

  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('txns', jsonEncode(transactions.map((t) => t.toJson()).toList()));
    prefs.setString('goals', jsonEncode(goals.map((g) => g.toJson()).toList()));
    prefs.setString('people', jsonEncode(people.map((p) => p.toJson()).toList()));
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final txnsStr = prefs.getString('txns');
      final goalsStr = prefs.getString('goals');
      final peopleStr = prefs.getString('people');
      if (txnsStr != null) transactions = (jsonDecode(txnsStr) as List).map((j) => Transaction.fromJson(j)).toList();
      if (goalsStr != null) goals = (jsonDecode(goalsStr) as List).map((j) => Goal.fromJson(j)).toList();
      if (peopleStr != null) people = (jsonDecode(peopleStr) as List).map((j) => Person.fromJson(j)).toList();
      notifyListeners();
    } catch (_) {}
  }
}