import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'state.dart';
import 'screens/home_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/invest_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/people_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(
    ChangeNotifierProvider.value(value: state, child: const BharatBudgetApp()),
  );
}

class BharatBudgetApp extends StatelessWidget {
  const BharatBudgetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'भारत Budget',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const MainShell(),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final _screens = const [
    HomeScreen(),
    ReportsScreen(),
    InvestScreen(),
    GoalsScreen(),
    PeopleScreen(),
    AccountsScreen(),
  ];

  void _openProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfilePanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _idx == 3
          ? null
          : AppBar(
              backgroundColor: kBg,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: _openProfile,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF1ABC9C),
                      radius: 18,
                      child: Text(
                        'S',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        backgroundColor: kCard2,
        selectedItemColor: kGreen,
        unselectedItemColor: kMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded), label: 'Invest'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded), label: 'Goals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'People'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_rounded), label: 'Accounts'),
        ],
      ),
      floatingActionButton: _idx == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen())),
              backgroundColor: kGreen,
              foregroundColor: Colors.black,
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }
}

// ─── Profile Panel ────────────────────────────────────────────────────────────
class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key});
  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  bool _salaryAlert = true;
  bool _dailyReminder = true;
  bool _aiTips = true;
  bool _darkMode = true;

  final String _name = 'Sabbir Hussain';
  final String _email = 'sabbir@gmail.com';
  final String _income = '₹80,000';
  final String _budgetLimit = '₹50,000';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B949E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF1ABC9C),
                    child: Text(
                      _name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_email,
                      style: const TextStyle(
                          color: Color(0xFF8B949E), fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF2ECC71).withOpacity(0.4)),
                    ),
                    child: const Text('Premium Member ✓',
                        style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                  _infoRow('💰', 'Monthly Income', _income,
                      const Color(0xFF2ECC71)),
                  _infoRow('🎯', 'Budget Limit', _budgetLimit,
                      const Color(0xFFF39C12)),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF30363D)),
                  const SizedBox(height: 8),
                  _toggleRow('🔔', 'Salary Alert', _salaryAlert,
                      (v) => setState(() => _salaryAlert = v)),
                  _toggleRow('📅', 'Daily Reminder', _dailyReminder,
                      (v) => setState(() => _dailyReminder = v)),
                  _toggleRow('🤖', 'AI Tips', _aiTips,
                      (v) => setState(() => _aiTips = v)),
                  _toggleRow('🌙', 'Dark Mode', _darkMode,
                      (v) => setState(() => _darkMode = v)),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF30363D)),
                  const SizedBox(height: 8),
                  _menuRow('🔒', 'Privacy'),
                  _menuRow('📱', 'Version',
                      trailing: const Text('v1.0.0 Beta',
                          style: TextStyle(
                              color: Color(0xFF8B949E), fontSize: 13))),
                  _menuRow('☁️', 'Data Sync',
                      trailing: const Text('✓ Synced',
                          style: TextStyle(
                              color: Color(0xFF2ECC71), fontSize: 13))),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF30363D)),
                  const SizedBox(height: 8),
                  _menuRow('🚪', 'Logout',
                      labelColor: const Color(0xFFE74C3C)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 15))),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _toggleRow(
      String icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 15))),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2ECC71)),
        ],
      ),
    );
  }

  Widget _menuRow(String icon, String label,
      {Color? labelColor, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: labelColor ?? Colors.white, fontSize: 15))),
          trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF8B949E)),
        ],
      ),
    );
  }
}