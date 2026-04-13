import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/ui_widgets.dart';

class AuthOverlay extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthOverlay({super.key, required this.onAuthenticated});

  @override
  State<AuthOverlay> createState() => _AuthOverlayState();
}

class _AuthOverlayState extends State<AuthOverlay> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    bool success;
    if (_isLogin) {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
        return;
      }
      success = await AuthService().login(_emailController.text, _passwordController.text);
    } else {
      if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields to register')));
        return;
      }
      success = await AuthService().register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) {
      return;
    }
    if (success) {
      widget.onAuthenticated();
    } else {
      final err = AuthService().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Authentication failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      width: 360,
      padding: const EdgeInsets.all(20),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isLogin ? 'Login' : 'Register', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!_isLogin)
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 18),
            if (_isLoading)
              const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()))
            else
              PrimaryButton(
                label: _isLogin ? 'Login' : 'Register',
                onPressed: _submit,
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
