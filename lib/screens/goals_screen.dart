import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Map<String, dynamic>> goals = [
    {
      'name': 'iPhone 15',
      'icon': Icons.phone_iphone,
      'iconColor': Color(0xFF42A5F5),
      'monthly': 500,
      'saved': 73000,
      'target': 79900,
    },
    {
      'name': 'Goa Trip',
      'icon': Icons.beach_access,
      'iconColor': Color(0xFFFF8A65),
      'monthly': 2000,
      'saved': 8000,
      'target': 25000,
    },
    {
      'name': 'Emergency Fund',
      'icon': Icons.shield,
      'iconColor': Color(0xFF00C897),
      'monthly': 5000,
      'saved': 35000,
      'target': 100000,
    },
  ];

  String _timeLeft(int saved, int target, int monthly) {
    if (monthly <= 0) return '';
    int remaining = target - saved;
    if (remaining <= 0) return 'Completed!';
    int months = (remaining / monthly).ceil();
    int years = months ~/ 12;
    int rem = months % 12;
    if (years > 0 && rem > 0) return '$years yr $rem mo';
    if (years > 0) return '$years yr';
    return '$rem months';
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final monthlyController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2D40),
        title: const Text('New Goal', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameController, 'Goal name'),
            const SizedBox(height: 10),
            _dialogField(targetController, 'Target Amount (₹)', isNumber: true),
            const SizedBox(height: 10),
            _dialogField(monthlyController, 'Monthly Saving (₹)', isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C897)),
            onPressed: () {
              setState(() {
                goals.add({
                  'name': nameController.text,
                  'icon': Icons.flag,
                  'iconColor': const Color(0xFF00C897),
                  'monthly': int.tryParse(monthlyController.text) ?? 0,
                  'saved': 0,
                  'target': int.tryParse(targetController.text) ?? 0,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2D40),
        title: Text('Add Money — ${goals[index]['name']}',
            style: const TextStyle(color: Colors.white)),
        content: _dialogField(controller, 'Amount (₹)', isNumber: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C897)),
            onPressed: () {
              setState(() {
                goals[index]['saved'] += int.tryParse(controller.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── NEW: Delete confirmation dialog ──────────────────────────────────────
  void _showDeleteConfirmation(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2D40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFF4757), size: 26),
            SizedBox(width: 8),
            Text('Delete Goal',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${goals[index]['name']}"?\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, Keep It',
              style: TextStyle(
                  color: Color(0xFF00C897), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => goals.removeAt(index));
    }
  }

  Widget _dialogField(TextEditingController c, String hint, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTarget = goals.fold(0, (s, g) => s + (g['target'] as int));
    int totalSaved = goals.fold(0, (s, g) => s + (g['saved'] as int));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goals 🎯',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Your saving targets',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                GestureDetector(
                  onTap: _showAddGoalDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C897),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('+ New Goal',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Summary Card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C897), Color(0xFF0088CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Total Goals', '${goals.length}'),
                  _summaryItem('Saved', '₹${_fmt(totalSaved)}'),
                  _summaryItem('Target', '₹${_fmt(totalTarget)}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── ALL GOALS cards ──
            const Text('ALL GOALS',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),

            ...goals.asMap().entries.map((entry) {
              int i = entry.key;
              Map<String, dynamic> g = entry.value;
              double pct = ((g['saved'] as int) / (g['target'] as int)).clamp(0.0, 1.0);
              String timeLeft = _timeLeft(g['saved'], g['target'], g['monthly']);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2D40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (g['iconColor'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(g['icon'] as IconData,
                              color: g['iconColor'] as Color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g['name'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                '₹${_fmt(g['monthly'])}/month → $timeLeft',
                                style: const TextStyle(
                                    color: Color(0xFF00C897), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(g['iconColor'] as Color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${_fmt(g['saved'])} / ₹${_fmt(g['target'])}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('${(pct * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: g['iconColor'] as Color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showAddMoneyDialog(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C897),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('+ Add Money',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ── Delete button with confirmation ──
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showDeleteConfirmation(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4757),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('Delete',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // ── Goals Breakdown ──
            const SizedBox(height: 20),
            const Text('GOALS BREAKDOWN',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2D40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...goals.map((g) {
                    double pct = ((g['saved'] as int) / (g['target'] as int)).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(g['icon'] as IconData,
                                    color: g['iconColor'] as Color, size: 16),
                                const SizedBox(width: 6),
                                Text(g['name'],
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ]),
                              Text('${(pct * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      color: g['iconColor'] as Color,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(g['iconColor'] as Color),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₹${_fmt(g['saved'])} invested',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              Text('₹${_fmt(g['target'])} target',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  String _fmt(int amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return '$amount';
  }
}