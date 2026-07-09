import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_text_field.dart';
import 'transaction_detail_screen.dart';

/// Transactions screen: Add Income / Add Expense / History.
///
/// TODO: wire "Save Income" / "Save Expense" to POST /api/transactions
/// once the backend endpoint is available, and load History from
/// GET /api/transactions.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(children: [
                Text('Transactions',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary))
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SegmentedTabs(
                  index: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _tabIndex == 0
                    ? const _TransactionForm(isIncome: true)
                    : _tabIndex == 1
                        ? const _TransactionForm(isIncome: false)
                        : const _HistoryList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['Income', 'Expense', 'History'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.subtle),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(labels[i],
                    style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  final bool isIncome;

  const _TransactionForm({required this.isIncome});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _linkedGoalController = TextEditingController();
  String? _selectedOption;

  final _incomeSources = ['Salary', 'Freelance', 'Business', 'Gift', 'Other'];
  final _expenseCategories = [
    'Groceries',
    'Transport',
    'Rent',
    'Utilities',
    'Entertainment',
    'Other'
  ];

  @override
  void didUpdateWidget(covariant _TransactionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isIncome != widget.isIncome) _selectedOption = null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _linkedGoalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 2),
        lastDate: DateTime(now.year + 2));
    if (picked != null) {
      _dateController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  void _handleSave() {
    // TODO: POST to /api/transactions with:
    // { type: isIncome ? 'income' : 'expense', amount, source/category, date, linkedGoalId }
    final label = widget.isIncome ? 'Income' : 'Expense';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$label saved locally (backend not connected yet)')));
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.isIncome ? _incomeSources : _expenseCategories;
    final accentColor = widget.isIncome ? AppColors.income : AppColors.expense;
    final accentPale =
        widget.isIncome ? AppColors.incomePale : AppColors.expensePale;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.subtle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration:
                    BoxDecoration(color: accentPale, shape: BoxShape.circle),
                child: Icon(
                    widget.isIncome
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: accentColor),
              ),
              const SizedBox(width: 8),
              Text('Add ${widget.isIncome ? 'Income' : 'Expense'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          AppTextField(
              label: 'Amount (KES)',
              hint: '0.00',
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          Text(widget.isIncome ? 'SOURCE' : 'CATEGORY', style: AppText.eyebrow),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedOption,
            hint: Text(widget.isIncome ? 'Select source' : 'Select category'),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (value) => setState(() => _selectedOption = value),
          ),
          const SizedBox(height: 16),
          const Text('DATE', style: AppText.eyebrow),
          const SizedBox(height: 6),
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
                hintText: 'mm/dd/yyyy',
                suffixIcon: Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 16),
          AppTextField(
              label: 'Linked Savings Goal (optional)',
              hint: 'e.g. Emergency Fund',
              controller: _linkedGoalController),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.isIncome
                    ? AppColors.primaryLight
                    : AppColors.expense),
            child: Text('Save ${widget.isIncome ? 'Income' : 'Expense'}'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Salary',
        'date': '1 Jun 2026',
        'amount': '+KES 65,000',
        'income': true,
        'category': 'Salary'
      },
      {
        'title': 'Freelance Gig',
        'date': '5 Jun 2026',
        'amount': '+KES 12,000',
        'income': true,
        'category': 'Freelance'
      },
      {
        'title': 'Groceries',
        'date': '3 Jun 2026',
        'amount': '-KES 4,200',
        'income': false,
        'category': 'Groceries'
      },
      {
        'title': 'Transport',
        'date': '4 Jun 2026',
        'amount': '-KES 1,450',
        'income': false,
        'category': 'Transport'
      },
      {
        'title': 'Rent',
        'date': '2 Jun 2026',
        'amount': '-KES 19,000',
        'income': false,
        'category': 'Rent'
      },
    ];

    return Column(
      children: items.map((tx) {
        final isIncome = tx['income'] as bool;
        final color = isIncome ? AppColors.income : AppColors.expense;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(
                title: tx['title'] as String,
                date: tx['date'] as String,
                amount: tx['amount'] as String,
                isIncome: isIncome,
                category: tx['category'] as String,
              ),
            ));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppShadows.subtle),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: isIncome
                          ? AppColors.incomePale
                          : AppColors.expensePale,
                      shape: BoxShape.circle),
                  child: Icon(
                      isIncome
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 18,
                      color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['title'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary)),
                      Text(tx['date'] as String, style: AppText.caption),
                    ],
                  ),
                ),
                Text(tx['amount'] as String,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
