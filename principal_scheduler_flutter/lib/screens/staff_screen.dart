import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';
import '../services/db_service_json.dart';
import '../utils/date_utils.dart';
import '../widgets/app_header.dart';

class StaffScreen extends StatefulWidget {
  static const routeName = '/staff';
  const StaffScreen({Key? key}) : super(key: key);

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _titleCtl = TextEditingController();
  final _detailsCtl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _statusMsg = '';
  int? _principalId;

  @override
  void initState() {
    super.initState();
    _loadPrincipals();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  Future<void> _loadPrincipals() async {
    final db = DBServiceJson();
    await db.load();
    final principals = db.getPrincipals();
    if (principals.isNotEmpty) {
      setState(() => _principalId = principals.first.id);
    }
  }

  Future<void> _loadAppointments() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final staffProv = Provider.of<StaffProvider>(context, listen: false);
    if (auth.user != null) {
      await staffProv.loadAppointments(auth.user!.id);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  String _selectedDateTimeText() {
    if (_selectedDate == null || _selectedTime == null) return 'Choose Date & Time';
    final dt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  Future<void> _sendRequest() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final staffProv = Provider.of<StaffProvider>(context, listen: false);

    if (_selectedDate == null || _selectedTime == null) {
      setState(() => _statusMsg = 'Please choose date and time');
      return;
    }
    if (_principalId == null) {
      setState(() => _statusMsg = 'No principal found');
      return;
    }

    final dt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    final iso = DateUtilsLocal.toIsoNoMicro(dt);

    await staffProv.sendRequest(
      staffId: auth.user!.id,
      principalId: _principalId!,
      title: _titleCtl.text.trim().isEmpty ? 'Meeting' : _titleCtl.text.trim(),
      details: _detailsCtl.text.trim(),
      requestedIso: iso,
    );

    _titleCtl.clear();
    _detailsCtl.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _statusMsg = 'Request Sent Successfully!';
    });

    await _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final staffProv = Provider.of<StaffProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          TextButton(
            onPressed: () {
              // logout
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleCtl,
                        decoration: const InputDecoration(labelText: 'Title (e.g., General, Department)'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailsCtl,
                        decoration: const InputDecoration(labelText: 'Details'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Choose Date'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time),
                            label: const Text('Choose Time'),
                          ),
                          const Spacer(),
                          Text(_selectedDateTimeText()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _sendRequest,
                              child: const Text('Send Request'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _loadAppointments,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMsg, style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Previous Requests', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: staffProv.appointments.length,
                itemBuilder: (ctx, i) {
                  final a = staffProv.appointments[i];
                  final status = a.status.toUpperCase();
                  Color statusColor;
                  switch (status) {
                    case 'PENDING':
                      statusColor = Colors.orange;
                      break;
                    case 'ACCEPTED':
                      statusColor = Colors.green;
                      break;
                    case 'DECLINED':
                      statusColor = Colors.red;
                      break;
                    case 'SUGGESTED':
                      statusColor = Colors.blue;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text('\${a.title}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Requested: \${DateUtilsLocal.prettyDateTime(a.requestedDatetime)}'),
                          if (a.suggestedDatetime != null) Text('Suggested: \${DateUtilsLocal.prettyDateTime(a.suggestedDatetime!)}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
