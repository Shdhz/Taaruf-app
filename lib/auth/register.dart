import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(),
              SizedBox(height: screenSize.height * 0.02),
              _buildLogo(logoHeight),
              _buildTitle(),
              _buildSubtitle(screenSize.width),
              SizedBox(height: screenSize.height * 0.03),
              _buildRegisterForm(),
              SizedBox(height: screenSize.height * 0.03),
              _buildDivider(),
              SizedBox(height: screenSize.height * 0.03),
              _buildSocialSignIn(),
              SizedBox(height: screenSize.height * 0.03),
              _buildLoginRedirect(),
              const SizedBox(height: 20),
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.deepPurple, size: 28),
      onPressed: () => Get.back(),
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    );
  }

  Widget _buildLogo(double height) {
    return Center(
      child: Image.asset('images/wedding_ring.png', height: height),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Buat Akun Baru',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSubtitle(double width) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: width * 0.05),
        child: Text(
          'Daftar untuk memulai perjalanan taaruf Anda',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
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
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Nomor WhatsApp', BoxIcons.bxl_whatsapp),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email', BoxIcons.bx_envelope),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _passwordDecoration(
              'Password',
              _isPasswordVisible,
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: _passwordDecoration(
              'Konfirmasi Password',
              _isConfirmPasswordVisible,
              () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                activeColor: Colors.deepPurple,
              ),
              Expanded(
                child: Text(
                  'Saya menyetujui syarat dan ketentuan yang berlaku',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _agreeToTerms ? _validateAndRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: Text(
          'DAFTAR',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialSignIn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          child: Brand(Brands.google, size: 24),
          onTap: () {
            // Google sign-in handler (optional)
          },
        ),
      ],
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah memiliki akun?',
          style: GoogleFonts.poppins(color: Colors.grey.shade700),
        ),
        TextButton(
          onPressed: () => Get.offNamed(AppRoutes.login),
          child: Text(
            'Masuk',
            style: GoogleFonts.poppins(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Dengan mendaftar, Anda menyetujui Syarat & Ketentuan serta Kebijakan Privasi kami.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: Colors.deepPurple.shade400),
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

  InputDecoration _passwordDecoration(String hint, bool isVisible, VoidCallback toggleVisibility) {
    return _inputDecoration(hint, BoxIcons.bx_lock).copyWith(
      suffixIcon: IconButton(
        icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade600),
        onPressed: toggleVisibility,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Atau', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButton({required Widget child, required VoidCallback onTap}) {
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

  void _validateAndRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Semua kolom harus diisi');
      return;
    }

    if (!_isValidWhatsAppNumber(name)) {
      _showErrorSnackBar('Format nomor WhatsApp tidak valid');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Format email tidak valid');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password minimal 6 karakter');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Password dan konfirmasi password tidak cocok');
      return;
    }

    _registerUserToSupabase(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidWhatsAppNumber(String number) {
    return RegExp(r'^(\+62|62|0)[0-9]{9,12}$').hasMatch(number);
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  Future<void> _registerUserToSupabase(String email, String password) async {
    try {
      // TODO: Implementasikan koneksi ke Supabase Auth di sini
      // Misalnya:
      // final response = await supabase.auth.signUp(email: email, password: password);

      Get.offNamed(AppRoutes.login);
    } catch (e) {
      _showErrorSnackBar('Pendaftaran gagal: ${e.toString()}');
    }
  }
}
