import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../exceptions/auth_exception.dart';

enum AuthState { signUp, logIn }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  AuthFormState createState() => AuthFormState();
}

class AuthFormState extends State<AuthForm> with SingleTickerProviderStateMixin {
  AuthState _state = AuthState.logIn;
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, String> data = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _offsetAnimation;

  bool get _isLogin {
    return _state == AuthState.logIn;
  } 

  bool get _isSignUp {
    return _state == AuthState.signUp;
  } 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
  }

  @override 
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin) {
        _state = AuthState.signUp;
        _controller?.forward();
      } else {
        _state = AuthState.logIn;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok')
          )
        ]
      )
    );
  }

  Future<void> _submit() async {
    AuthProvider auth = Provider.of(context, listen: false);
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    
    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    
    try {
      if (_isLogin) {
        await auth.login(data['email']!, data['password']!);
      } else {
        await auth.signUp(data['email']!, data['password']!);
      } 
    } on AuthException catch (e) {
      _showErrorDialog(e.toString());
    } catch (e) {
      _showErrorDialog('An unexpected error occurred.');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final devSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _isLogin ? 310 : 400,
        width: devSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-mail'
                ),
                onSaved: (email) => data['email'] = email ?? '',
                validator: (mail) {
                  final email = mail ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Email is invalid';
                  }
                  return null;
                }
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password'
                ),
                obscureText: true,
                controller: _passController,
                onSaved: (pass) => data['password'] = pass ?? '',
                validator: (pass) {
                  final password = pass ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Password is too short';
                  }
                  return null;
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _isLogin ? 0 : 60,
                  maxHeight: _isLogin ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _offsetAnimation!,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password'
                      ),
                      obscureText: true,
                      validator: _isSignUp ? (pass) {
                        final password = pass ?? '';
                        if (password != _passController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      } : null
                    ),
                  )
                ),
              ),
              const SizedBox(height: 20),
              _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  primary: Colors.black,
                  onPrimary: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 18
                  )
                ),
                child: Text(_isLogin ? 'Enter' : 'Register')
              ),
              const Spacer(),
              _isLoading
              ? const Text('Loading...')
              : TextButton(
                onPressed: _switchAuthMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  textStyle: const TextStyle(
                    fontSize: 18
                  )
                ),
                child: Text(_isLogin ? 'Create new account' : 'I already have an account'),
              )
            ]
          )
        ),  
      )
    );
  }
}