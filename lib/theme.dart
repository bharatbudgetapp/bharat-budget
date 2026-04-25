import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBg = Color(0xFF090f1c);
const kBg2 = Color(0xFF101827);
const kCard = Color(0xFF131f33);
const kCard2 = Color(0xFF1a2840);
const kGreen = Color(0xFF00d4a0);
const kGreen2 = Color(0xFF00a87e);
const kRed = Color(0xFFff5252);
const kAmber = Color(0xFFffb830);
const kBlue = Color(0xFF4a9eff);
const kPurple = Color(0xFF8b5cf6);
const kText = Color(0xFFe2eaf5);
const kMuted = Color(0xFF6b809a);
const kMuted2 = Color(0xFF8fa3be);
const kBorder = Color(0x12ffffff);

const List<Color> kAvatarColors = [kGreen, kBlue, kPurple, kAmber, kRed, Color(0xFFf97316)];

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kGreen,
      secondary: kBlue,
      surface: kCard,
      error: kRed,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: kText,
      displayColor: kText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kCard2,
      selectedItemColor: kGreen,
      unselectedItemColor: kMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCard2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGreen),
      ),
      hintStyle: const TextStyle(color: kMuted),
      labelStyle: const TextStyle(color: kMuted, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

// Helper widgets
Widget kDivider() => const Divider(color: kBorder, height: 1);

BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? kBorder),
    );

Widget badge(String text, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );

String fmtMoney(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
  return '₹${v.toStringAsFixed(0)}';
}

String fmtFull(double v) {
  final s = v.abs().toStringAsFixed(0);
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && (count == 3 || (count > 3 && (count - 3) % 2 == 0))) buf.write(',');
    buf.write(s[i]);
    count++;
  }
  return '₹${buf.toString().split('').reversed.join()}';
}

String fmtDate(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

Widget avatarCircle(String name, Color color, {double size = 42, double fontSize = 16}) {
  final initials = name.trim().split(' ').map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  final show = initials.length > 2 ? initials.substring(0, 2) : initials;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Center(
      child: Text(show, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.black)),
    ),
  );
}
