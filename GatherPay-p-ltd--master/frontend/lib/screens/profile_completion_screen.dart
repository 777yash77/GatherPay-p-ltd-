import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({
    super.key,
    required this.session,
    required this.onCompleted,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onCompleted;
  final VoidCallback onLogout;

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _cityController;
  late final TextEditingController _upiController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.session.user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _mobileController = TextEditingController(text: user.mobileNumber);
    _cityController = TextEditingController(text: user.city);
    _upiController = TextEditingController(text: user.upiId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete every profile field to continue.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final updatedProfile = await ApiService.updateProfile(
        widget.session.token,
        widget.session.user.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          city: _cityController.text.trim(),
          upiId: _upiController.text.trim(),
          profileCompleted: true,
        ),
      );

      final session = AuthSession(token: widget.session.token, user: updatedProfile);
      await SessionService.saveSession(session);
      widget.onCompleted(session);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Finish the details we need for invites, contributions, and notifications.',
                          style: TextStyle(color: Color(0xFFD2D7D3), height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      children: [
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                        const SizedBox(height: 14),
                        TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                        const SizedBox(height: 14),
                        TextField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile Number')),
                        const SizedBox(height: 14),
                        TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
                        const SizedBox(height: 14),
                        TextField(controller: _upiController, decoration: const InputDecoration(labelText: 'UPI ID')),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            child: Text(_saving ? 'Saving...' : 'Save and Continue'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: widget.onLogout,
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
