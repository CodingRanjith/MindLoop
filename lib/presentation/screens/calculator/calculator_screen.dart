import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindloop/themes/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '0';
  String _buffer = '';
  String? _operator;
  double _accumulator = 0;

  void _clear() {
    setState(() {
      _output = '0';
      _buffer = '';
      _operator = null;
      _accumulator = 0;
    });
  }

  void _inputDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_output == '0' || _buffer == _output && _operator == null) {
        _output = digit;
      } else {
        _output += digit;
      }
    });
  }

  void _setOperator(String op) {
    HapticFeedback.lightImpact();
    setState(() {
      _accumulator = double.tryParse(_output) ?? 0;
      _operator = op;
      _buffer = _output;
      _output = '0';
    });
  }

  void _applyEqual() {
    HapticFeedback.mediumImpact();
    final rhs = double.tryParse(_output) ?? 0;
    final result = switch (_operator) {
      '+' => _accumulator + rhs,
      '-' => _accumulator - rhs,
      'x' => _accumulator * rhs,
      '/' => rhs == 0 ? 0 : _accumulator / rhs,
      _ => rhs,
    };
    setState(() {
      _output = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
      _operator = null;
      _buffer = _output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2A78), Color(0xFF2E3DAA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x331E2A78),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _operator == null ? '' : '$_accumulator $_operator',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _output,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    _CalcKey(label: 'C', accent: true, onTap: _clear),
                    _CalcKey(label: '/', accent: true, onTap: () => _setOperator('/')),
                    _CalcKey(label: 'x', accent: true, onTap: () => _setOperator('x')),
                    _CalcKey(label: '-', accent: true, onTap: () => _setOperator('-')),
                    ...['7', '8', '9'].map((e) => _CalcKey(label: e, onTap: () => _inputDigit(e))),
                    _CalcKey(label: '+', accent: true, onTap: () => _setOperator('+')),
                    ...['4', '5', '6', '1', '2', '3', '00', '0', '.'].map(
                      (e) => _CalcKey(
                        label: e,
                        onTap: () {
                          if (e == '.' && _output.contains('.')) return;
                          _inputDigit(e);
                        },
                      ),
                    ),
                    _CalcKey(label: '=', accent: true, onTap: _applyEqual),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcKey extends StatelessWidget {
  const _CalcKey({
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: accent ? AppColors.primaryDark : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent ? AppColors.primaryDark : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: accent ? 0.18 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: accent ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
