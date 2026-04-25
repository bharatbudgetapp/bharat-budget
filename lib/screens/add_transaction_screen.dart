import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';
import '../models/models.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'expense';
  String _selCat = 'food';
  final _amtCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  List<Category> get _cats => _type == 'income'
      ? kCategories.where((c) => c.id == 'salary' || c.id == 'other').toList()
      : kCategories.where((c) => c.id != 'salary').toList();

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: kBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type Toggle
          Row(children: [
            Expanded(child: _typeBtn('expense', '⬆ Kharch', kRed)),
            const SizedBox(width: 8),
            Expanded(child: _typeBtn('income', '⬇ Aaya', kGreen)),
          ]),
          const SizedBox(height: 14),

          // Amount
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Amount (₹)', style: TextStyle(fontSize: 12, color: kMuted)),
              const SizedBox(height: 8),
              TextField(
                controller: _amtCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kText),
                decoration: const InputDecoration(hintText: '0', border: InputBorder.none, filled: false),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Category
          const Text('Category', style: TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: _cats.map((c) {
              final sel = c.id == _selCat;
              return GestureDetector(
                onTap: () => setState(() => _selCat = c.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel ? kGreen.withOpacity(0.1) : kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? kGreen : kBorder),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(c.icon, size: 22, color: sel ? kGreen : kMuted),
                    const SizedBox(height: 4),
                    Text(c.name, style: TextStyle(fontSize: 9, color: sel ? kGreen : kMuted), textAlign: TextAlign.center),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Description
          const Text('Description', style: TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _descCtrl, decoration: const InputDecoration(hintText: 'Kya kharcha? (e.g. Zomato, Petrol)')),
          const SizedBox(height: 14),

          // Date
          const Text('Date', style: TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: kGreen, surface: kCard)),
                  child: child!,
                ),
              );
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: kMuted),
                const SizedBox(width: 10),
                Text(fmtDate(_date), style: const TextStyle(color: kText)),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(_amtCtrl.text);
              final desc = _descCtrl.text.trim();
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Amount daalo!'), backgroundColor: kRed));
                return;
              }
              if (desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Description daalo!'), backgroundColor: kRed));
                return;
              }
              state.addTransaction(Transaction(
                id: state.newId(), type: _type, cat: _selCat,
                desc: desc, amount: amt, date: _date,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Transaction save ho gaya!'), backgroundColor: kGreen, behavior: SnackBarBehavior.floating));
              Navigator.pop(context);
            },
            child: const Text('✓ Save Karo'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _typeBtn(String type, String label, Color color) {
    final sel = _type == type;
    return GestureDetector(
      onTap: () => setState(() { _type = type; _selCat = type == 'income' ? 'salary' : 'food'; }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.15) : kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? color : kBorder),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? color : kMuted)),
      ),
    );
  }
}
