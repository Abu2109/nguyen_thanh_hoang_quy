
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Co dinh man hinh doc.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const QFamilyApp());
}

class QFamilyApp extends StatelessWidget {
  const QFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QFamily - Quan ly tre em',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFDCE4F0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFDCE4F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF2563EB),
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// ====================================
// MAN HINH DANG NHAP VA DANG KY
// ====================================

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isRegister = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkBlue = Color(0xFF172B50);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    setState(() {
      _isRegister = register;
      _hidePassword = true;
      _hideConfirmPassword = true;
    });

    _formKey.currentState?.reset();

    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui long nhap email';
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Email khong hop le';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui long nhap mat khau';
    }

    if (value.length < 8) {
      return 'Mat khau phai co it nhat 8 ky tu';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Se thay bang loi goi API public that.
    // Khong gia lap dang nhap thanh cong.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBlue,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _isRegister
              ? 'Giao dien dang ky da san sang. '
              'Can ket noi API de tao tai khoan.'
              : 'Giao dien dang nhap da san sang. '
              'Can ket noi API va OTP.',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withAlpha(45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.family_restroom_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'QFamily',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: darkBlue,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Ket noi gia dinh - Bao ve yeu thuong',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              'Dang nhap',
              !_isRegister,
                  () => _switchMode(false),
            ),
          ),
          Expanded(
            child: _modeButton(
              'Dang ky',
              _isRegister,
                  () => _switchMode(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(
      String title,
      bool selected,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 8,
            ),
          ]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected
                ? primaryBlue
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRegister
                ? 'Tao tai khoan moi'
                : 'Chao mung tro lai!',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _isRegister
                ? 'Dang ky tai khoan phu huynh'
                : 'Dang nhap de quan ly gia dinh',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 25),

          if (_isRegister) ...[
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ho va ten',
                hintText: 'Nhap ho va ten',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Vui long nhap ho ten';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Dia chi email',
              hintText: 'example@gmail.com',
              prefixIcon: Icon(
                Icons.email_outlined,
              ),
            ),
            validator: _validateEmail,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            textInputAction: _isRegister
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Mat khau',
              hintText: 'Nhap mat khau',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),
            ),
            validator: _validatePassword,
          ),

          if (_isRegister) ...[
            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _hideConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xac nhan mat khau',
                hintText: 'Nhap lai mat khau',
                prefixIcon: const Icon(
                  Icons.verified_user_outlined,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _hideConfirmPassword =
                      !_hideConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui long xac nhan mat khau';
                }

                if (value != _passwordController.text) {
                  return 'Mat khau khong khop';
                }

                return null;
              },
            ),
          ],

          const SizedBox(height: 26),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegister
                        ? 'Tao tai khoan'
                        : 'Dang nhap',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRegister
                    ? 'Da co tai khoan? '
                    : 'Chua co tai khoan? ',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),

              InkWell(
                onTap: () {
                  _switchMode(!_isRegister);
                },
                child: Text(
                  _isRegister
                      ? 'Dang nhap'
                      : 'Dang ky ngay',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 24,
              ),
              child: Column(
                children: [
                  _buildHeader(),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1E3A8A,
                          ).withAlpha(13),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildModeSelector(),

                        const SizedBox(height: 25),

                        _buildForm(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 17,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'An toan - Bao mat - Ket noi gia dinh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
