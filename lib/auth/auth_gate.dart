import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/backend.dart';
import 'auth_screen.dart';

/// Keeps the sign-in choice off screen while a Supabase session is available.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.backend,
    required this.authenticatedBuilder,
  });

  final NextMateBackend backend;
  final Widget Function(BuildContext, Session, Future<void> Function())
  authenticatedBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Session? _session;
  late final StreamSubscription<AuthState> _subscription;
  bool _recoveringPassword = false;

  @override
  void initState() {
    super.initState();
    _session = widget.backend.auth.session;
    _subscription = widget.backend.auth.changes.listen((state) {
      if (!mounted) return;
      setState(() {
        _session = state.session;
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _recoveringPassword = true;
        } else if (state.event == AuthChangeEvent.signedOut) {
          _recoveringPassword = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await widget.backend.auth.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그아웃하지 못했어요. 다시 시도해 주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recoveringPassword && _session != null) {
      return PasswordRecoveryScreen(
        auth: widget.backend.auth,
        onCompleted: () => setState(() => _recoveringPassword = false),
      );
    }
    if (_session == null) return AuthScreen(auth: widget.backend.auth);
    return widget.authenticatedBuilder(context, _session!, _signOut);
  }
}
