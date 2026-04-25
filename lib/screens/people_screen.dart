import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

// Local color helpers
const _orange = Color(0xFFFF9800);
const _orangeBg = Color(0x1FFF9800);
const _orangeBorder = Color(0x66FF9800);

// ── DATE + TIME FORMATTER ─────────────────────────────────────
String fmtDateTime(DateTime dt) {
  return DateFormat('d MMM, h:mm a').format(dt);
}

String fmtDateOnly(DateTime dt) {
  return DateFormat('d MMM yyyy').format(dt);
}

// ── CHANGED: StatelessWidget → StatefulWidget ─────────────────
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  // ── SEARCH STATE ──────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Returns people whose name OR any transaction description matches _query.
  /// Matched people are sorted to top; rest follow the original settled sort.
  List<Person> _filteredPeople(List<Person> all) {
    final sorted = List<Person>.from(all)
      ..sort((a, b) {
        final aSettled = a.transactions.every((t) => t.settled);
        final bSettled = b.transactions.every((t) => t.settled);
        if (aSettled == bSettled) return 0;
        return aSettled ? 1 : -1;
      });

    if (_query.isEmpty) return sorted;

    final q = _query.toLowerCase();

    final matched = sorted
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.transactions.any((t) => t.desc.toLowerCase().contains(q)))
        .toList();

    final rest =
        sorted.where((p) => !matched.contains(p)).toList();

    return [...matched, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final people = _filteredPeople(state.people);
    final hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title (left)
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👥 People & Bills',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kText)),
                        Text('Shared expenses tracker',
                            style: TextStyle(fontSize: 12, color: kMuted)),
                      ],
                    ),
                  ),

                  // ── SEARCH ICON / INLINE SEARCH BAR (right) ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _searchOpen
                        ? SizedBox(
                            key: const ValueKey('bar'),
                            width: 180,
                            height: 38,
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              style: const TextStyle(
                                  fontSize: 13, color: kText),
                              onChanged: (v) =>
                                  setState(() => _query = v.trim()),
                              decoration: InputDecoration(
                                hintText: 'Search name / bill…',
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: kMuted),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                isDense: true,
                                filled: true,
                                fillColor: kCard2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() {
                                    _searchOpen = false;
                                    _query = '';
                                    _searchCtrl.clear();
                                  }),
                                  child: const Icon(Icons.close,
                                      size: 16, color: kMuted),
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            key: const ValueKey('icon'),
                            onPressed: () =>
                                setState(() => _searchOpen = true),
                            icon: const Icon(Icons.search,
                                color: kMuted, size: 22),
                            tooltip: 'Search people / bills',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                          ),
                  ),
                ],
              ),
            ),

            // ── BODY ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards (hidden while searching)
                  if (!hasQuery) ...[
                    Row(children: [
                      Expanded(
                          child: _sumCard(true, state.totalReceive)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _sumCard(false, state.totalOwe)),
                    ]),
                    const SizedBox(height: 14),
                  ],

                  // Add Person button
                  GestureDetector(
                    onTap: () => _showAddPerson(context, state),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 212, 160, 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                Color.fromRGBO(0, 212, 160, 0.35)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: kGreen, size: 18),
                          SizedBox(width: 8),
                          Text('Add Person & Bills',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kGreen)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── SEARCH RESULT BANNER ─────────────────────
                  if (hasQuery) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 212, 160, 0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                Color.fromRGBO(0, 212, 160, 0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.search,
                            size: 14, color: kGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${people.where((p) => p.name.toLowerCase().contains(_query.toLowerCase()) || p.transactions.any((t) => t.desc.toLowerCase().contains(_query.toLowerCase()))).length} result(s) for "$_query"',
                            style: const TextStyle(
                                fontSize: 12,
                                color: kGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _query = '';
                            _searchCtrl.clear();
                            _searchOpen = false;
                          }),
                          child: const Icon(Icons.close,
                              size: 14, color: kMuted),
                        ),
                      ]),
                    ),
                  ],

                  // ── PERSON LIST ──────────────────────────────
                  ...people.map((p) {
                    final isMatch = hasQuery &&
                        (p.name
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            p.transactions.any((t) => t.desc
                                .toLowerCase()
                                .contains(_query.toLowerCase())));
                    return _personRow(context, p,
                        highlight: isMatch, query: _query);
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumCard(bool isReceive, double amount) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isReceive
              ? Color.fromRGBO(0, 212, 160, 0.12)
              : Color.fromRGBO(255, 82, 82, 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isReceive
                  ? Color.fromRGBO(0, 212, 160, 0.25)
                  : Color.fromRGBO(255, 82, 82, 0.25)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: isReceive ? kGreen : kRed,
                        shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(isReceive ? 'You will receive' : 'You owe',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isReceive ? kGreen : kRed)),
              ]),
              const SizedBox(height: 6),
              Text(fmtFull(amount),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isReceive ? kGreen : kRed)),
            ]),
      );

  // ── highlight: draws a teal left-border accent on matched rows ──
  Widget _personRow(BuildContext context, Person p,
      {bool highlight = false, String query = ''}) {
    final bal = p.balance;
    final unsettled =
        p.transactions.where((t) => !t.settled).length;
    final allSettled = p.transactions.every((t) => t.settled);
    Color amtColor;
    String amtText;
    if (allSettled) {
      amtColor = kMuted;
      amtText = 'Settled ✓';
    } else if (bal > 0) {
      amtColor = kGreen;
      amtText = '${fmtFull(bal)} owes you';
    } else {
      amtColor = kRed;
      amtText = 'You owe ${fmtFull(bal.abs())}';
    }

    // Matching bill descriptions to show as sub-hint
    final matchedBills = query.isEmpty
        ? <String>[]
        : p.transactions
            .where((t) =>
                t.desc.toLowerCase().contains(query.toLowerCase()))
            .map((t) => t.desc)
            .toList();

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) =>
                  PersonDetailScreen(personId: p.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          // teal left accent on matched
          border: highlight
              ? const Border(
                  left: BorderSide(color: kGreen, width: 3))
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: highlight
              ? BoxDecoration(
                  color: Color.fromRGBO(0, 212, 160, 0.06),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                  border: Border.all(
                      color: Color.fromRGBO(0, 212, 160, 0.2)),
                )
              : cardDecoration(),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kText)),
                    Text(p.relation,
                        style: const TextStyle(
                            fontSize: 11, color: kMuted)),
                    // Show matched bill names as chips
                    if (matchedBills.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: matchedBills
                            .take(3)
                            .map((bill) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _orangeBg,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    border: const Border.fromBorderSide(
                                        BorderSide(
                                            color: _orangeBorder)),
                                  ),
                                  child: Text(bill,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: _orange,
                                          fontWeight:
                                              FontWeight.w600)),
                                ))
                            .toList(),
                      ),
                    ],
                  ]),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amtText,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: amtColor)),
                  Text(
                      allSettled
                          ? '${p.transactions.length} txns'
                          : '$unsettled txns',
                      style: const TextStyle(
                          fontSize: 10, color: kMuted)),
                ]),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: kMuted),
          ]),
        ),
      ),
    );
  }

  void _showAddPerson(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String relation = 'Friend';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
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
                              borderRadius:
                                  BorderRadius.circular(4)))),
                  const SizedBox(height: 16),
                  const Text('Add New Person',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kText)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Rahul, Priya')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: relation,
                    dropdownColor: kCard2,
                    decoration: const InputDecoration(
                        labelText: 'Relation'),
                    items: [
                      'Friend',
                      'Brother',
                      'Sister',
                      'Mother',
                      'Father',
                      'Colleague',
                      'Credit Card',
                      'Bills',
                      'Other'
                    ]
                        .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: const TextStyle(
                                    color: kText))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => relation = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amtCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            signed: true),
                    decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        hintText:
                            'Positive = they owe you, Negative = you owe'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Note',
                          hintText:
                              'e.g. Dinner split, Petrol loan')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final amt =
                          double.tryParse(amtCtrl.text) ?? 0;

                      final existing = state.people
                          .cast<Person?>()
                          .firstWhere(
                            (p) =>
                                p!.name.toLowerCase() ==
                                name.toLowerCase(),
                            orElse: () => null,
                          );

                      if (existing != null) {
                        if (amt != 0) {
                          state.addTransactionToPerson(
                            existing.id,
                            PersonTxn(
                              desc: noteCtrl.text.trim().isEmpty
                                  ? 'Transaction'
                                  : noteCtrl.text.trim(),
                              amount: amt,
                              date: DateTime.now(),
                            ),
                          );
                        }
                      } else {
                        final colors = kAvatarColors;
                        final color = colors[
                            state.people.length % colors.length];
                        final p = Person(
                          id: state.newId(),
                          name: name,
                          relation: relation,
                          color: color,
                          transactions: [],
                        );
                        if (amt != 0) {
                          p.transactions.add(PersonTxn(
                            desc: noteCtrl.text.trim().isEmpty
                                ? 'Transaction'
                                : noteCtrl.text.trim(),
                            amount: amt,
                            date: DateTime.now(),
                          ));
                        }
                        state.addPerson(p);
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existing != null
                              ? '✓ Transaction added for $name!'
                              : '✓ $name added successfully!'),
                          backgroundColor: kGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('✓ Add'),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

