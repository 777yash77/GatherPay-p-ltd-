import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key, required this.pool});

  final PoolModel pool;

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _upiController = TextEditingController(text: 'yaswanth@upi');
  final _amountController = TextEditingController();
  bool _paymentDone = false;
  bool _paymentFailed = false;

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    final enteredAmount = int.tryParse(_amountController.text.trim()) ?? 0;
    final remainingAmount = widget.pool.targetAmount - widget.pool.collectedAmount;
    final hasValidUpi = _upiController.text.trim().contains('@');

    if (!hasValidUpi || enteredAmount <= 0 || enteredAmount > remainingAmount) {
      setState(() {
        _paymentDone = false;
        _paymentFailed = true;
      });
      return;
    }

    setState(() {
      _paymentDone = true;
      _paymentFailed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = widget.pool.targetAmount - widget.pool.collectedAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribute'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pool.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining to target: Rs.$remainingAmount',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checkout mode: ${widget.pool.settlementLabel} | Pool type: ${widget.pool.styleLabel}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _upiController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'name@upi',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Max Rs.$remainingAmount',
                prefixText: 'Rs. ',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cloud,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                widget.pool.settlementMode == PoolSettlementMode.getBack
                    ? 'Get Back pools keep exact contribution history so refunds can return only what each member paid.'
                    : widget.pool.settlementMode == PoolSettlementMode.adminControl
                        ? 'Admin Control pools centralize checkout with the admin when the pool closes.'
                        : 'Splitwise pools divide the final checkout equally among all members.',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _paymentDone
                      ? Colors.green
                      : _paymentFailed
                          ? Colors.red
                          : AppTheme.ink,
                ),
                child: Text(_paymentDone ? 'Payment Successful' : 'Pay Now'),
              ),
            ),
            const SizedBox(height: 18),
            if (_paymentDone)
              const Center(
                child: Text(
                  'Contribution added to the pool.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_paymentFailed)
              const Center(
                child: Text(
                  'Payment failed. Please check the UPI ID and amount.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
