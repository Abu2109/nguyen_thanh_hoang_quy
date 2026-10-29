import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String location = 'Chưa lấy vị trí';
  String biometric = 'Chưa xác thực';
  String translated = '';
  bool busy = false;
  final input = TextEditingController();
  String source = 'vi';
  String target = 'en';

  @override
  void dispose() { input.dispose(); super.dispose(); }

  void notice(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
  }

  Future<void> getLocation() async {
    setState(() => busy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception('Hãy bật GPS trên điện thoại');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Chưa được cấp quyền vị trí');
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (mounted) setState(() => location = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}');
    } catch (e) { notice(e); } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> authenticate() async {
    setState(() => busy = true);
    try {
      final auth = LocalAuthentication();
      if (!await auth.isDeviceSupported() || !await auth.canCheckBiometrics) throw Exception('Thiết bị chưa hỗ trợ hoặc chưa thiết lập sinh trắc học');
      final ok = await auth.authenticate(localizedReason: 'Xác thực để mở tính năng bảo vệ QFamily', biometricOnly: true);
      if (mounted) setState(() => biometric = ok ? 'Xác thực thành công' : 'Chưa xác thực');
    } catch (e) { notice(e); } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> translate() async {
    if (input.text.trim().isEmpty) return;
    setState(() => busy = true);
    try {
      // MyMemory public API: may impose quotas and may be unavailable.
      final uri = Uri.https('api.mymemory.translated.net', '/get', {'q': input.text.trim(), 'langpair': '$source|$target'});
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('Dịch vụ dịch trả về HTTP ${response.statusCode}');
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (data['responseStatus'] != 200) throw Exception('Dịch vụ dịch đang giới hạn yêu cầu');
      if (mounted) setState(() => translated = (data['responseData']?['translatedText'] ?? '').toString());
    } catch (e) { notice(e); } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QFamily • Tiện ích')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('B • Vị trí hiện tại', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const Text('Chỉ lấy vị trí khi bạn chủ động nhấn nút; chưa gửi về tài khoản phụ huynh.'),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Text(location), const SizedBox(height: 8), FilledButton.icon(onPressed: busy ? null : getLocation, icon: const Icon(Icons.location_on), label: const Text('Lấy vị trí GPS'))]))),
      const SizedBox(height: 18),
      const Text('E • Xác thực sinh trắc học', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Text(biometric), const SizedBox(height: 8), FilledButton.icon(onPressed: busy ? null : authenticate, icon: const Icon(Icons.fingerprint), label: const Text('Xác thực vân tay'))]))),
      const SizedBox(height: 18),
      const Text('F • Dịch văn bản trực tuyến', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const Text('Dịch văn bản qua mạng; chưa hỗ trợ dịch giọng nói realtime.'),
      const SizedBox(height: 8),
      TextField(controller: input, maxLines: 3, decoration: const InputDecoration(labelText: 'Nhập nội dung cần dịch', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(initialValue: source, items: const [DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')), DropdownMenuItem(value: 'en', child: Text('Tiếng Anh'))], onChanged: (v) { if (v != null) setState(() { source = v; target = v == 'vi' ? 'en' : 'vi'; }); })),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward)),
        Expanded(child: Text(target == 'en' ? 'Tiếng Anh' : 'Tiếng Việt')),
      ]),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: busy ? null : translate, icon: const Icon(Icons.translate), label: const Text('Dịch ngay')),
      if (translated.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(translated))),
      if (busy) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
    ]),
  );
}
