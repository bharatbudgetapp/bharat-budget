import 'package:flutter/material.dart';
import 'dart:math';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  // SIP Calculator
  double sipAmount = 9000;
  double sipYears = 14;

  // FD Calculator
  double fdAmount = 50000;
  double fdMonths = 60;
  final TextEditingController _fdController = TextEditingController(text: '50000');

  double calculateSIP(double monthly, double years, double rate) {
    double r = rate / 12 / 100;
    int n = (years * 12).toInt();
    return monthly * ((pow(1 + r, n) - 1) / r) * (1 + r);
  }

  double calculateFD(double principal, double months, double rate) {
    double years = months / 12;
    return principal * pow(1 + rate / 100, years);
  }

  @override
  Widget build(BuildContext context) {
    double sipTotal = calculateSIP(sipAmount, sipYears, 12);
    double sipInvested = sipAmount * sipYears * 12;
    double sipReturns = sipTotal - sipInvested;

    double fdMaturity = calculateFD(fdAmount, fdMonths, 6.5);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invest 📈',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text('Grow your money smartly',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),

            // ── 1. POPULAR INVESTMENTS (TOP) ──────────────────────────────
            const Text('POPULAR INVESTMENTS',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),

            _investCard(Icons.currency_rupee, const Color(0xFFFF8A65),
                'Mutual Funds — SIP', 'Start from ₹500', '12-15%', 'avg returns', const Color(0xFF00C897)),
            _investCard(Icons.account_balance, const Color(0xFF42A5F5),
                'PPF — Public Provident Fund', 'Tax free, safe investment', '7.1%', 'guaranteed', const Color(0xFF00C897)),
            _investCard(Icons.star, const Color(0xFFFFD700),
                'Digital Gold', 'Buy gold from ₹1', 'Varies', 'market rate', const Color(0xFFFFD700)),
            _investCard(Icons.bar_chart, const Color(0xFF7E57C2),
                'NPS — National Pension', 'For your retirement', '8-10%', 'avg returns', const Color(0xFF7E57C2)),

            const SizedBox(height: 20),

            // ── 2. SIP CALCULATOR (MIDDLE) ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2D40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFF00C897), size: 20),
                      SizedBox(width: 6),
                      Text('SIP Calculator',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Monthly Investment Slider
                  const Text('Monthly Investment',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00C897),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00C897),
                      overlayColor: const Color(0xFF00C897).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: sipAmount,
                      min: 500,
                      max: 20000,
                      onChanged: (v) => setState(() => sipAmount = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('₹500', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('₹${sipAmount.toInt()}',
                          style: const TextStyle(
                              color: Color(0xFF00C897),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const Text('₹20,000', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Duration Slider
                  const Text('Duration (Years)',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00C897),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00C897),
                      overlayColor: const Color(0xFF00C897).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: sipYears,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setState(() => sipYears = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1 yr', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('${sipYears.toInt()} yrs',
                          style: const TextStyle(
                              color: Color(0xFF00C897),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const Text('30 yrs', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SIP Result
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C897), Color(0xFF0088CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('You Invest',
                                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  '₹${_formatAmount(sipInvested)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('You Earn',
                                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  '₹${_formatAmount(sipReturns)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Total Value (12% p.a. estimated)',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatAmount(sipTotal)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 3. FD CALCULATOR (BOTTOM) ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2D40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.home_work, color: Color(0xFF00C897), size: 20),
                      SizedBox(width: 6),
                      Text('FD Calculator',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('FD Amount (₹)',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fdController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (v) {
                      setState(() => fdAmount = double.tryParse(v) ?? 50000);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Duration (months)',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00C897),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00C897),
                    ),
                    child: Slider(
                      value: fdMonths,
                      min: 3,
                      max: 60,
                      onChanged: (v) => setState(() => fdMonths = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3m', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('${fdMonths.toInt()} months',
                          style: const TextStyle(
                              color: Color(0xFF00C897),
                              fontWeight: FontWeight.bold)),
                      const Text('60m', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Maturity Amount (6.5% p.a.)',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${fdMaturity.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFF00C897),
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _investCard(IconData icon, Color iconColor, String title,
      String subtitle, String returns, String returnLabel, Color returnColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(returns,
                  style: TextStyle(
                      color: returnColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(returnLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}