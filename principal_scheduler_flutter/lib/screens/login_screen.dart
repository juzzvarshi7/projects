import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String _msg = '';

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final err = auth.login(_username.text, _password.text);
    if (err != null) {
      setState(() => _msg = err);
      return;
    }

    final user = auth.user!;
    if (user.role == 'staff') {
      Navigator.pushReplacementNamed(context, '/staff');
    } else {
      Navigator.pushReplacementNamed(context, '/principal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 8),
              Text('Welcome to Principal Scheduler', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'username or email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'password'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _doLogin,
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_msg, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
