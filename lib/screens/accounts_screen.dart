import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../state.dart';
import '../theme.dart';

const kOrange = Color(0xFFF39C12);
const kTeal = Color(0xFF1ABC9C);

// ─── IMPORTANT: Apni real API key yahan dalo ─────────────────────────────────
const String kClaudeApiKey = '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';
// ─────────────────────────────────────────────────────────────────────────────

// ─── Data Models ─────────────────────────────────────────────────────────────

class BankAccount {
  String name;
  String type;
  String last4;
  double balance;
  Color color;
  IconData icon;

  BankAccount({
    required this.name,
    required this.type,
    required this.last4,
    required this.balance,
    required this.color,
    required this.icon,
  });
}

class AnalysisCategory {
  final String name;
  final String emoji;
  final int count;
  final double amount;
  final Color color;
  final List<Map<String, dynamic>> transactions;

  AnalysisCategory({
    required this.name,
    required this.emoji,
    required this.count,
    required this.amount,
    required this.color,
    this.transactions = const [],
  });
}

class PersonTransfer {
  final String name;
  final int count;
  final double amount;
  PersonTransfer({required this.name, required this.count, required this.amount});
}

class StatementAnalysis {
  final double totalIn;
  final double totalOut;
  final double netSavings;
  final double totalInvested;
  final double totalCharges;
  final double totalSubscriptions;
  final int totalTransactions;
  final List<AnalysisCategory> categories;
  final List<PersonTransfer> people;
  final List<Map<String, dynamic>> unusualTransactions;
  final List<Map<String, dynamic>> subscriptions;
  final List<Map<String, dynamic>> investments;
  final List<Map<String, dynamic>> charges;
  final Map<String, double> monthlyTrend;

