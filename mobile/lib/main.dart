import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api');

void main() => runApp(const LegalizacionesApp());

class ApiClient {
  static String? token;
  static Future<dynamic> call(String method, String path, [Map<String, dynamic>? body]) async {
    final response = await http.Request(method, Uri.parse('$apiBase$path'))
      ..headers.addAll({'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'})
      ..body = body == null ? '' : jsonEncode(body);
    final streamed = await response.send();
    final text = await streamed.stream.bytesToString();
    final data = text.isEmpty ? null : jsonDecode(text);
    if (streamed.statusCode >= 400) throw Exception(data?['error'] ?? 'No fue posible completar la solicitud');
    return data;
  }
}

class LegalizacionesApp extends StatelessWidget {
  const LegalizacionesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Legalizaciones USCOM',
    theme: ThemeData(colorSchemeSeed: const Color(0xff0a4e9b), useMaterial3: true),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(); final password = TextEditingController(); String? error; bool loading = false;
  Future<void> login() async { setState(() => loading = true); try { final data = await ApiClient.call('POST', '/auth/login', {'email': email.text.trim(), 'password': password.text}); ApiClient.token = data['token']; if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProjectsPage())); } catch (e) { setState(() => error = e.toString().replaceFirst('Exception: ', '')); } finally { if (mounted) setState(() => loading = false); } }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.receipt_long, size: 72, color: Color(0xff0a4e9b)), const SizedBox(height: 12), const Text('Legalizaciones USCOM', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo')), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')), const SizedBox(height: 18), FilledButton(onPressed: loading ? null : login, child: Text(loading ? 'Ingresando...' : 'Ingresar')), if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))) ])))));
}

class ProjectsPage extends StatefulWidget { const ProjectsPage({super.key}); @override State<ProjectsPage> createState() => _ProjectsPageState(); }
class _ProjectsPageState extends State<ProjectsPage> {
  List<dynamic> projects = []; String? error; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final data = await ApiClient.call('GET', '/projects'); if (mounted) setState(() { projects = List<dynamic>.from(data); error = null; }); } catch (e) { if (mounted) setState(() => error = e.toString()); } finally { if (mounted) setState(() => loading = false); } }
  Future<void> createProject() async { final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectFormPage())); if (result == true) load(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mis legalizaciones'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))]), floatingActionButton: FloatingActionButton.extended(onPressed: createProject, icon: const Icon(Icons.add), label: const Text('Nueva')), body: loading ? const Center(child: CircularProgressIndicator()) : error != null ? Center(child: Text(error!)) : projects.isEmpty ? const Center(child: Text('No hay proyectos registrados')) : ListView(children: projects.map((p) => Card(child: ListTile(title: Text(p['name']), subtitle: Text('${p['city']} · ${p['status']}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailPage(project: p))).then((_) => load()))).toList()));
}

class ProjectFormPage extends StatefulWidget { const ProjectFormPage({super.key}); @override State<ProjectFormPage> createState() => _ProjectFormPageState(); }
class _ProjectFormPageState extends State<ProjectFormPage> {
  final name = TextEditingController(); final city = TextEditingController(); final advance = TextEditingController(); String currency = 'COP'; String? error; bool saving = false;
  Future<void> save() async { setState(() => saving = true); try { await ApiClient.call('POST', '/projects', {'name': name.text, 'city': city.text, 'baseCurrency': currency, 'advanceCurrency': currency, 'advanceAmount': advance.text}); if (mounted) Navigator.pop(context, true); } catch (e) { setState(() => error = e.toString()); } finally { if (mounted) setState(() => saving = false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Nueva legalización')), body: Padding(padding: const EdgeInsets.all(18), child: ListView(children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre del proyecto')), TextField(controller: city, decoration: const InputDecoration(labelText: 'Ciudad')), DropdownButtonFormField<String>(value: currency, decoration: const InputDecoration(labelText: 'Moneda'), items: const [DropdownMenuItem(value: 'COP', child: Text('COP')), DropdownMenuItem(value: 'USD', child: Text('USD'))], onChanged: (v) => setState(() => currency = v!)), TextField(controller: advance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor del anticipo')), const SizedBox(height: 20), FilledButton(onPressed: saving ? null : save, child: Text(saving ? 'Guardando...' : 'Crear legalización')), if (error != null) Text(error!, style: const TextStyle(color: Colors.red)) ])));
}

class ProjectDetailPage extends StatefulWidget { final dynamic project; const ProjectDetailPage({super.key, required this.project}); @override State<ProjectDetailPage> createState() => _ProjectDetailPageState(); }
class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<dynamic> expenses = []; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final data = await ApiClient.call('GET', '/projects/${widget.project['id']}/expenses'); if (mounted) setState(() { expenses = List<dynamic>.from(data); loading = false; }); }
  Future<void> addExpense() async { final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseFormPage(projectId: widget.project['id']))); if (result == true) load(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.project['name'])), floatingActionButton: FloatingActionButton.extended(onPressed: addExpense, icon: const Icon(Icons.add), label: const Text('Gasto')), body: loading ? const Center(child: CircularProgressIndicator()) : ListView(children: [Padding(padding: const EdgeInsets.all(16), child: Text('Gastos registrados: ${expenses.length}', style: const TextStyle(fontWeight: FontWeight.bold))), ...expenses.map((e) => ListTile(title: Text(e['description']), subtitle: Text('${e['city']} · ${e['currency']}'), trailing: Text('${e['totalValue']}')))]));
}

class ExpenseFormPage extends StatefulWidget { final String projectId; const ExpenseFormPage({super.key, required this.projectId}); @override State<ExpenseFormPage> createState() => _ExpenseFormPageState(); }
class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final city = TextEditingController(); final description = TextEditingController(); final quantity = TextEditingController(text: '1'); final unitValue = TextEditingController(); String currency = 'COP'; String? error;
  Future<void> save() async { final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(content: const Text('¿QUIERE REGISTRAR ESTE GASTO?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('NO')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('SÍ'))])); if (confirm != true) return; try { await ApiClient.call('POST', '/projects/${widget.projectId}/expenses', {'city': city.text, 'expenseDate': DateTime.now().toIso8601String(), 'description': description.text, 'quantity': quantity.text, 'currency': currency, 'unitValue': unitValue.text}); if (mounted) Navigator.pop(context, true); } catch (e) { setState(() => error = e.toString()); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Registrar gasto')), body: Padding(padding: const EdgeInsets.all(18), child: ListView(children: [TextField(controller: city, decoration: const InputDecoration(labelText: 'Ciudad')), TextField(controller: description, decoration: const InputDecoration(labelText: 'Descripción')), TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')), DropdownButtonFormField<String>(value: currency, decoration: const InputDecoration(labelText: 'Moneda'), items: const [DropdownMenuItem(value: 'COP', child: Text('COP')), DropdownMenuItem(value: 'USD', child: Text('USD'))], onChanged: (v) => setState(() => currency = v!)), TextField(controller: unitValue, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor unitario')), const SizedBox(height: 20), FilledButton(onPressed: save, child: const Text('Registrar gasto')), if (error != null) Text(error!, style: const TextStyle(color: Colors.red)) ])));
}

