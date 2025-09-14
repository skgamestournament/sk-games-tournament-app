import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTANT: We will create this file in the next step.
import 'home_page.dart'; 
import 'main.dart'; // To access the 'supabase' client

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'username': _usernameController.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success! Please check your email for verification.')),
        );
        _emailController.clear();
        _passwordController.clear();
        _usernameController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _signIn() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        // Navigate to HomePage on successful sign-in
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red),
        );
      }
    }
     if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'SK Games Tournament',
                    style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to the Arena',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 40),
                  const TabBar(
                    indicatorColor: Colors.deepPurpleAccent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'LOGIN'),
                      Tab(text: 'SIGN UP'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: Form(
                      key: _formKey,
                      child: TabBarView(
                        children: [
                          // Login Tab
                          _buildAuthForm(isLogin: true),
                          // Sign Up Tab
                          _buildAuthForm(isLogin: false),
                        ],
                      ),
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

  Widget _buildAuthForm({required bool isLogin}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isLogin) ...[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
             validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              return null;
            },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
           validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              return null;
            },
        ),
        const SizedBox(height: 32),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: isLogin ? _signIn : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: Text(isLogin ? 'LOGIN' : 'SIGN UP'),
              ),
      ],
    );
  }
}
