import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipCtrl   = TextEditingController();
  final _portCtrl = TextEditingController();
  bool   _testing    = false;
  String _testResult = '';
  bool   _testOk     = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final ip   = await ApiService.getSavedIp();
    final port = await ApiService.getSavedPort();
    setState(() {
      _ipCtrl.text   = ip;
      _portCtrl.text = port.toString();
    });
  }

  Future<void> _save() async {
    final ip   = _ipCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 3000;
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the PC IP address'), backgroundColor: Colors.orange),
      );
      return;
    }
    await ApiService.saveServerSettings(ip, port);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Settings saved!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _testConnection() async {
    final ip   = _ipCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 3000;
    await ApiService.saveServerSettings(ip, port);
    setState(() { _testing = true; _testResult = ''; });
    final ok = await ApiService.testConnection();
    setState(() {
      _testing    = false;
      _testOk     = ok;
      _testResult = ok
          ? '✅ Connected! Server is reachable.'
          : '❌ Cannot connect. Make sure:\n• PC server is running (node server.js)\n• Phone and PC are on the same Wi-Fi\n• IP address is correct';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('How to find your PC IP',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    '1. On your PC, open Command Prompt\n'
                    '2. Type: ipconfig\n'
                    '3. Look for "IPv4 Address" under your Wi-Fi adapter\n'
                    '4. It looks like: 192.168.x.x\n\n'
                    'The server also prints it when it starts.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // IP field
          TextField(
            controller: _ipCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'PC IP Address',
              hintText:  'e.g. 192.168.1.10',
              prefixIcon: Icon(Icons.computer),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Port field
          TextField(
            controller: _portCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText:  '3000',
              prefixIcon: Icon(Icons.router),
              border: OutlineInputBorder(),
              helperText: 'Default is 3000',
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          FilledButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Settings'),
            onPressed: _save,
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),

          // Test button
          OutlinedButton.icon(
            icon: _testing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.wifi_find_outlined),
            label: Text(_testing ? 'Testing…' : 'Test Connection'),
            onPressed: _testing ? null : _testConnection,
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),

          // Test result
          if (_testResult.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _testOk ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _testOk ? Colors.green.shade300 : Colors.red.shade300,
                ),
              ),
              child: Text(
                _testResult,
                style: TextStyle(
                  color: _testOk ? Colors.green.shade800 : Colors.red.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
