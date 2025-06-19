import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:icons_plus/icons_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taaruf_app/main.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  bool _isPasswordVisible = false;

  // ignore: unused_field
  String? _userId;

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  // Fungsi login (siap integrasi dengan Supabase)
  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password wajib diisi',
        backgroundColor: Colors.amber[100],
        colorText: Colors.black,
      );
      return;
    }

    try {
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

  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      const webClientId =
          '866202077954-akl5bgo01vhm27g4ih75f7mssg4om1it.apps.googleusercontent.com';

      final googleUser =
          await GoogleSignIn(serverClientId: webClientId).signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Token Google tidak ditemukan';
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) throw 'Login ke Supabase gagal: User null';

      // ✅ Tambahkan ke tabel `profiles` jika belum ada
      final profileCheck =
          await supabase
              .from('profiles')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();

      if (profileCheck == null) {
        final fullName = user.userMetadata?['name'] ?? 'Pengguna Baru';
        final now = DateTime.now().toIso8601String();

        await supabase.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'created_at': now,
          'updated_at': now,
        });
      }

      // 🚀 Navigasi ke halaman utama
      Get.offNamed(AppRoutes.beranda);
    } catch (e) {
      Get.snackbar('Login Gagal', e.toString());
    } finally {
      isGoogleLoading.value = false;
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
            // ignore: deprecated_member_use
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
              onPressed: () {},
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
        Obx(() {
          return _buildSocialButton(
            child:
                isGoogleLoading.value
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Brand(Brands.google, size: 24),
            onTap: isGoogleLoading.value ? null : loginWithGoogle,
          );
        }),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required Future<void> Function()? onTap,
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
              // ignore: deprecated_member_use
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
