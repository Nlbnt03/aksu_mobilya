import 'package:flutter/material.dart';
import 'package:mobilya/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _statusMessage = "";
  bool _isSuccess = false;
  bool _isPasswordVisible = false; // Şifreyi göster/gizle durumu
  bool _isConfirmPasswordVisible = false; // Onay şifresi göster/gizle durumu

  Future<void> _savePassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _statusMessage = "⚠️ Şifre boş olamaz!";
        _isSuccess = false;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _statusMessage = "⚠️ Şifreler eşleşmiyor!";
        _isSuccess = false;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', _passwordController.text);

    setState(() {
      _statusMessage = "✅ Şifre başarıyla değiştirildi!";
      _isSuccess = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Menu()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Tamamen koyu arka plan
      appBar: AppBar(
        title: const Text(
          "🔐 Şifre Değiştir",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField("Yeni Şifre", _passwordController, _isPasswordVisible, () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
              const SizedBox(height: 12),
              _buildPasswordField("Şifreyi Onayla", _confirmPasswordController, _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _savePassword,
                  child: const Text(
                    "✅ Şifreyi Kaydet",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggleVisibility) {
    return SizedBox(
      width: 300,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade900,
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blueGrey.shade700),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
