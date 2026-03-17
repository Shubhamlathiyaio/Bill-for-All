import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;
  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String _priority = 'medium';
  String _status   = 'pending';
  bool   _saving   = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.todo?.title       ?? '');
    _descCtrl  = TextEditingController(text: widget.todo?.description ?? '');
    _priority  = widget.todo?.priority ?? 'medium';
    _status    = widget.todo?.status   ?? 'pending';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await ApiService.updateTodo(
          widget.todo!.id,
          title:       _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority:    _priority,
          status:      _status,
        );
      } else {
        await ApiService.createTodo(
          title:       _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority:    _priority,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Todo' : 'New Todo'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText:  'What needs to be done?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:  'Optional details…',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Priority
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'low',
                  label: Text('Low'),
                  icon: Icon(Icons.keyboard_arrow_down),
                ),
                ButtonSegment(
                  value: 'medium',
                  label: Text('Medium'),
                  icon: Icon(Icons.drag_handle),
                ),
                ButtonSegment(
                  value: 'high',
                  label: Text('High'),
                  icon: Icon(Icons.keyboard_arrow_up),
                ),
              ],
              selected: {_priority},
              onSelectionChanged: (val) => setState(() => _priority = val.first),
            ),

            // Status (edit only)
            if (_isEditing) ...[
              const SizedBox(height: 24),
              const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pending',
                    label: Text('Pending'),
                    icon: Icon(Icons.hourglass_empty),
                  ),
                  ButtonSegment(
                    value: 'completed',
                    label: Text('Completed'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {_status},
                onSelectionChanged: (val) => setState(() => _status = val.first),
              ),
            ],

            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_isEditing ? Icons.save_outlined : Icons.add),
              label: Text(_isEditing ? 'Update Todo' : 'Create Todo'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ),
      ),
    );
  }
}
