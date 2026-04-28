import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
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
  bool _obscurePassword = true;

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
    if (!mounted) return;
    if (success) {
      widget.onAuthenticated();
    } else {
      final err = AuthService().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Authentication failed. Check your credentials.')),
      );
    }
  }

  InputDecoration _glassInput(ColorScheme cs, {required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.textMuted.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, size: 20, color: cs.textMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: cs.glassBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 380.0 : (context.isTablet ? 440.0 : 500.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(28),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowBadge(
              icon: _isLogin ? Icons.login_rounded : Icons.person_add_rounded,
              color: cs.primary,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _isLogin ? 'Sign in to continue' : 'Join the hangman arena',
              style: TextStyle(fontSize: 13, color: cs.textMuted),
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              TextField(
                controller: _usernameController,
                style: TextStyle(color: cs.textPrimary),
                decoration: _glassInput(cs, hint: 'Username', icon: Icons.person_outline),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _emailController,
              style: TextStyle(color: cs.textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: _glassInput(cs, hint: 'Email', icon: Icons.email_outlined),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: cs.textPrimary),
              obscureText: _obscurePassword,
              decoration: _glassInput(
                cs,
                hint: 'Password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: cs.textMuted,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_isLoading)
              SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: cs.primary)))
            else
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isLogin ? 'Sign In' : 'Create Account',
                  icon: _isLogin ? Icons.login_rounded : Icons.person_add_rounded,
                  onPressed: _submit,
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Sign In',
                style: TextStyle(color: cs.primary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