// ── PERSON DETAIL ────────────────────────────────────────────
class PersonDetailScreen extends StatelessWidget {
  final String personId;
  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.people.firstWhere((x) => x.id == personId);
    final bal = p.balance;
    Color balColor = bal > 0 ? kGreen : bal < 0 ? kRed : kMuted;
    String balText = bal > 0
        ? 'You will receive ${fmtFull(bal)}'
        : bal < 0
            ? 'You owe ${fmtFull(bal.abs())}'
            : 'Settled ✓';

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(p.name),
        backgroundColor: kBg,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kText),
            onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    avatarCircle(p.name, p.color,
                        size: 56, fontSize: 22),
                    const SizedBox(width: 14),
                    Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          Text(p.relation,
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted)),
                          const SizedBox(height: 6),
                          Text(balText,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: balColor)),
                        ]),
                  ]),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () =>
                        _showAddTransaction(context, state),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 212, 160, 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Color.fromRGBO(
                                0, 212, 160, 0.35)),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,
                              color: kGreen, size: 18),
                          SizedBox(width: 8),
                          Text('Add Amount & Bill',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kGreen)),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
          const SizedBox(height: 14),
          const Text('TRANSACTIONS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kMuted,
                  letterSpacing: 1.3)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(),
            child: Column(
              children: p.transactions.map((t) {
                final isPartial =
                    t.paidAmount > 0 && !t.settled;
                final iconColor = t.settled
                    ? kGreen
                    : (isPartial
                        ? _orange
                        : (t.amount >= 0 ? kGreen : kRed));

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: t.settled
                                ? const Color(0x1F00D4A0)
                                : isPartial
                                    ? _orangeBg
                                    : t.amount >= 0
                                        ? const Color(
                                            0x1F00D4A0)
                                        : const Color(
                                            0x1AFF5252),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Icon(
                            t.settled
                                ? Icons.check_circle
                                : isPartial
                                    ? Icons.pending
                                    : t.amount >= 0
                                        ? Icons.savings
                                        : Icons.money_off,
                            size: 18,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(t.desc,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: kText)),
                                Text(fmtDateTime(t.date),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: kMuted)),
                                if (t.settled &&
                                    t.settledDate != null)
                                  Text(
                                    'Settled ✓ ${fmtDateTime(t.settledDate!)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: kGreen),
                                  ),
                                if (isPartial)
                                  Text(
                                    '₹${t.remaining.toStringAsFixed(0)} remaining',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: _orange),
                                  ),
                              ]),
                        ),
                        Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${t.amount >= 0 ? '+' : ''}${fmtFull(t.amount.abs())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: t.settled
                                      ? kMuted
                                      : (t.amount >= 0
                                          ? kGreen
                                          : kRed),
                                ),
                              ),
                              if (t.paidAmount > 0)
                                Text(
                                    'Received: ₹${t.paidAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: kGreen)),
                            ]),
                      ]),
                      if (t.partialPayments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          margin:
                              const EdgeInsets.only(left: 46),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _orangeBg,
                            borderRadius:
                                BorderRadius.circular(10),
                            border: const Border.fromBorderSide(
                                BorderSide(
                                    color: _orangeBorder)),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Payment History:',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: _orange,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 6),
                              ...t.partialPayments.map((pp) =>
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            bottom: 4),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                fmtDateTime(
                                                    pp.dateTime),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: kMuted),
                                              ),
                                              if (pp.note !=
                                                      null &&
                                                  pp.note!
                                                      .isNotEmpty)
                                                Text(
                                                  pp.note!,
                                                  style: const TextStyle(
                                                      fontSize:
                                                          10,
                                                      color:
                                                          _orange),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            '+₹${pp.amount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                                color: kGreen),
                                          ),
                                        ]),
                                  )),
                            ],
                          ),
                        ),
                      ],
                      if (!t.settled) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const SizedBox(width: 46),
                          GestureDetector(
                            onTap: () => _showPartialSettle(
                                context, state, p.id, t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: const BoxDecoration(
                                color: _orangeBg,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8)),
                                border: Border.fromBorderSide(
                                    BorderSide(
                                        color: _orangeBorder)),
                              ),
                              child: const Text('Partial Settle',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _orange)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: kBg2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              16)),
                                  title: const Text(
                                      'Settle in Full?',
                                      style: TextStyle(
                                          color: kText,
                                          fontWeight:
                                              FontWeight.w800)),
                                  content: Text(
                                    'Do you want to fully settle "${t.desc}"?',
                                    style: const TextStyle(
                                        color: kMuted),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx),
                                      child: const Text('No',
                                          style: TextStyle(
                                              color: kRed)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _showAmountConfirmDialog(
                                            context,
                                            state,
                                            p.id,
                                            t);
                                      },
                                      child: const Text(
                                          'Yes, Proceed'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Color(0x1F00D4A0),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8)),
                                border: Border.fromBorderSide(
                                    BorderSide(
                                        color:
                                            Color(0x6600D4A0))),
                              ),
                              child: const Text('Full Settle ✓',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: kGreen)),
                            ),
                          ),
                        ]),
                      ],
                      const Divider(
                          color: Colors.white10, height: 16),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context, AppState state) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
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
                            borderRadius:
                                BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                const Text('Add Amount & Bill',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kText)),
                const SizedBox(height: 16),
                TextField(
                  controller: amtCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                          signed: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      hintText:
                          'Positive = they owe you, Negative = you owe'),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText:
                            'e.g. Dinner split, Petrol loan')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final amt =
                        double.tryParse(amtCtrl.text) ?? 0;
                    if (amt == 0) return;
                    state.addTransactionToPerson(
                      personId,
                      PersonTxn(
                        desc: noteCtrl.text.trim().isEmpty
                            ? 'Transaction'
                            : noteCtrl.text.trim(),
                        amount: amt,
                        date: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('✓ Transaction added successfully!'),
                        backgroundColor: kGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('✓ Add'),
                ),
              ]),
        ),
      ),
    );
  }

  void _showSettleAllAmountConfirm(BuildContext context,
      AppState state, String name, double totalBal) {
    final amtCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final entered =
              double.tryParse(amtCtrl.text) ?? 0;
          final isMatch = entered == totalBal;

          return AlertDialog(
            backgroundColor: kBg2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Confirm Amount',
                style: TextStyle(
                    color: kText,
                    fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _orangeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border.fromBorderSide(
                        BorderSide(color: _orangeBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:',
                          style: TextStyle(
                              fontSize: 13, color: kMuted)),
                      Text(
                        '₹${totalBal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Type the exact total amount to confirm:',
                  style: TextStyle(fontSize: 12, color: kMuted),
                ),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: amtCtrl,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isMatch ? kGreen : kRed,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Type ₹${totalBal.toStringAsFixed(0)}',
                      hintStyle: const TextStyle(
                          color: Colors.white24, fontSize: 14),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                          color: isMatch ? kGreen : kMuted,
                          fontWeight: FontWeight.w700),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: amtCtrl.text.isEmpty
                                ? Colors.white24
                                : isMatch
                                    ? kGreen
                                    : kRed),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color:
                                isMatch ? kGreen : kRed,
                            width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter amount';
                      final val = double.tryParse(v);
                      if (val == null)
                        return 'Enter a valid number';
                      if (val != totalBal) {
                        return 'Amount does not match! Total: ₹${totalBal.toStringAsFixed(0)}';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (amtCtrl.text.isNotEmpty)
                  Row(children: [
                    Icon(
                      isMatch
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 14,
                      color: isMatch ? kGreen : kRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMatch
                          ? '✓ Amount is correct! Will be settled.'
                          : 'Amount does not match',
                      style: TextStyle(
                          fontSize: 11,
                          color: isMatch ? kGreen : kRed,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: kMuted)),
              ),
              ElevatedButton(
                onPressed: !isMatch
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          state.settleAll(personId);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text('🎉 All settled!'),
                              backgroundColor: kGreen,
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMatch ? kGreen : Colors.grey,
                ),
                child: const Text('✓ Confirm Settle'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAmountConfirmDialog(BuildContext context,
      AppState state, String personId, PersonTxn t) {
    final remaining = t.amount.abs() - t.paidAmount;
    final amtCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final entered =
              double.tryParse(amtCtrl.text) ?? 0;
          final isMatch = entered == remaining;

          return AlertDialog(
            backgroundColor: kBg2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Confirm Amount',
                style: TextStyle(
                    color: kText,
                    fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _orangeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border.fromBorderSide(
                        BorderSide(color: _orangeBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Amount:',
                          style: TextStyle(
                              fontSize: 13, color: kMuted)),
                      Text(
                        '₹${remaining.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Type the exact remaining amount to confirm:',
                  style: TextStyle(fontSize: 12, color: kMuted),
                ),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: amtCtrl,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isMatch ? kGreen : kRed,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Type ₹${remaining.toStringAsFixed(0)}',
                      hintStyle: const TextStyle(
                          color: Colors.white24, fontSize: 14),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                          color: isMatch ? kGreen : kMuted,
                          fontWeight: FontWeight.w700),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: amtCtrl.text.isEmpty
                                ? Colors.white24
                                : isMatch
                                    ? kGreen
                                    : kRed),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color:
                                isMatch ? kGreen : kRed,
                            width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter amount';
                      final val = double.tryParse(v);
                      if (val == null)
                        return 'Enter a valid number';
                      if (val != remaining) {
                        return 'Amount does not match! Remaining: ₹${remaining.toStringAsFixed(0)}';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (amtCtrl.text.isNotEmpty)
                  Row(children: [
                    Icon(
                      isMatch
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 14,
                      color: isMatch ? kGreen : kRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMatch
                          ? '✓ Amount is correct! Will be settled.'
                          : 'Amount does not match',
                      style: TextStyle(
                          fontSize: 11,
                          color: isMatch ? kGreen : kRed,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: kMuted)),
              ),
              ElevatedButton(
                onPressed: !isMatch
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          state.settleSingle(personId, t);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('🎉 Fully settled!'),
                              backgroundColor: kGreen,
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMatch ? kGreen : Colors.grey,
                ),
                child: const Text('✓ Confirm Settle'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPartialSettle(BuildContext context, AppState state,
      String personId, PersonTxn txn) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg2,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final entered =
              double.tryParse(amtCtrl.text) ?? 0;
          final alreadyPaid = txn.paidAmount;
          final totalAmt = txn.amount.abs();
          final stillRemaining = totalAmt - alreadyPaid;
          final afterPayment = stillRemaining - entered;

          return Padding(
            padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius:
                                BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Partial Settlement',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kText)),
                    const SizedBox(height: 4),
                    Text(txn.desc,
                        style: const TextStyle(
                            fontSize: 13, color: kMuted)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: _infoTile(
                              'Total Amount',
                              '₹${totalAmt.toStringAsFixed(0)}',
                              kText)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _infoTile(
                              'Already Paid',
                              '₹${alreadyPaid.toStringAsFixed(0)}',
                              kGreen)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _infoTile(
                              'Remaining',
                              '₹${stillRemaining.toStringAsFixed(0)}',
                              _orange)),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amtCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Amount Received (₹)',
                        hintText: 'Enter amount',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText:
                            'e.g. Cash, UPI, Returned loan',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (entered > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: afterPayment <= 0
                              ? const Color(0x1A00D4A0)
                              : _orangeBg,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: afterPayment <= 0
                                  ? const Color(0x6600D4A0)
                                  : _orangeBorder),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              afterPayment <= 0
                                  ? '🎉 Will be fully settled!'
                                  : '⚡ Remaining after payment:',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: afterPayment <= 0
                                      ? kGreen
                                      : _orange),
                            ),
                            if (afterPayment > 0)
                              Text(
                                '₹${afterPayment.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: _orange),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: entered <= 0
                          ? null
                          : () {
                              state.partialSettle(
                                  personId, txn, entered,
                                  note: noteCtrl.text.trim());
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(afterPayment <=
                                          0
                                      ? '🎉 Fully settled!'
                                      : '✓ ₹${entered.toStringAsFixed(0)} recorded! ₹${afterPayment.toStringAsFixed(0)} remaining'),
                                  backgroundColor:
                                      afterPayment <= 0
                                          ? kGreen
                                          : _orange,
                                  behavior:
                                      SnackBarBehavior.floating,
                                ),
                              );
                            },
                      child: Text(afterPayment <= 0
                          ? '✓ Settle in Full'
                          : '✓ Partial Settle'),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value, Color color) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(
              color.red, color.green, color.blue, 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Color.fromRGBO(
                  color.red, color.green, color.blue, 0.2)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: kMuted)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ]),
      );
}