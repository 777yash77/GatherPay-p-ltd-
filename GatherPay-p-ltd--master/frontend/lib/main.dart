import 'package:flutter/material.dart';

import 'models/app_models.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'services/session_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GatherPayApp());
}

class GatherPayApp extends StatefulWidget {
  const GatherPayApp({super.key});

  @override
  State<GatherPayApp> createState() => _GatherPayAppState();
}

class _GatherPayAppState extends State<GatherPayApp> {
  AuthSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await SessionService.loadSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  Future<void> _setSession(AuthSession session) async {
    await SessionService.saveSession(session);
    if (!mounted) {
      return;
    }
    setState(() {
      _session = session;
    });
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget home;

    if (_loading) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_session == null) {
      home = LoginScreen(onAuthenticated: _setSession);
    } else if (!_session!.user.profileCompleted) {
      home = ProfileCompletionScreen(
        session: _session!,
        onCompleted: _setSession,
        onLogout: _logout,
      );
    } else {
      home = DashboardScreen(
        session: _session!,
        onSessionUpdated: _setSession,
        onLogout: _logout,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GatherPay',
      theme: AppTheme.theme,
      home: home,
    );
  }
}
