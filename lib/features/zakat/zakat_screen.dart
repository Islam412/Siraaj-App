import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _debtsController = TextEditingController();

  double? _zakatAmount;
  bool _isEligible = false;

  // نصاب الذهب التقريبي (85 جرام) * سعر افتراضي (يمكن تعديله)
  final double _goldNisabValue = 85 * 2500; // مثال: 2500 جنيه للجرام

  void _calculateZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0;
    double gold = double.tryParse(_goldController.text) ?? 0;
    double silver = double.tryParse(_silverController.text) ?? 0;
    double debts = double.tryParse(_debtsController.text) ?? 0;

    double totalAssets = cash + gold + silver;
    double netWealth = totalAssets - debts;

    if (netWealth >= _goldNisabValue) {
      setState(() {
        _isEligible = true;
        _zakatAmount = netWealth * 0.025; // 2.5%
      });
    } else {
      setState(() {
        _isEligible = false;
        _zakatAmount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الزكاة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('النقد المتاح (بنك/منزل)', _cashController, Icons.payments),
            const SizedBox(height: 16),
            _buildInputField('قيمة الذهب (بالجنيه/العملة المحلية)', _goldController, Icons.diamond),
            const SizedBox(height: 16),
            _buildInputField('قيمة الفضة', _silverController, Icons.circle),
            const SizedBox(height: 16),
            _buildInputField('الديون المستحقة عليك (تُخصم)', _debtsController, Icons.money_off, isNegative: true),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateZakat,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب الزكاة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            if (_zakatAmount != null) ...[
              const SizedBox(height: 32),
              Card(
                color: _isEligible ? Colors.green.shade50 : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        _isEligible ? Icons.check_circle : Icons.info_outline,
                        size: 48,
                        color: _isEligible ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isEligible ? 'تجب عليك الزكاة' : 'لم تبلغ أموالك النصاب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isEligible ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                      if (_isEligible) ...[
                        const SizedBox(height: 12),
                        const Text('مقدار الزكاة المستحقة (2.5%):', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          '${_zakatAmount!.toStringAsFixed(2)} جنيه/عملة',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          'النصاب التقريبي هو: ${_goldNisabValue.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ]
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).scale(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isNegative = false}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isNegative ? Colors.red : Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}