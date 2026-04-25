import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';
import '../models/models.dart';

// ── LANGUAGE MODEL ────────────────────────────────────────────────────────────
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// Top 10 World Languages (English default, Hindi 2nd, Marathi 3rd, Urdu 4th)
const List<AppLanguage> kLanguages = [
  AppLanguage(code: 'en', name: 'English',    nativeName: 'English',    flag: '🇬🇧'),
  AppLanguage(code: 'hi', name: 'Hindi',      nativeName: 'हिंदी',       flag: '🇮🇳'),
  AppLanguage(code: 'mr', name: 'Marathi',    nativeName: 'मराठी',       flag: '🇮🇳'),
  AppLanguage(code: 'ur', name: 'Urdu',       nativeName: 'اردو',        flag: '🇵🇰'),
  AppLanguage(code: 'zh', name: 'Chinese',    nativeName: '中文',         flag: '🇨🇳'),
  AppLanguage(code: 'es', name: 'Spanish',    nativeName: 'Español',     flag: '🇪🇸'),
  AppLanguage(code: 'ar', name: 'Arabic',     nativeName: 'العربية',     flag: '🇸🇦'),
  AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português',   flag: '🇧🇷'),
  AppLanguage(code: 'fr', name: 'French',     nativeName: 'Français',    flag: '🇫🇷'),
  AppLanguage(code: 'de', name: 'German',     nativeName: 'Deutsch',     flag: '🇩🇪'),
];