  StatementAnalysis({
    required this.totalIn,
    required this.totalOut,
    required this.netSavings,
    required this.totalInvested,
    required this.totalCharges,
    required this.totalSubscriptions,
    required this.totalTransactions,
    required this.categories,
    required this.people,
    required this.unusualTransactions,
    required this.subscriptions,
    required this.investments,
    required this.charges,
    required this.monthlyTrend,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with TickerProviderStateMixin {
  bool _showBalance = false;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  String _analysisStatus = '';
  StatementAnalysis? _analysis;
  double _cashInHand = 0;
  double _uploadProgress = 0.0;

  PlatformFile? _selectedFile;
  String _selectedFileName = '';
  double _selectedFileSizeMB = 0;

  final Set<String> _expandedCategories = {};
  final Set<String> _expandedPeople = {}; // ← ADDED

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<BankAccount> _accounts = [
    BankAccount(
      name: 'SBI Bank Account',
      type: 'Savings',
      last4: '4521',
      balance: 1,
      color: kBlue,
      icon: Icons.account_balance_rounded,
    ),
    BankAccount(
      name: 'HDFC Credit Card',
      type: 'Credit',
      last4: '7834',
      balance: -15000,
      color: kRed,
      icon: Icons.credit_card_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  double get _totalBalance => _accounts
      .where((a) => a.type == 'Savings' || a.type == 'Current')
      .fold(0, (s, a) => s + a.balance);

  double get _totalCredit => _accounts
      .where((a) => a.type == 'Credit')
      .fold(0, (s, a) => s + a.balance.abs());

  // ─── Add Account Dialog ───────────────────────────────────────────────────
  void _showAddAccountDialog() {
    final nameCtrl = TextEditingController();
    final last4Ctrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String selectedType = 'Savings';
    Color selectedColor = kBlue;
    IconData selectedIcon = Icons.account_balance_rounded;

    final types = ['Savings', 'Current', 'Credit', 'Wallet'];
    final colorOptions = [kBlue, kGreen, kRed, kOrange, kPurple, kTeal];
    final iconOptions = [
      Icons.account_balance_rounded,
      Icons.credit_card_rounded,
      Icons.wallet_rounded,
      Icons.savings_rounded,
      Icons.payment_rounded,
      Icons.currency_rupee_rounded,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 16),
                const Text('Add New Account',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kText)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Account Name',
                      hintText: 'e.g. SBI Savings, HDFC Credit'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: kCard2,
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  items: types
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t,
                              style: const TextStyle(color: kText))))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: last4Ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                      labelText: 'Last 4 digits',
                      hintText: 'e.g. 4521',
                      counterText: ''),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  decoration: InputDecoration(
                    labelText: selectedType == 'Credit'
                        ? 'Outstanding Amount (₹)'
                        : 'Current Balance (₹)',
                    hintText:
                        selectedType == 'Credit' ? 'e.g. 15000' : 'e.g. 50000',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose Color:',
                    style: TextStyle(color: kMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: colorOptions.map((c) {
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2.5)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Choose Icon:',
                    style: TextStyle(color: kMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: iconOptions.map((ic) {
                    final isSelected = selectedIcon == ic;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = ic),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.3)
                              : kCard,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: selectedColor)
                              : null,
                        ),
                        child: Icon(ic,
                            color: isSelected ? selectedColor : kMuted,
                            size: 20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final last4 = last4Ctrl.text.trim().isEmpty
                        ? '0000'
                        : last4Ctrl.text.trim();
                    final balance = double.tryParse(balanceCtrl.text) ?? 0;
                    setState(() {
                      _accounts.add(BankAccount(
                        name: name,
                        type: selectedType,
                        last4: last4,
                        balance: selectedType == 'Credit'
                            ? -balance.abs()
                            : balance,
                        color: selectedColor,
                        icon: selectedIcon,
                      ));
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('✓ $name added successfully!'),
                          backgroundColor: kGreen,
                          behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: const Text('✓ Add Account'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Edit Account Dialog ──────────────────────────────────────────────────
  void _showEditAccountDialog(int index) {
    final acc = _accounts[index];
    final nameCtrl = TextEditingController(text: acc.name);
    final last4Ctrl = TextEditingController(text: acc.last4);
    final balanceCtrl =
        TextEditingController(text: acc.balance.abs().toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              Text('Edit ${acc.name}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kText)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Account Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: last4Ctrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                    labelText: 'Last 4 digits', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                decoration: InputDecoration(
                  labelText: acc.type == 'Credit'
                      ? 'Outstanding Amount (₹)'
                      : 'Current Balance (₹)',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final balance =
                            double.tryParse(balanceCtrl.text) ?? acc.balance;
                        setState(() {
                          _accounts[index].name = name;
                          _accounts[index].last4 = last4Ctrl.text.trim();
                          _accounts[index].balance = acc.type == 'Credit'
                              ? -balance.abs()
                              : balance;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✓ Account updated!'),
                              backgroundColor: kGreen,
                              behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: const Text('✓ Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kRed),
                    onPressed: () {
                      setState(() => _accounts.removeAt(index));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Account deleted!'),
                            backgroundColor: kRed,
                            behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Edit Cash Dialog ─────────────────────────────────────────────────────
  void _showEditCashDialog() {
    final cashCtrl =
        TextEditingController(text: _cashInHand.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              const Text('Update Cash in Hand',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kText)),
              const SizedBox(height: 16),
              TextField(
                controller: cashCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Cash Amount (₹)',
                    hintText: 'e.g. 5000'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(cashCtrl.text) ?? 0;
                  setState(() => _cashInHand = amount);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✓ Cash updated!'),
                        backgroundColor: kGreen,
                        behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('✓ Save Karo'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP 1: Only Pick File ───────────────────────────────────────────────
  Future<void> _uploadStatement() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'csv', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() {
      _selectedFile = file;
      _selectedFileName = file.name;
      _selectedFileSizeMB = (file.bytes?.length ?? 0) / (1024 * 1024);
      _analysisComplete = false;
      _analysis = null;
      _expandedCategories.clear();
      _expandedPeople.clear(); // ← ADDED
    });
  }

  // ─── STEP 2: Process / AI Analyze ────────────────────────────────────────
  Future<void> _processStatement() async {
    if (_selectedFile == null) return;

    if (kClaudeApiKey.isEmpty || kClaudeApiKey == 'YOUR_API_KEY_HERE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ API key set nahi hai! accounts_screen.dart mein kClaudeApiKey fill karein.'),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final file = _selectedFile!;
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
      _uploadProgress = 0.0;
      _analysisStatus = '📂 File load ho rahi hai...';
    });

    try {
      // Step 1: File read (0% → 20%)
      for (int i = 1; i <= 20; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
        if (mounted) setState(() => _uploadProgress = i / 100);
      }

      final fileBytes = List<int>.from(file.bytes ?? []);
      if (fileBytes.isEmpty) throw Exception('File empty hai ya read nahi hui');

      final fileSizeMB = _selectedFileSizeMB;
      debugPrint('📄 File size: ${fileSizeMB.toStringAsFixed(2)} MB');

      // Step 2: File save (20% → 35%)
      if (mounted) setState(() => _analysisStatus = '💾 File save ho rahi hai...');
      await _saveFileToDevice(file);
      for (int i = 21; i <= 35; i++) {
        await Future.delayed(const Duration(milliseconds: 25));
        if (mounted) setState(() => _uploadProgress = i / 100);
      }

      // Step 3: API bhejne ki tayyari (35% → 50%)
      if (mounted) setState(() => _analysisStatus = '📡 AI ko bhej raha hai...');
      for (int i = 36; i <= 50; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        if (mounted) setState(() => _uploadProgress = i / 100);
      }

      // Step 4: API call + parallel progress
      if (mounted) setState(() => _analysisStatus = '🤖 AI analyze kar raha hai...');

      StatementAnalysis? analysisResult;
      Object? apiError;
      bool apiDone = false;

      _analyzeWithClaude(
        fileBytes,
        file.extension?.toLowerCase() ?? 'pdf',
        file.name,
        fileSizeMB,
      ).then((r) {
        analysisResult = r;
        apiDone = true;
      }).catchError((e) {
        apiError = e;
        apiDone = true;
      });

      int prog = 50;
      int elapsedSeconds = 0;
      while (!apiDone) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        elapsedSeconds++;
        if (prog < 87) {
          prog++;
          setState(() => _uploadProgress = prog / 100);
        }
        if (elapsedSeconds % 10 == 0) {
          setState(() => _analysisStatus =
              '🤖 AI analyze kar raha hai... (${(elapsedSeconds / 2).toInt()}s)');
        }
      }

      if (apiError != null) {
        debugPrint('❌ API Error: $apiError');
        throw apiError!;
      }
      if (analysisResult == null) {
        throw Exception('Analysis result null aaya — please retry');
      }

      // Step 5: Report ready (88% → 100%)
      if (mounted) setState(() => _analysisStatus = '📊 Report tayyar ho rahi hai...');
      for (int i = 89; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 25));
        if (mounted) setState(() => _uploadProgress = i / 100);
      }

      if (!mounted) return;
      setState(() {
        _analysis = analysisResult;
        _isAnalyzing = false;
        _analysisComplete = true;
        _uploadProgress = 1.0;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _uploadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: kRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  // ─── File Save ────────────────────────────────────────────────────────────
  Future<void> _saveFileToDevice(PlatformFile file) async {
    try {
      if (file.path != null) return;
      if (file.bytes == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final statementsDir = Directory('${dir.path}/statements');
      await statementsDir.create(recursive: true);
      final savedFile = File('${statementsDir.path}/${file.name}');
      await savedFile.writeAsBytes(file.bytes!);
      debugPrint('✅ File saved: ${savedFile.path}');
    } catch (e) {
      debugPrint('⚠️ Save warning: $e');
    }
  }

  // ─── Claude API Call ──────────────────────────────────────────────────────
  Future<StatementAnalysis> _analyzeWithClaude(
      List<int> fileBytes, String ext, String fileName, double fileSizeMB) async {

    const analysisPrompt = '''You are an expert Indian bank statement analyzer.
Analyze ALL transactions in this bank statement. Return ONLY valid JSON — no markdown, no explanation.

CRITICAL: Analyze every single transaction. Do NOT skip any.

Categories: Food & Dining 🍔, Shopping 🛍️, Transport 🚗, Entertainment 🎬, Utilities & Bills 💡, Health & Medical 🏥, Education 📚, Investments 📈, Insurance 🛡️, Loan Repayment 🏦, Bank Charges 💸, Subscriptions 🔄, UPI Transfers 👤, ATM Withdrawal 💵, Salary/Income 💰, Other 📦

For "people": extract real names from UPI remarks (e.g. "UPI/RAHMAT HAW/..." → "Rahmat Haw").
For "unusualTransactions": any single transaction ≥ ₹10000.
For "monthlyTrend": sum of debits per month (e.g. {"Jan": 5000, "Feb": 8000}).

Return EXACTLY this JSON (no extra fields):
{
  "totalTransactions": <int>,
  "totalIn": <float>,
  "totalOut": <float>,
  "netSavings": <float>,
  "totalInvested": <float>,
  "totalCharges": <float>,
  "totalSubscriptions": <float>,
  "categories": [{"name":"<str>","emoji":"<str>","count":<int>,"amount":<float>,"transactions":[{"desc":"<str>","amount":<float>,"date":"<DD Mon>","type":"debit|credit"}]}],
  "people": [{"name":"<str>","count":<int>,"amount":<float>}],
  "investments": [{"name":"<str>","amount":<float>,"date":"<str>"}],
  "charges": [{"name":"<str>","amount":<float>,"date":"<str>"}],
  "subscriptions": [{"name":"<str>","amount":<float>,"date":"<str>"}],
  "unusualTransactions": [{"desc":"<str>","amount":<float>,"date":"<str>","type":"debit|credit"}],
  "monthlyTrend": {"<Mon>": <float>}
}''';

    const String modelName = 'claude-sonnet-4-6';
    const int maxTokens = 64000;

    Map<String, dynamic> requestBody;

    if (ext == 'csv') {
      final csvText = utf8.decode(fileBytes, allowMalformed: true);
      requestBody = {
        'model': modelName,
        'max_tokens': maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': '$analysisPrompt\n\nCSV Data:\n$csvText'}
            ]
          }
        ],
      };
    } else if (ext == 'pdf') {
      final base64Pdf = base64Encode(fileBytes);
      requestBody = {
        'model': modelName,
        'max_tokens': maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'document',
                'source': {
                  'type': 'base64',
                  'media_type': 'application/pdf',
                  'data': base64Pdf,
                },
              },
              {'type': 'text', 'text': analysisPrompt}
            ]
          }
        ],
      };
    } else {
      final base64Img = base64Encode(fileBytes);
      final mediaType = ext == 'png' ? 'image/png' : 'image/jpeg';
      requestBody = {
        'model': modelName,
        'max_tokens': maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mediaType,
                  'data': base64Img,
                },
              },
              {'type': 'text', 'text': analysisPrompt}
            ]
          }
        ],
      };
    }

    const int timeoutMinutes = 3;
    debugPrint('🚀 API call: model=$modelName, maxTokens=$maxTokens, size=${fileSizeMB.toStringAsFixed(2)}MB, timeout=${timeoutMinutes}min');

    final client = http.Client();
    late http.Response response;

    try {
      final postFuture = client.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': kClaudeApiKey,
          'anthropic-version': '2023-06-01',
          'anthropic-beta': 'pdfs-2024-09-25,output-128k-2025-02-19',
        },
        body: jsonEncode(requestBody),
      );

      final timeoutFuture = Future.delayed(
        const Duration(minutes: timeoutMinutes),
        () => throw Exception(
            'Timeout! 3 minute mein response nahi aaya. '
            'Dobara try karein ya CSV use karein.'),
      );

      response = await Future.any([postFuture, timeoutFuture]);
    } finally {
      client.close();
    }

    debugPrint('📡 Status: ${response.statusCode}, Body: ${response.body.length} chars');

    if (response.statusCode == 529) {
      throw Exception('Claude server overloaded hai. 1-2 minute baad retry karein.');
    }
    if (response.statusCode == 413) {
      throw Exception('PDF bahut bada hai (>${fileSizeMB.toStringAsFixed(0)}MB). Chhota PDF try karein.');
    }
    if (response.statusCode == 401) {
      throw Exception('API key galat hai. accounts_screen.dart mein kClaudeApiKey check karein.');
    }
    if (response.statusCode == 429) {
      throw Exception('Rate limit hit! Thodi der baad retry karein.');
    }
    if (response.statusCode != 200) {
      debugPrint('❌ API Error body: ${response.body}');
      Map<String, dynamic> errBody;
      try {
        errBody = jsonDecode(response.body);
      } catch (_) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
      final errMsg = errBody['error']?['message'] ?? response.body;
      throw Exception('API Error ${response.statusCode}: $errMsg');
    }

    final data = jsonDecode(response.body);

    final stopReason = data['stop_reason'] as String? ?? '';
    debugPrint('🛑 Stop reason: $stopReason');
    if (stopReason == 'max_tokens') {
      debugPrint('⚠️ Response truncated — attempting partial JSON recovery...');
    }

    final text = (data['content'] as List)
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('');

    debugPrint('📝 Response length: ${text.length} chars');

    var clean = text.trim()
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final jsonStart = clean.indexOf('{');
    if (jsonStart == -1) {
      throw Exception('AI ne JSON return nahi kiya. Dobara try karein.');
    }

    var jsonEnd = clean.lastIndexOf('}');

    if (stopReason == 'max_tokens' && jsonEnd < jsonStart) {
      clean = clean + ']}';
      jsonEnd = clean.lastIndexOf('}');
    }

    if (jsonEnd < jsonStart) {
      throw Exception('JSON incomplete hai (response truncated). Chhota PDF try karein.');
    }

    clean = clean.substring(jsonStart, jsonEnd + 1);

    Map<String, dynamic> json;
    try {
      json = jsonDecode(clean);
    } catch (e) {
      debugPrint('❌ JSON parse failed: $e');
      debugPrint('Last 300 chars: ...${clean.substring((clean.length - 300).clamp(0, clean.length))}');
      try {
        int openBrackets = 0;
        int openBraces = 0;
        bool inString = false;
        for (int i = 0; i < clean.length; i++) {
          final c = clean[i];
          if (c == '"' && (i == 0 || clean[i - 1] != '\\')) inString = !inString;
          if (!inString) {
            if (c == '[') openBrackets++;
            if (c == ']') openBrackets--;
            if (c == '{') openBraces++;
            if (c == '}') openBraces--;
          }
        }
        final lastComma = clean.lastIndexOf(',');
        if (lastComma > clean.length - 100) {
          clean = clean.substring(0, lastComma);
        }
        final suffix = ']' * openBrackets.clamp(0, 10) + '}' * openBraces.clamp(0, 10);
        json = jsonDecode(clean + suffix);
        debugPrint('✅ JSON recovery successful!');
      } catch (e2) {
        throw Exception('Response parse nahi hua. CSV try karein ya chhota PDF use karein.');
      }
    }

    return _parseAnalysis(json);
  }

  // ─── Parse Analysis ───────────────────────────────────────────────────────
  StatementAnalysis _parseAnalysis(Map<String, dynamic> j) {
    final colors = [
      kGreen, kBlue, kOrange, kPurple, kTeal, kRed,
      const Color(0xFFE74C3C), const Color(0xFF2ECC71)
    ];
    int ci = 0;

    final cats = (j['categories'] as List? ?? []).map((c) {
      final txns = (c['transactions'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t))
          .toList();

      final cat = AnalysisCategory(
        name: c['name'] ?? 'Other',
        emoji: c['emoji'] ?? '📦',
        count: (c['count'] as num?)?.toInt() ?? txns.length,
        amount: (c['amount'] as num?)?.toDouble() ?? 0,
        color: colors[ci % colors.length],
        transactions: txns,
      );
      ci++;
      return cat;
    }).toList();

    final people = (j['people'] as List? ?? []).map((p) => PersonTransfer(
          name: p['name'] ?? 'Unknown',
          count: (p['count'] as num?)?.toInt() ?? 0,
          amount: (p['amount'] as num?)?.toDouble() ?? 0,
        )).toList();

    final trend = <String, double>{};
    (j['monthlyTrend'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      trend[k] = (v as num).toDouble();
    });

    return StatementAnalysis(
      totalIn: (j['totalIn'] as num?)?.toDouble() ?? 0,
      totalOut: (j['totalOut'] as num?)?.toDouble() ?? 0,
      netSavings: (j['netSavings'] as num?)?.toDouble() ?? 0,
      totalInvested: (j['totalInvested'] as num?)?.toDouble() ?? 0,
      totalCharges: (j['totalCharges'] as num?)?.toDouble() ?? 0,
      totalSubscriptions: (j['totalSubscriptions'] as num?)?.toDouble() ?? 0,
      totalTransactions: (j['totalTransactions'] as num?)?.toInt() ?? 0,
      categories: cats,
      people: people,
      unusualTransactions:
          List<Map<String, dynamic>>.from(j['unusualTransactions'] ?? []),
      subscriptions: List<Map<String, dynamic>>.from(j['subscriptions'] ?? []),
      investments: List<Map<String, dynamic>>.from(j['investments'] ?? []),
      charges: List<Map<String, dynamic>>.from(j['charges'] ?? []),
      monthlyTrend: trend,
    );
  }

  String _fmt(double v) {
    final isNeg = v < 0;
    final abs = v.abs();
    final intPart = abs.toInt();
    final decPart = abs - intPart;

    final str = intPart.toString();
    String formatted;

    if (str.length <= 3) {
      formatted = str;
    } else {
      final last3 = str.substring(str.length - 3);
      var rest = str.substring(0, str.length - 3);
      final parts = <String>[];
      while (rest.length > 2) {
        parts.add(rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.add(rest);
      formatted = '${parts.reversed.join(',')},${last3}';
    }

    if (decPart > 0.005) {
      final paise = (decPart * 100).round();
      formatted = '$formatted.${paise.toString().padLeft(2, '0')}';
    }

    return '${isNeg ? '-' : ''}₹$formatted';
  }

  void _shareAnalysis() {
    if (_analysis == null) return;
    final a = _analysis!;

    final buffer = StringBuffer();
    buffer.writeln('📊 Bank Statement Analysis');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total Transactions: ${a.totalTransactions}');
    buffer.writeln('');
    buffer.writeln('💰 Summary');
    buffer.writeln('⬆️  Total In:        ${_fmt(a.totalIn)}');
    buffer.writeln('⬇️  Total Out:       ${_fmt(a.totalOut)}');
    buffer.writeln('💵 Net Savings:     ${_fmt(a.netSavings)}');
    buffer.writeln('📈 Invested:        ${_fmt(a.totalInvested)}');
    buffer.writeln('💸 Charges:         ${_fmt(a.totalCharges)}');
    buffer.writeln('🔄 Subscriptions:   ${_fmt(a.totalSubscriptions)}');
    buffer.writeln('');

    if (a.categories.isNotEmpty) {
      buffer.writeln('🗂️ Categories');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final cat in a.categories) {
        buffer.writeln('${cat.emoji} ${cat.name.padRight(22)} ${_fmt(cat.amount)}  (${cat.count} txns)');
      }
      buffer.writeln('');
    }

    if (a.people.isNotEmpty) {
      buffer.writeln('👥 People / Transfers');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final p in a.people) {
        buffer.writeln('👤 ${p.name}  ${_fmt(p.amount)}  (${p.count} txns)');
        final txns = _getPersonTransactions(p.name);
        for (final txn in txns) {
          final isDebit = txn['type'] == 'debit';
          final amount = (txn['amount'] as num?)?.toDouble() ?? 0;
          buffer.writeln(
            '   ${isDebit ? '🔴' : '🟢'} ${txn['desc']}  '
            '${isDebit ? '-' : '+'}${_fmt(amount)}  '
            '${txn['date']}',
          );
        }
        buffer.writeln('');
      }
    }

    if (a.investments.isNotEmpty) {
      buffer.writeln('📈 Investments');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final inv in a.investments) {
        buffer.writeln('• ${inv['name']}  ${_fmt((inv['amount'] as num?)?.toDouble() ?? 0)}  ${inv['date']}');
      }
      buffer.writeln('');
    }

    if (a.subscriptions.isNotEmpty) {
      buffer.writeln('🔄 Subscriptions');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final sub in a.subscriptions) {
        buffer.writeln('• ${sub['name']}  ${_fmt((sub['amount'] as num?)?.toDouble() ?? 0)}');
      }
      buffer.writeln('');
    }

    if (a.charges.isNotEmpty) {
      buffer.writeln('💸 Charges & Fees');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final c in a.charges) {
        buffer.writeln('• ${c['name']}  ${_fmt((c['amount'] as num?)?.toDouble() ?? 0)}  ${c['date']}');
      }
      buffer.writeln('');
    }

