import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Fungsi login (siap integrasi dengan Supabase)
  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi');
      return;
    }

    try {
      // TODO: Ganti dengan autentikasi Supabase
      print("Email: $email, Password: $password");

      // Contoh Supabase login (aktifkan jika Supabase siap)
      // final response = await supabase.auth.signInWithPassword(
      //   email: email,
      //   password: password,
      // );
      // if (response.user != null) {
      //   Get.offNamed(AppRoutes.beranda);
      // }

      // Sementara: langsung navigasi
      Get.offNamed(AppRoutes.beranda);
    } catch (e) {
      Get.snackbar('Login Gagal', e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingHorizontal = screenSize.width > 600 ? 60.0 : 24.0;
    final double logoHeight = screenSize.height * 0.12;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenSize.height - 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  padding: EdgeInsets.zero,
                ),

                SizedBox(height: screenSize.height * 0.02),

                Center(
                  child: Image.asset(
                    'images/wedding_ring.png',
                    height: logoHeight,
                  ),
                ),

                SizedBox(height: screenSize.height * 0.03),

                Center(
                  child: Text(
                    'Selamat Datang Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: screenSize.width * 0.05,
                    ),
                    child: Text(
                      'Masuk untuk melanjutkan perjalanan taaruf Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenSize.height * 0.04),

                _buildLoginForm(),

                SizedBox(height: screenSize.height * 0.03),

                _buildDividerWithText(),

                SizedBox(height: screenSize.height * 0.03),

                _buildSocialLoginButtons(),

                SizedBox(height: screenSize.height * 0.03),

                _buildRegisterPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Email
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              hint: 'Email',
              icon: BoxIcons.bx_envelope,
            ),
          ),

          const SizedBox(height: 20),

          // Password
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _buildInputDecoration(
              hint: 'Password',
              icon: BoxIcons.bx_lock,
              isPassword: true,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Tambahkan navigasi ke halaman lupa password
              },
              child: Text(
                'Lupa password?',
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tombol Login
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'MASUK',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: Colors.deepPurple.shade400),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              )
              : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildDividerWithText() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Atau',
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          child: Brand(Brands.google, size: 24),
          onTap: () {
            // TODO: Tambahkan login Google via Supabase
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum memiliki akun?',
          style: GoogleFonts.poppins(color: Colors.grey.shade700),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.register),
          child: Text(
            'Daftar',
            style: GoogleFonts.poppins(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
