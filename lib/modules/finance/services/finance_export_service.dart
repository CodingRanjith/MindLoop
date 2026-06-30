import 'dart:io';

import 'package:excel/excel.dart';
import 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/financial_goal_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/loan_entity.dart';
import 'package:mindloop/modules/finance/domain/entities/pfm_dashboard_snapshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class FinanceExportService {
  Future<File> exportExcel({
    required PfmDashboardSnapshot snapshot,
    required List<BudgetTransactionEntity> transactions,
    required List<FinancialGoalEntity> goals,
    required List<LoanEntity> loans,
    required List<String> insights,
  }) async {
    final excel = Excel.createExcel();
    _sheetDashboard(excel, snapshot);
    _sheetTransactions(excel, 'Income', transactions.where((t) => t.type == TransactionType.income));
    _sheetTransactions(excel, 'Expenses', transactions.where((t) => t.type == TransactionType.expense));
    _sheetGoals(excel, goals);
    _sheetLoans(excel, loans);
    _sheetInsights(excel, insights, snapshot);

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/mindloop_finance_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> exportPdf({
    required PfmDashboardSnapshot snapshot,
    required List<String> insights,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('MindLoop Financial Report')),
          pw.Text('Health Score: ${snapshot.financialHealthScore}/100'),
          pw.SizedBox(height: 8),
          pw.Text('Income: ${snapshot.totalIncome.toStringAsFixed(0)}'),
          pw.Text('Expenses: ${snapshot.totalExpenses.toStringAsFixed(0)}'),
          pw.Text('Net Worth: ${snapshot.netWorth.toStringAsFixed(0)}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, child: pw.Text('AI Insights')),
          ...insights.map((i) => pw.Bullet(text: i)),
        ],
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/mindloop_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> exportCsv(List<BudgetTransactionEntity> transactions) async {
    final buffer = StringBuffer('Date,Title,Type,Category,Amount,Notes\n');
    for (final t in transactions) {
      buffer.writeln(
        '${t.date.toIso8601String()},${t.title},${t.type.name},${t.category},${t.amount},"${t.notes}"',
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/mindloop_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(buffer.toString());
    return file;
  }

  void _sheetDashboard(Excel excel, PfmDashboardSnapshot s) {
    final sheet = excel['Dashboard Summary'];
    final rows = [
      ['Metric', 'Value'],
      ['Total Income', s.totalIncome],
      ['Total Expenses', s.totalExpenses],
      ['Available Balance', s.availableBalance],
      ['Total Savings', s.totalSavings],
      ['Investments', s.investments],
      ['Active Loans', s.activeLoans],
      ['Upcoming EMI', s.upcomingEmi],
      ['Financial Health', s.financialHealthScore],
      ['Net Worth', s.netWorth],
    ];
    for (var i = 0; i < rows.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i)).value =
          TextCellValue(rows[i][0].toString());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i)).value =
          DoubleCellValue((rows[i][1] as num).toDouble());
    }
  }

  void _sheetTransactions(
    Excel excel,
    String name,
    Iterable<BudgetTransactionEntity> items,
  ) {
    final sheet = excel[name];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Date');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        TextCellValue('Title');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue('Category');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        TextCellValue('Amount');
    var row = 1;
    for (final t in items) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          TextCellValue(t.date.toIso8601String());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(t.title);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(t.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          DoubleCellValue(t.amount);
      row++;
    }
  }

  void _sheetGoals(Excel excel, List<FinancialGoalEntity> goals) {
    final sheet = excel['Goals'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Goal');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        TextCellValue('Target');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue('Current');
    for (var i = 0; i < goals.length; i++) {
      final g = goals[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value =
          TextCellValue(g.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value =
          DoubleCellValue(g.targetAmount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value =
          DoubleCellValue(g.currentAmount);
    }
  }

  void _sheetLoans(Excel excel, List<LoanEntity> loans) {
    final sheet = excel['Loans'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Loan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        TextCellValue('Pending');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue('EMI');
    for (var i = 0; i < loans.length; i++) {
      final l = loans[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value =
          TextCellValue(l.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value =
          DoubleCellValue(l.pendingAmount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value =
          DoubleCellValue(l.emiAmount);
    }
  }

  void _sheetInsights(Excel excel, List<String> insights, PfmDashboardSnapshot s) {
    final sheet = excel['AI Insights'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Insight');
    for (var i = 0; i < insights.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value =
          TextCellValue(insights[i]);
    }
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: insights.length + 2)).value =
        TextCellValue('Loan Burden %: ${s.loanBurdenPercent.toStringAsFixed(1)}');
  }
}