    if (a.unusualTransactions.isNotEmpty) {
      buffer.writeln('⚠️ Unusual Transactions');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      for (final u in a.unusualTransactions) {
        final isDebit = u['type'] == 'debit';
        buffer.writeln(
          '${isDebit ? '🔴' : '🟢'} ${u['desc']}  '
          '${isDebit ? '-' : '+'}${_fmt((u['amount'] as num?)?.toDouble() ?? 0)}  '
          '${u['date']}',
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('Generated by Bharat Budget 🇮🇳');

    Share.share(buffer.toString(), subject: 'My Bank Statement Analysis');
  }

  // ─── Person ke transactions categories se filter karta hai ────────────────
  List<Map<String, dynamic>> _getPersonTransactions(String personName) {
    if (_analysis == null) return [];
    final nameL = personName.toLowerCase();
    final List<Map<String, dynamic>> result = [];
    for (final cat in _analysis!.categories) {
      for (final txn in cat.transactions) {
        final desc = (txn['desc'] ?? '').toString().toLowerCase();
        if (desc.contains(nameL)) result.add(txn);
      }
    }
    if (result.isEmpty) {
      for (final txn in _analysis!.unusualTransactions) {
        final desc = (txn['desc'] ?? '').toString().toLowerCase();
        if (desc.contains(nameL)) result.add(txn);
      }
    }
    return result;
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBalanceCards()),
            SliverToBoxAdapter(child: _buildBankAccounts()),
            SliverToBoxAdapter(child: _buildCashSection()),
            SliverToBoxAdapter(child: _buildUploadSection()),
            SliverToBoxAdapter(child: _buildSelectedFileCard()),
            if (_isAnalyzing) SliverToBoxAdapter(child: _buildAnalyzing()),
            if (_analysisComplete && _analysis != null) ...[
              SliverToBoxAdapter(child: _buildSummaryCards()),
              SliverToBoxAdapter(child: _buildMonthlyTrend()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: _buildPeopleSection()),
              SliverToBoxAdapter(child: _buildInvestments()),
              SliverToBoxAdapter(child: _buildCharges()),
              SliverToBoxAdapter(child: _buildSubscriptions()),
              SliverToBoxAdapter(child: _buildUnusualTransactions()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: kBg,
      floating: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 16,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All Accounts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show balance',
                        style: TextStyle(color: kMuted, fontSize: 13)),
                    const SizedBox(width: 6),
                    Transform.scale(
                      scale: 0.78,
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: _showBalance,
                        onChanged: (v) => setState(() => _showBalance = v),
                        activeColor: kGreen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAddAccountDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withOpacity(0.5), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: kGreen, size: 12),
                  SizedBox(width: 3),
                  Text('Add Account',
                      style: TextStyle(
                          color: kGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _balanceCard('Available Balance', _totalBalance, kBlue)),
          const SizedBox(width: 12),
          Expanded(child: _balanceCard('Available Credit', _totalCredit, kRed)),
        ],
      ),
    );
  }

