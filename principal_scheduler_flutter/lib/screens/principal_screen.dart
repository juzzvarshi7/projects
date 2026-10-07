import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/principal_provider.dart';
import '../widgets/app_header.dart';
import '../utils/date_utils.dart';

class PrincipalScreen extends StatefulWidget {
  static const routeName = '/principal';
  const PrincipalScreen({Key? key}) : super(key: key);

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    Future.delayed(const Duration(seconds: 1), _setupPeriodic);
  }

  void _setupPeriodic() {
    Future.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) timer.cancel();
      _load();
    });
  }

  Future<void> _load() async {
    final prov = Provider.of<PrincipalProvider>(context, listen: false);
    await prov.loadAll(2); // using principal id 2 by default for demo
  }

  Future<void> _showSuggestDialog(int apptId) async {
    final _dateCtl = TextEditingController();
    final _timeCtl = TextEditingController();
    final prov = Provider.of<PrincipalProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suggest alternate time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _dateCtl, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')),
            const SizedBox(height: 8),
            TextField(controller: _timeCtl, decoration: const InputDecoration(hintText: 'HH:MM')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final dtText = '\${_dateCtl.text.trim()} \${_timeCtl.text.trim()}';
              final dt = DateUtilsLocal.parseLocal(dtText);
              if (dt == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid format. Use YYYY-MM-DD HH:MM')));
                return;
              }
              final iso = DateUtilsLocal.toIsoNoMicro(dt);
              prov.respond(apptId, 'suggest', suggested: iso).then((_) => _load());
              Navigator.pop(ctx);
            },
            child: const Text('Suggest'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PrincipalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal Dashboard'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const AppHeader(),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: Text('Pending Requests', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prov.pending.length,
                  itemBuilder: (ctx, i) {
                    final a = prov.pending[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('From: \${a.staffName}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                Text('Requested: \${DateUtilsLocal.prettyDateTime(a.requestedDatetime)}', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('\${a.title} — \${a.details}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    prov.respond(a.id, 'accept').then((_) => _load());
                                  },
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    prov.respond(a.id, 'decline').then((_) => _load());
                                  },
                                  child: const Text('Decline'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _showSuggestDialog(a.id),
                                  child: const Text('Suggest New Time'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text('History (Accepted/Declined/Suggested)', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prov.history.length,
                  itemBuilder: (ctx, i) {
                    final a = prov.history[i];
                    final status = a.status.toUpperCase();
                    return ListTile(
                      title: Text('[' + status + '] ' + a.title + ' — ' + DateUtilsLocal.prettyDateTime(a.requestedDatetime)),
                      subtitle: a.suggestedDatetime != null ? Text('New: ' + DateUtilsLocal.prettyDateTime(a.suggestedDatetime!)) : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
