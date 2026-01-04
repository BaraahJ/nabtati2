import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  String? _nameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 139, 244, 167),
                  Color.fromARGB(255, 201, 165, 215),
                ],
                
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Color.fromARGB(255, 36, 4, 66),
                                ),
                                onPressed: () => context.go('/login'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color.fromARGB(255, 95, 94, 94),
                                  size: 32,
                                ),
                                onPressed: () => context.go('/home'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 50, 16, 84),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'انضم إلينا ودع حديقتك تزدهر\nأنشئ حسابك الجديد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 58, 10, 103),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildForm(context),
                          const SizedBox(height: 24),
                          const Text(
                            'أو تابع مع',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(
                                  Icons.g_mobiledata, const Color(0xFFDB4437),
                                  provider: 'google'),
                              const SizedBox(width: 16),
                              _socialButton(Icons.apple, Colors.black,
                                  provider: 'apple'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'لديك حساب بالفعل؟ ',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 140, 80, 164),
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text(
                                    'سجّل دخولك',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.all(20), // أصغر من السابق
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.54),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 72, 29, 109)),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                errorText: _nameError,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 14), // أصغر
            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 72, 29, 109)),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 14),
            // Password
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 72, 29, 109)),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20), // أصغر
            // Register Button
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                        _nameError = null;
                      });
                      try {
                        final user = await _authService.registerWithEmail(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                        if (user != null) context.go('/home');
                      } catch (e) {
                        if (e.toString().contains('اسم المستخدم موجود')) {
                          setState(() {
                            _nameError = 'اسم المستخدم موجود مسبقاً';
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 193, 163, 205),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}


  Widget _socialButton(IconData icon, Color color, {required String provider}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: () async {
          if (provider == 'google') {
            setState(() => _isLoading = true);
            try {
              final user = await _authService.registerWithGoogle();
              if (user != null) context.go('/home');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل تسجيل الدخول عبر Google: $e')),
              );
            } finally {
              setState(() => _isLoading = false);
            }
          } else if (provider == 'apple') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Apple Sign-In غير مفعل حالياً')),
            );
          }
        },
      ),
    );
  }
}