  Widget _balanceCard(String label, double amount, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: const TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, color: kMuted, size: 14),
          ]),
          const SizedBox(height: 8),
          _showBalance
              ? Text(_fmt(amount),
                  style: TextStyle(
                      color: accent, fontSize: 20, fontWeight: FontWeight.bold))
              : Row(
                  children: List.generate(5, (_) => const Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: Icon(Icons.star_rounded, color: kMuted, size: 18),
                  )),
                ),
        ],
      ),
    );
  }

  Widget _buildBankAccounts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_balance_rounded, color: kMuted, size: 18),
            const SizedBox(width: 8),
            const Text('Bank Accounts',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          ..._accounts
              .asMap()
              .entries
              .where((e) => e.value.type != 'Cash')
              .map((e) => _accountTile(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _accountTile(BankAccount acc, int index) {
    return GestureDetector(
      onTap: () => _showEditAccountDialog(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: acc.color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: acc.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(acc.icon, color: acc.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text('${acc.type} · ••••${acc.last4}',
                      style: const TextStyle(color: kMuted, fontSize: 12)),
                ],
              ),
            ),
            _showBalance
                ? Text(_fmt(acc.balance.abs()),
                    style: TextStyle(
                        color: acc.type == 'Credit' ? kRed : kGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14))
                : const Text('• • • • •',
                    style: TextStyle(color: kMuted, letterSpacing: 2)),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded, color: kMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCashSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.payments_rounded, color: kGreen, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Cash',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showEditCashDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.wallet_rounded,
                        color: kGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash in Hand',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const Text('Physical cash',
                            style: TextStyle(color: kMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  _showBalance
                      ? Text(_fmt(_cashInHand),
                          style: const TextStyle(
                              color: kGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14))
                      : const Text('• • • • •',
                          style: TextStyle(color: kMuted, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_rounded, color: kMuted, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _isAnalyzing ? null : _uploadStatement,
        child: AnimatedOpacity(
          opacity: _isAnalyzing ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                  color: kGreen.withOpacity(0.5),
                  width: 1.5,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
              color: kGreen.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration:
                      const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                  child: const Icon(
                    Icons.upload_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload Bank Statement',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('PDF ya CSV — AI auto categories mein divide karega',
                    style: TextStyle(color: kMuted, fontSize: 13),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _fileChip('PDF'),
                    const SizedBox(width: 8),
                    _fileChip('CSV'),
                    const SizedBox(width: 8),
                    _fileChip('Photo'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fileChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGreen.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: kGreen, fontSize: 11)),
    );
  }

  Widget _buildSelectedFileCard() {
    if (_selectedFile == null || _isAnalyzing) return const SizedBox();

    final ext = (_selectedFile!.extension ?? 'file').toUpperCase();
    final IconData fileIcon = ext == 'PDF'
        ? Icons.picture_as_pdf_rounded
        : ext == 'CSV'
            ? Icons.table_chart_rounded
            : Icons.image_rounded;
    final Color fileColor = ext == 'PDF'
        ? kRed
        : ext == 'CSV'
            ? kGreen
            : kBlue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fileColor.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fileColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(fileIcon, color: fileColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$ext • ${_selectedFileSizeMB.toStringAsFixed(2)} MB',
                        style: const TextStyle(color: kMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedFile = null;
                    _selectedFileName = '';
                    _selectedFileSizeMB = 0;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: kMuted, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _processStatement,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '🤖 Process & Analyze',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    final percent = (_uploadProgress * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGreen.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(_analysisStatus,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Text('$percent%',
                    style: const TextStyle(
                        color: kGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: kGreen.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(kGreen),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stepDot('📂 Load', _uploadProgress >= 0.0),
                _stepLine(_uploadProgress >= 0.25),
                _stepDot('📡 Send', _uploadProgress >= 0.25),
                _stepLine(_uploadProgress >= 0.55),
                _stepDot('🤖 AI', _uploadProgress >= 0.55),
                _stepLine(_uploadProgress >= 0.85),
                _stepDot('✅ Done', _uploadProgress >= 1.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(String label, bool active) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? kGreen : kMuted.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: active ? kGreen : kMuted,
                fontSize: 9,
                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: active ? kGreen.withOpacity(0.6) : kMuted.withOpacity(0.2),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final a = _analysis!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.analytics_rounded, color: kGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Statement Analysis — ${a.totalTransactions} Transactions',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: _shareAnalysis,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBlue.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_rounded, color: kBlue, size: 14),
                      SizedBox(width: 5),
                      Text('Share',
                          style: TextStyle(
                              color: kBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _summaryCard('⬆️ Total In', a.totalIn, kGreen)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('⬇️ Total Out', a.totalOut, kRed)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _summaryCard('💰 Net Savings', a.netSavings,
                  a.netSavings >= 0 ? kGreen : kRed)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('📈 Invested', a.totalInvested, kBlue)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _summaryCard('💸 Charges', a.totalCharges, kOrange)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('🔄 Subscriptions',
                  a.totalSubscriptions, kPurple)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(_fmt(amount),
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    final trend = _analysis!.monthlyTrend;
    if (trend.isEmpty) return const SizedBox();
    final maxVal = trend.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '📅 Monthly Spending',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: trend.entries.map((e) {
            final pct = maxVal > 0 ? e.value / maxVal : 0.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Text(_fmt(e.value),
                        style: const TextStyle(color: kMuted, fontSize: 9)),
                    const SizedBox(height: 4),
                    Container(
                      height: 60 * pct,
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(e.key,
                        style: const TextStyle(color: kMuted, fontSize: 10)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final cats = _analysis!.categories;
    if (cats.isEmpty) return const SizedBox();
    final total = cats.fold(0.0, (s, c) => s + c.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🗂️ Categories',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${cats.length} categories',
                    style: const TextStyle(color: kMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            ...cats.map((cat) {
              final pct = total > 0 ? cat.amount / total : 0.0;
              final isExpanded = _expandedCategories.contains(cat.name);
              final hasTxns = cat.transactions.isNotEmpty;

              return Column(
                children: [
                  GestureDetector(
                    onTap: hasTxns
                        ? () => setState(() {
                              if (isExpanded) {
                                _expandedCategories.remove(cat.name);
                              } else {
                                _expandedCategories.add(cat.name);
                              }
                            })
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          Row(children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text('${cat.count} transactions',
                                      style: const TextStyle(
                                          color: kMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(_fmt(cat.amount),
                                style: TextStyle(
                                    color: cat.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(width: 6),
                            if (hasTxns)
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: kMuted,
                                size: 18,
                              ),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor:
                                      cat.color.withOpacity(0.15),
                                  valueColor:
                                      AlwaysStoppedAnimation(cat.color),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(pct * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: kMuted, fontSize: 10)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded && hasTxns)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cat.color.withOpacity(0.25)),
                      ),
                      child: Column(
                        children: cat.transactions.map((txn) {
                          final isDebit = txn['type'] == 'debit';
                          final amount =
                              (txn['amount'] as num?)?.toDouble() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: isDebit
                                      ? kRed.withOpacity(0.15)
                                      : kGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  isDebit
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: isDebit ? kRed : kGreen,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(txn['desc'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    Text(txn['date'] ?? '',
                                        style: const TextStyle(
                                            color: kMuted, fontSize: 10)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isDebit ? '-' : '+'}${_fmt(amount)}',
                                style: TextStyle(
                                    color: isDebit ? kRed : kGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  if (cat != cats.last)
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── People Section — UPDATED with expand/collapse ────────────────────────
  Widget _buildPeopleSection() {
    final people = _analysis!.people;
    if (people.isEmpty) return const SizedBox();
    final maxCount = people.map((p) => p.count).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '👥 People / Transfers',
        child: Column(
          children: people.map((p) {
            final pct = maxCount > 0 ? p.count / maxCount : 0.0;
            final isExpanded = _expandedPeople.contains(p.name);
            final txns = _getPersonTransactions(p.name);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (isExpanded) {
                        _expandedPeople.remove(p.name);
                      } else {
                        _expandedPeople.add(p.name);
                      }
                    }),
                    child: Column(
                      children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: kBlue.withOpacity(0.2),
                            child: Text(
                                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    color: kBlue, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text('${p.count} transactions',
                                    style: const TextStyle(
                                        color: kMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(_fmt(p.amount),
                              style: const TextStyle(
                                  color: kOrange, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: kMuted,
                            size: 18,
                          ),
                        ]),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: kBlue.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(kBlue),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kBlue.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBlue.withOpacity(0.25)),
                      ),
                      child: txns.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('No transactions found',
                                  style: TextStyle(color: kMuted, fontSize: 12)),
                            )
                          : Column(
                              children: txns.map((txn) {
                                final isDebit = txn['type'] == 'debit';
                                final amount =
                                    (txn['amount'] as num?)?.toDouble() ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: isDebit
                                            ? kRed.withOpacity(0.15)
                                            : kGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        isDebit
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color: isDebit ? kRed : kGreen,
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(txn['desc'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          Text(txn['date'] ?? '',
                                              style: const TextStyle(
                                                  color: kMuted, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isDebit ? '-' : '+'}${_fmt(amount)}',
                                      style: TextStyle(
                                          color: isDebit ? kRed : kGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ]),
                                );
                              }).toList(),
                            ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInvestments() {
    final inv = _analysis!.investments;
    if (inv.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '📈 Investments — ${_fmt(_analysis!.totalInvested)}',
        child: Column(
          children: inv
              .map((i) => _listRow(
                    icon: Icons.trending_up_rounded,
                    color: kGreen,
                    title: i['name'] ?? '',
                    subtitle: i['date'] ?? '',
                    amount: _fmt((i['amount'] as num?)?.toDouble() ?? 0),
                    amountColor: kGreen,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCharges() {
    final charges = _analysis!.charges;
    if (charges.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '💸 Charges & Fees — ${_fmt(_analysis!.totalCharges)}',
        child: Column(
          children: charges
              .map((c) => _listRow(
                    icon: Icons.remove_circle_outline_rounded,
                    color: kOrange,
                    title: c['name'] ?? '',
                    subtitle: c['date'] ?? '',
                    amount:
                        '-${_fmt((c['amount'] as num?)?.toDouble() ?? 0)}',
                    amountColor: kOrange,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSubscriptions() {
    final subs = _analysis!.subscriptions;
    if (subs.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '🔄 Subscriptions — ${_fmt(_analysis!.totalSubscriptions)}/month',
        child: Column(
          children: subs
              .map((s) => _listRow(
                    icon: Icons.repeat_rounded,
                    color: kPurple,
                    title: s['name'] ?? '',
                    subtitle: s['date'] ?? '',
                    amount: _fmt((s['amount'] as num?)?.toDouble() ?? 0),
                    amountColor: kPurple,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildUnusualTransactions() {
    final unusual = _analysis!.unusualTransactions;
    if (unusual.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _sectionCard(
        title: '⚠️ Unusual Transactions',
        child: Column(
          children: unusual.map((u) {
            final isDebit = u['type'] == 'debit';
            return _listRow(
              icon: isDebit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isDebit ? kRed : kGreen,
              title: u['desc'] ?? '',
              subtitle: u['date'] ?? '',
              amount:
                  '${isDebit ? '-' : '+'}${_fmt((u['amount'] as num?)?.toDouble() ?? 0)}',
              amountColor: isDebit ? kRed : kGreen,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: const TextStyle(color: kMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}