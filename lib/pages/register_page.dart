import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const RegisterPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  late AnimationController _controller;
  late Animation<double> floatingAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  bool isStrongPassword(String password) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUppercase && hasLowercase && hasNumber && hasSymbol;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      showMessage('Please fill all fields.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage('Email must contain @ symbol and valid format.');
      return;
    }

    if (mobile.length != 10) {
      showMessage('Mobile number must be exactly 10 digits.');
      return;
    }

    if (!isStrongPassword(password)) {
      showMessage(
        'Password must contain capital, small, number and symbol.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;

      showMessage('Registration successful.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } catch (e) {
      showMessage('Registration failed. Email may already exist.');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget passwordHint() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Password must include A-Z, a-z, number and symbol',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: floatingAnimation,
                builder: (context, child) {
                  return Positioned(
                    right: floatingAnimation.value,
                    bottom: 40,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white10 : Colors.black12,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.white24 : Colors.black12,
                            blurRadius: 100,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 460,
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF171717) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.white10 : Colors.black12,
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CREATE\nACCOUNT',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                        ),
                        IconButton(
                          onPressed: widget.toggleTheme,
                          icon: Icon(
                            widget.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    inputBox(
                      controller: nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    inputBox(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),

                  const SizedBox(height: 8),

Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Email must contain @ and proper format',
    style: TextStyle(
      color: Colors.grey.shade500,
      fontSize: 12,
    ),
  ),
),

                    const SizedBox(height: 16),
                    inputBox(
                      controller: mobileController,
                      hint: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),

                  const SizedBox(height: 8),

Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Mobile number must contain exactly 10 digits',
    style: TextStyle(
      color: Colors.grey.shade500,
      fontSize: 12,
    ),
  ),
),

                    const SizedBox(height: 16),
                    inputBox(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscure: !showPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    passwordHint(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Register',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              toggleTheme: widget.toggleTheme,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}