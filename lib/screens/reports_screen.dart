import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state.dart';
import '../theme.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedMonth = 'April';
  String _selectedYear = '2026';

  final List<String> _years = ['2024', '2025', '2026', '2027'];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Monthly trend data (Kharch, Income) for last 6 months
  final List<Map<String, dynamic>> _trendData = [
    {'month': 'Nov', 'kharch': 32000.0, 'income': 70000.0},
    {'month': 'Dec', 'kharch': 35000.0, 'income': 70000.0},
    {'month': 'Jan', 'kharch': 30000.0, 'income': 75000.0},
    {'month': 'Feb', 'kharch': 38000.0, 'income': 75000.0},
    {'month': 'Mar', 'kharch': 44800.0, 'income': 80000.0},
    {'month': 'Apr', 'kharch': 48000.0, 'income': 80000.0},
  ];

  // Category data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Health',   'amount': 5000.0,  'color': Color(0xFF4a9eff), 'emoji': '💊'},
    {'name': 'Other',    'amount': 10000.0, 'color': Color(0xFFffb830), 'emoji': '📦'},
    {'name': 'Food',     'amount': 2030.0,  'color': Color(0xFFff5252), 'emoji': '🍔'},
    {'name': 'Travel',   'amount': 1150.0,  'color': Color(0xFFffd740), 'emoji': '🚗'},
    {'name': 'Shopping', 'amount': 2300.0,  'color': Color(0xFF9c27b0), 'emoji': '🛍'},
    {'name': 'Bills',    'amount': 1800.0,  'color': Color(0xFF00d4a0), 'emoji': '⚡'},
    {'name': 'Fun',      'amount': 500.0,   'color': Color(0xFFff9800), 'emoji': '🎬'},
  ];

  double get _totalKharch =>
      _categories.fold(0, (sum, c) => sum + (c['amount'] as double));

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allTxn = state.transactions;
    final income = state.totalIncome;
    final saved = income - _totalKharch;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          children: [

            // ── HEADER ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('Reports ',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kText)),
                        const Text('📊',
                            style: TextStyle(fontSize: 20)),
                      ]),
                      const SizedBox(height: 2),
                      const Text('Spending analysis',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: kMuted)),
                    ],
                  ),
                ],
              ),
            ),

            // ── YEAR DROPDOWN + MONTH FILTER CHIPS ──────
            Row(
              children: [
                // Year Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGreen.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      dropdownColor: kCard2,
                      style: const TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: kGreen, size: 18),
                      items: _years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Month Chips
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _months.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final m = _months[i];
                        final isSelected = _selectedMonth == m;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMonth = m),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? kGreen : kCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? kGreen
                                    : Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              m,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.black : kMuted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SUMMARY CARDS ────────────────────────────
            Row(children: [
              Expanded(child: _summaryCard('₹${(_totalKharch / 1000).toStringAsFixed(0)}K', 'Expenses', kRed)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('₹${(saved / 1000).toStringAsFixed(0)}K', 'Savings', kGreen)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('${allTxn.length}', 'Transactions', kAmber)),
            ]),
            const SizedBox(height: 14),

            // ── CATEGORY BREAKDOWN (DONUT) ───────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category Breakdown',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kText)),
                  const SizedBox(height: 16),

                  // Donut Chart
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: _categories.map((cat) {
                          final pct = (cat['amount'] as double) / _totalKharch;
                          return PieChartSectionData(
                            value: cat['amount'] as double,
                            color: cat['color'] as Color,
                            radius: 40,
                            title: pct > 0.08
                                ? '${(pct * 100).toStringAsFixed(0)}%'
                                : '',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legend
                  ..._buildLegend(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── MONTHLY TREND BAR CHART ──────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Trend',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kText)),
                  const SizedBox(height: 8),

                  // Legend
                  Row(children: [
                    _legendDot(kRed, 'Kharch'),
                    const SizedBox(width: 16),
                    _legendDot(kGreen, 'Income'),
                  ]),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 90000,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx < 0 || idx >= _trendData.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _trendData[idx]['month'] as String,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: kMuted,
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20000,
                              getTitlesWidget: (val, meta) => Text(
                                '₹${(val / 1000).toInt()}K',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600),
                              ),
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20000,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withOpacity(0.06),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _trendData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: d['kharch'] as double,
                                color: kRed,
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: d['income'] as double,
                                color: kGreen,
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── CATEGORY WISE GRID ───────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 10),
              child: Text('CATEGORY WISE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                      letterSpacing: 1.4)),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: _categories
                  .map((cat) => _categoryCard(cat))
                  .toList(),
            ),
            const SizedBox(height: 14),

            // ── ALL TRANSACTIONS ─────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Transactions',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kText)),
                  const SizedBox(height: 8),
                  ...allTxn.asMap().entries.map((entry) {
                    final isLast = entry.key == allTxn.length - 1;
                    return Column(children: [
                      _txnRow(entry.value),
                      if (!isLast)
                        const Divider(color: Colors.white10, height: 1),
                    ]);
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

  // ── HELPER WIDGETS ───────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: child,
      );

  Widget _summaryCard(String value, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    color: kMuted,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _categoryCard(Map<String, dynamic> cat) {
    final color = cat['color'] as Color;
    final amount = cat['amount'] as double;
    final maxAmt = 10000.0;
    final pct = (amount / maxAmt).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cat['emoji'] as String,
              style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Text(cat['name'] as String,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kMuted)),
          const SizedBox(height: 2),
          Text(
            '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kText),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegend() {
    final rows = <Widget>[];
    for (var i = 0; i < _categories.length; i += 2) {
      final left = _categories[i];
      final right = i + 1 < _categories.length ? _categories[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: _legendItem(left)),
            if (right != null) Expanded(child: _legendItem(right)),
          ]),
        ),
      );
    }
    return rows;
  }

  Widget _legendItem(Map<String, dynamic> cat) => Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cat['color'] as Color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(cat['name'] as String,
            style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text(
          '₹${(cat['amount'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: const TextStyle(
              fontSize: 12, color: kText, fontWeight: FontWeight.w700),
        ),
      ]);

  Widget _legendDot(Color color, String label) => Row(children: [
        Container(
          width: 28,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: kMuted, fontWeight: FontWeight.w600)),
      ]);

  Widget _txnRow(Transaction t) {
    final cat = catById(t.cat);
    final isExp = t.type == 'expense';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: cat.color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(cat.icon, size: 18, color: cat.color),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(t.desc,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kText)),
              const SizedBox(height: 2),
              Text('${fmtDate(t.date)} · ${cat.name}',
                  style: const TextStyle(fontSize: 11, color: kMuted)),
            ])),
        Text(
          '${isExp ? '-' : '+'}${fmtFull(t.amount)}',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isExp ? kRed : kGreen),
        ),
      ]),
    );
  }
}