// ── HOME SCREEN ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = 'This Month';

  // Default language: English
  AppLanguage _selectedLanguage = kLanguages[0];

  final List<Map<String, dynamic>> _periodOptions = [
    {'label': 'This Month', 'icon': Icons.calendar_today},
    {'label': 'This Year',  'icon': Icons.calendar_month},
    {'divider': true},
    {'label': 'January',   'icon': Icons.circle, 'month': 1},
    {'label': 'February',  'icon': Icons.circle, 'month': 2},
    {'label': 'March',     'icon': Icons.circle, 'month': 3},
    {'label': 'April',     'icon': Icons.circle, 'month': 4},
    {'label': 'May',       'icon': Icons.circle, 'month': 5},
    {'label': 'June',      'icon': Icons.circle, 'month': 6},
    {'label': 'July',      'icon': Icons.circle, 'month': 7},
    {'label': 'August',    'icon': Icons.circle, 'month': 8},
    {'label': 'September', 'icon': Icons.circle, 'month': 9},
    {'label': 'October',   'icon': Icons.circle, 'month': 10},
    {'label': 'November',  'icon': Icons.circle, 'month': 11},
    {'label': 'December',  'icon': Icons.circle, 'month': 12},
  ];

  // ── PERIOD PICKER ─────────────────────────────────────────────────────────
  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: kMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _periodOptions.length,
                itemBuilder: (ctx, i) {
                  final opt = _periodOptions[i];

                  if (opt['divider'] == true) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white10, height: 1),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
                          child: Text(
                            'MONTH WISE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kMuted,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final label      = opt['label'] as String;
                  final isSelected = _selectedPeriod == label;
                  final isMonth    = opt.containsKey('month');

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedPeriod = label);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      color: isSelected ? kGreen.withOpacity(0.08) : Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kGreen.withOpacity(0.18)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isMonth
                                  ? Text(
                                      '${opt['month']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? kGreen : kMuted,
                                      ),
                                    )
                                  : Icon(
                                      opt['icon'] as IconData,
                                      size: 16,
                                      color: isSelected ? kGreen : kMuted,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? kGreen : kText,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: kGreen, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ── LANGUAGE PICKER ───────────────────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: kMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language, size: 16, color: kGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: kLanguages.length,
                itemBuilder: (ctx, i) {
                  final lang = kLanguages[i];
                  final isSelected = _selectedLanguage.code == lang.code;
                  final showDivider = i == 4;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDivider) ...[
                        const Divider(color: Colors.white10, height: 1),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 10, bottom: 4),
                          child: Text(
                            'WORLD LANGUAGES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kMuted,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                      if (i == 0)
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 10, bottom: 4),
                          child: Text(
                            'INDIAN LANGUAGES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kMuted,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          setState(() => _selectedLanguage = lang);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: isSelected
                              ? kGreen.withOpacity(0.08)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kGreen.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    lang.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected ? kGreen : kText,
                                      ),
                                    ),
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? kGreen.withOpacity(0.7)
                                            : kMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (lang.code == 'en' && !isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: kMuted,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: kGreen, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    final income  = state.totalIncome;
    final expense = state.totalExpense;
    final pct     = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;
    final recent  = state.transactions.take(5).toList();

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
                  // App title — भारत Budget naam unchanged
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kText),
                          children: [
                            TextSpan(text: 'भारत '),
                            TextSpan(
                                text: 'Budget',
                                style: TextStyle(color: kGreen)),
                            TextSpan(text: ' 💰'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Your Financial Manager',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: kMuted),
                      ),
                    ],
                  ),

                  // ── LANGUAGE BUTTON ──────────────────
                  GestureDetector(
                    onTap: _showLanguagePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: kCard2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: kGreen.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language,
                              size: 14, color: kGreen),
                          const SizedBox(width: 5),
                          Text(
                            _selectedLanguage.flag,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedLanguage.code.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: kText,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 14, color: kGreen),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── CASH FLOW CARD ───────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CASH FLOW',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kMuted,
                              letterSpacing: 1.3)),
                      GestureDetector(
                        onTap: _showPeriodPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kCard2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: kGreen.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedPeriod,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: kText,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 14, color: kGreen),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SPENDING',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: kRed,
                                    letterSpacing: 1)),
                            Text(fmtFull(expense),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: kText)),
                            const Text('↑ ₹3,200 more than last month',
                                style: TextStyle(fontSize: 11, color: kMuted)),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('INCOME',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: kGreen,
                                    letterSpacing: 1)),
                            Text(fmtFull(income),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: kText)),
                            const Text('✓ Salary received',
                                style:
                                    TextStyle(fontSize: 11, color: kGreen)),
                          ]),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── SALARY USAGE ─────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SALARY USAGE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kMuted,
                          letterSpacing: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: kText),
                                children: [
                                  TextSpan(
                                      text:
                                          '${(pct * 100).toStringAsFixed(0)}% '),
                                  const TextSpan(
                                      text: 'spent',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: kRed,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            const Text('10 days remaining this month',
                                style:
                                    TextStyle(fontSize: 11, color: kMuted)),
                          ]),
                      _badgeWidget(
                          '⚠ Warning', const Color(0x26ffb830), kAmber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(kRed),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Spent: ${fmtFull(expense)}',
                          style:
                              const TextStyle(fontSize: 11, color: kMuted)),
                      Text('Salary: ${fmtFull(income)}',
                          style:
                              const TextStyle(fontSize: 11, color: kMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── AI INSIGHTS ──────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                          color: kBlue,
                          borderRadius: BorderRadius.circular(7)),
                      child: const Icon(Icons.smart_toy,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('AI Smart Insights',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kText)),
                  ]),
                  const SizedBox(height: 12),
                  _insightRow(
                      Icons.fastfood,
                      const Color(0x1Fff5252),
                      'Food spending up by 40%',
                      '₹1,400 more than last month',
                      '+40%',
                      kRed),
                  const Divider(color: Colors.white10, height: 1),
                  _insightRow(
                      Icons.savings,
                      const Color(0x1A00d4a0),
                      'Save ₹500/month',
                      'Get an iPhone in 2 years!',
                      'Goal',
                      kGreen),
                  const Divider(color: Colors.white10, height: 1),
                  _insightRow(
                      Icons.warning_amber,
                      const Color(0x1Affb830),
                      'Salary running low',
                      'May run out in 10 days',
                      'Alert',
                      kAmber),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── SAVING GOAL ──────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SAVING GOAL',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kMuted,
                          letterSpacing: 1.3)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: const Color(0x1A4a9eff),
                          borderRadius: BorderRadius.circular(13)),
                      child: const Center(
                          child: Text('📱',
                              style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('iPhone 15 — ₹79,900',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          SizedBox(height: 2),
                          Text('₹500/month → 2 yrs 8 months',
                              style:
                                  TextStyle(fontSize: 12, color: kGreen)),
                        ]),
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 12000 / 79900,
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(kGreen),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Saved so far: ₹12,000 / ₹79,900',
                      style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── RECENT TRANSACTIONS ──────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Transactions',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kText)),
                      Text('View All →',
                          style: TextStyle(
                              fontSize: 12,
                              color: kGreen,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recent.asMap().entries.map((entry) {
                    final isLast = entry.key == recent.length - 1;
                    return Column(children: [
                      _txnRow(entry.value),
                      if (!isLast)
                        const Divider(color: Colors.white10, height: 1),
                    ]);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── AI TIPS ──────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 8),
              child: Text('AI TIPS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                      letterSpacing: 1.4)),
            ),
            _tip('💡 Saving Tip', kGreen,
                'Skip eating out once — save ₹950!'),
            const SizedBox(height: 8),
            _tip('⚠ Alert', kAmber,
                'At this rate your salary may run out in 10 days!'),
            const SizedBox(height: 8),
            _tip('📈 Invest Suggestion', kBlue,
                'Start a ₹2,000/month SIP — grow to ₹3.5 lakh in 10 years!'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: child,
      );

  Widget _badgeWidget(String text, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: fg)),
      );

  Widget _insightRow(IconData icon, Color iconBg, String title,
          String sub, String badgeText, Color badgeColor) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: badgeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kText)),
                const SizedBox(height: 2),
                Text(sub,
                    style:
                        const TextStyle(fontSize: 11, color: kMuted)),
              ])),
          _badgeWidget(
              badgeText, badgeColor.withOpacity(0.15), badgeColor),
        ]),
      );

  Widget _txnRow(Transaction t) {
    final cat   = catById(t.cat);
    final isExp = t.type == 'expense';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Container(
          width: 40, height: 40,
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

  Widget _tip(String label, Color color, String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(13),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 12, color: kMuted2, height: 1.6)),
        ]),
      );
}