import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'screens/tools_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const QFamilyApp());
}

class QFamilyApp extends StatelessWidget {
  const QFamilyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'QFamily',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F7FD),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    ),
    home: const AuthScreen(),
  );
}

void showError(BuildContext context, Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool registering = false;
  bool loading = false;
  bool hidden = true;

  @override
  void dispose() {
    username.dispose();
    fullName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  String? requiredField(String? value) =>
      value == null || value.trim().isEmpty ? 'Không được để trống' : null;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false) || loading) return;
    setState(() => loading = true);
    try {
      if (registering) {
        await ApiService.register(
          username: username.text.trim(),
          fullName: fullName.text.trim(),
          email: email.text.trim(),
          password: password.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công. Hãy đăng nhập.')),
        );
        setState(() => registering = false);
        password.clear();
        confirmPassword.clear();
      } else {
        final result = await ApiService.login(
          username: username.text.trim(),
          password: password.text,
        );
        if (!mounted) return;
        final user = Map<String, dynamic>.from(result['user'] as Map);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => user['role'] == 'Parent'
              ? ParentScreen(user: user)
              : ChildScreen(user: user),
        ));
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.family_restroom, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 15),
              const Text('QFamily', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800)),
              const Text('Kết nối gia đình - Bảo vệ yêu thương'),
              const SizedBox(height: 25),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Đăng nhập')),
                          ButtonSegment(value: true, label: Text('Đăng ký')),
                        ],
                        selected: {registering},
                        onSelectionChanged: loading
                            ? null
                            : (value) => setState(() => registering = value.first),
                      ),
                      const SizedBox(height: 24),
                      Text(registering ? 'Tạo tài khoản phụ huynh' : 'Chào mừng trở lại!',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: username,
                        decoration: const InputDecoration(labelText: 'Tên đăng nhập hoặc email', prefixIcon: Icon(Icons.person_outline)),
                        validator: requiredField,
                      ),
                      if (registering) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: fullName,
                          decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.badge_outlined)),
                          validator: requiredField,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                          validator: (value) {
                            if (requiredField(value) != null) return 'Vui lòng nhập email';
                            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
                                ? null : 'Email không hợp lệ';
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: password,
                        obscureText: hidden,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => hidden = !hidden),
                            icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nhập mật khẩu';
                          if (registering && value.length < 6) return 'Tối thiểu 6 ký tự';
                          return null;
                        },
                      ),
                      if (registering) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: confirmPassword,
                          obscureText: hidden,
                          decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu', prefixIcon: Icon(Icons.verified_user_outlined)),
                          validator: (value) => value == password.text ? null : 'Mật khẩu không khớp',
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: loading ? null : submit,
                        icon: loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.arrow_forward),
                        label: Text(registering ? 'Tạo tài khoản' : 'Đăng nhập'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('An toàn • Bảo mật • Kết nối gia đình', style: TextStyle(color: Colors.blueGrey)),
            ]),
          ),
        ),
      ),
    ),
  );
}

class ParentScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ParentScreen({super.key, required this.user});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  late Future<List<dynamic>> childrenFuture;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() => setState(() => childrenFuture = ApiService.getChildren());

  Future<void> addChild() async {
    final formKey = GlobalKey<FormState>();
    final username = TextEditingController();
    final fullName = TextEditingController();
    final password = TextEditingController();
    final birthDate = TextEditingController();
    bool saving = false;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, updateDialog) => AlertDialog(
            title: const Text('Thêm tài khoản trẻ em'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      controller: username,
                      decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                      validator: (v) => v == null || v.trim().length < 3 ? 'Ít nhất 3 ký tự' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fullName,
                      decoration: const InputDecoration(labelText: 'Họ và tên trẻ'),
                      validator: (v) => v == null || v.trim().length < 2 ? 'Ít nhất 2 ký tự' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      decoration: const InputDecoration(labelText: 'Mật khẩu trẻ'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 8 ? 'Ít nhất 8 ký tự theo API hiện tại' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: birthDate,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Ngày sinh (không bắt buộc)', suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime(2015),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          birthDate.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ]),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Hủy')),
              FilledButton(
                onPressed: saving ? null : () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  updateDialog(() => saving = true);
                  try {
                    await ApiService.createChild(
                      username: username.text.trim(),
                      fullName: fullName.text.trim(),
                      password: password.text,
                      birthDate: birthDate.text.isEmpty ? null : birthDate.text,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (mounted) refresh();
                  } catch (error) {
                    if (dialogContext.mounted) showError(dialogContext, error);
                    updateDialog(() => saving = false);
                  }
                },
                child: Text(saving ? 'Đang lưu...' : 'Tạo tài khoản'),
              ),
            ],
          ),
        ),
      );
    } finally {
      // Controller lifecycle is tied to this dialog invocation.
      // Do not dispose synchronously while closing animation is active.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('QFamily • Phụ huynh'),
      actions: [
        IconButton(onPressed: refresh, icon: const Icon(Icons.refresh), tooltip: 'Làm mới'),
        IconButton(
          tooltip: 'Đăng xuất',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ApiService.logout();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
          },
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: addChild,
      icon: const Icon(Icons.person_add),
      label: const Text('Thêm trẻ'),
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        refresh();
        try { await childrenFuture; } catch (_) {}
      },
      child: ListView(padding: const EdgeInsets.all(18), children: [
        Card(
          color: const Color(0xFFDBEAFE),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Xin chào, phụ huynh!', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${widget.user['fullName'] ?? widget.user['username']}'),
              const SizedBox(height: 8),
              const Text('Quản lý tài khoản trẻ em trong gia đình.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(child: ListTile(leading: const Icon(Icons.apps), title: const Text('GPS • Vân tay • Dịch ngôn ngữ'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsScreen())))),
        const SizedBox(height: 20),
        const Text('Danh sách trẻ em', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        FutureBuilder<List<dynamic>>(
          future: childrenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Card(child: Padding(padding: const EdgeInsets.all(20), child: Text('Không tải được danh sách: ${snapshot.error}')));
            }
            final children = snapshot.data ?? [];
            if (children.isEmpty) return const Card(child: ListTile(title: Text('Chưa có trẻ em'), subtitle: Text('Nhấn Thêm trẻ để tạo tài khoản.')));
            return Column(children: children.map((item) {
              final child = Map<String, dynamic>.from(item as Map);
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.child_care)),
                  title: Text('${child['fullName'] ?? 'Trẻ em'}'),
                  subtitle: Text('Tài khoản: ${child['username'] ?? 'Chưa liên kết'}\nNgày sinh: ${child['birthDate'] ?? 'Chưa có'}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async { final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child))); if (changed == true) refresh(); },
                ),
              );
            }).toList());
          },
        ),
        const SizedBox(height: 90),
      ]),
    ),
  );
}

class ChildDetailScreen extends StatelessWidget {
  final Map<String, dynamic> child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ trẻ em')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Center(child: CircleAvatar(radius: 45, child: Icon(Icons.child_care, size: 45))),
      const SizedBox(height: 20),
      Card(child: Column(children: [
        ListTile(title: const Text('Họ tên'), subtitle: Text('${child['fullName'] ?? ''}')),
        ListTile(title: const Text('Tên đăng nhập'), subtitle: Text('${child['username'] ?? ''}')),
        ListTile(title: const Text('Ngày sinh'), subtitle: Text('${child['birthDate'] ?? 'Chưa có'}')),
        ListTile(title: const Text('Mã hồ sơ'), subtitle: Text('${child['childId'] ?? ''}')),
      ])),
      const SizedBox(height: 15),
      FilledButton(onPressed: () async {
        final name = TextEditingController(text: '${child['fullName'] ?? ''}');
        final result = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(title: const Text('Sửa họ tên'), content: TextField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(ctx, name.text.trim()), child: const Text('Lưu'))]));
        if (result == null || result.isEmpty || !context.mounted) return;
        try { await ApiService.updateChild(childId: child['childId'] as int, fullName: result, birthDate: child['birthDate']?.toString()); if (context.mounted) Navigator.pop(context, true); } catch (e) { if (context.mounted) showError(context, e); }
      }, child: const Text('Cập nhật họ tên')),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: () async {
        try {
          if (child['isActive'] == false) { await ApiService.restoreChild(child['childId'] as int); }
          else { await ApiService.disableChild(child['childId'] as int); }
          if (context.mounted) Navigator.pop(context, true);
        } catch (e) { if (context.mounted) showError(context, e); }
      }, child: Text(child['isActive'] == false ? 'Khôi phục tài khoản' : 'Vô hiệu hóa tài khoản')),
    ]),
  );
}

class ChildScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ChildScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QFamily • Trẻ em'), actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await ApiService.logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
        },
      ),
    ]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 20),
      const CircleAvatar(radius: 45, child: Icon(Icons.child_care, size: 45)),
      const SizedBox(height: 18),
      Center(child: Text('Xin chào, ${user['fullName'] ?? user['username']}!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      const SizedBox(height: 12),
      Card(child: ListTile(leading: const Icon(Icons.apps), title: const Text('GPS • Vân tay • Dịch ngôn ngữ'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsScreen())))),
      const Card(child: ListTile(
        leading: Icon(Icons.shield_outlined),
        title: Text('Tài khoản trẻ em'),
        subtitle: Text('Đã đăng nhập với quyền Child.'),
      )),
      const Card(child: ListTile(
        leading: Icon(Icons.access_time),
        title: Text('Giới hạn sử dụng'),
        subtitle: Text('Sẽ hiển thị khi Backend có API quy tắc sử dụng.'),
      )),
    ]),
  );
}
