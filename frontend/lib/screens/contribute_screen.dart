import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({
    super.key,
    required this.token,
    required this.pool,
    required this.currentUser,
    required this.onPoolUpdated,
  });

  final String token;
  final PoolModel pool;
  final UserProfile currentUser;
  final ValueChanged<PoolModel> onPoolUpdated;

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  late final Razorpay _razorpay;
  final _amountController = TextEditingController();
  late PoolModel _pool;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _pool = widget.pool;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _contributeToBackend(response.paymentId!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
    setState(() {
      _submitting = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet if needed
  }

  Future<void> _contributeToBackend(String paymentId) async {
    try {
      final enteredAmount = int.parse(_amountController.text.trim());
      final updatedPool = await ApiService.contribute(
        token: widget.token,
        poolId: _pool.id,
        amount: enteredAmount,
        upiId: paymentId,
      );
      widget.onPoolUpdated(updatedPool);
      if (!mounted) return;
      setState(() {
        _pool = updatedPool;
        _amountController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution added successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _submitPayment() async {
    final enteredAmount = int.tryParse(_amountController.text.trim()) ?? 0;
    final remainingAmount = _pool.targetAmount - _pool.collectedAmount;

    if (enteredAmount <= 0 || enteredAmount > remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount within the remaining target.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    var options = {
      'key': 'rzp_test_Sa8ru5f1To0dwi', // Replace with your Razorpay test key
      'amount': enteredAmount * 100, // Amount in paise
      'name': 'GatherPay',
      'description': 'Contribution to ${_pool.name}',
      'prefill': {
        'contact': widget.currentUser.mobileNumber,
        'email': '', // Add email if available
      }
    };

    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = (_pool.targetAmount - _pool.collectedAmount).clamp(0, _pool.targetAmount);
    final contributor = _pool.members
        .where((member) => normalizePhoneNumber(member.phoneNumber) == normalizePhoneNumber(widget.currentUser.mobileNumber))
        .cast<PoolMember?>()
        .firstWhere((_) => true, orElse: () => null);

    return Scaffold(
      appBar: AppBar(title: const Text('Contribute')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_pool.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Target Rs.${_pool.targetAmount} | Collected Rs.${_pool.collectedAmount}', style: const TextStyle(color: Color(0xFFD2D7D3))),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _pool.progress, minHeight: 12),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.softGreen, borderRadius: BorderRadius.circular(24)),
              child: Text(
                '${contributor?.name ?? widget.currentUser.name} has contributed Rs.${contributor?.contributedAmount ?? 0}. Remaining amount: Rs.$remainingAmount',
              ),
            ),
            const SizedBox(height: 18),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount', hintText: 'Max Rs.$remainingAmount', prefixText: 'Rs. ')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitPayment,
                child: Text(_submitting ? 'Processing...' : 'Pay with Razorpay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
