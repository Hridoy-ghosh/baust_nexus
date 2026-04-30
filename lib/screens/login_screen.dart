import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import 'signup_screen.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';
import 'guest_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.error));
      auth.clearError();
      return;
    }
    if (auth.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else if (auth.isTeacher) {
      Navigator.pushReplacementNamed(context, '/teacher_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/student_dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const SizedBox(height: 60),
                Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)]), child: const Icon(Icons.school, size: 50, color: Color(0xFF1A237E))),
                const SizedBox(height: 24),
                Text(AppConstants.appName, style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Sign in to continue', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
                  child: Column(children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => v?.isEmpty == true ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v!), activeColor: AppColors.primary),
                      Text('Remember me', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                      const Spacer(),
                      TextButton(onPressed: (){}, child: Text('Forgot Password?', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary))),
                    ]),
                    const SizedBox(height: 16),
                    Consumer<AuthService>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign In', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? ", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                      GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary))),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestScreen())),
                      icon: const Icon(Icons.person_outline),
                      label: Text('Continue as Guest', style: GoogleFonts.poppins()),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}