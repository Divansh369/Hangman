import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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
      success = await AuthService().login(_emailController.text, _passwordController.text);
    } else {
      success = await AuthService().register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
    }

    setState(() => _isLoading = false);
    if (success) {
      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isLogin ? 'Login' : 'Register', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!_isLogin)
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
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
