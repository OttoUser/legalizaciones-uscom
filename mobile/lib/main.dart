import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api');
void main() => runApp(const LegalizacionesApp());

class Api {
  static String? token;
  static Future<dynamic> request(String method, String path, [Map<String,dynamic>? body]) async {
    final response = await http.Request(method, Uri.parse('$apiBase$path'))
      ..headers.addAll({'Content-Type':'application/json', if(token != null) 'Authorization':'Bearer $token'})
      ..body = body == null ? '' : jsonEncode(body);
    final streamed = await response.send();
    final text = await streamed.stream.bytesToString();
    final data = text.isEmpty ? null : jsonDecode(text);
    if (streamed.statusCode >= 400) throw Exception(data?['error'] ?? 'Error de conexión');
    return data;
  }
}

class LegalizacionesApp extends StatelessWidget {
  const LegalizacionesApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title:'Legalizaciones USCOM', theme:ThemeData(colorSchemeSeed:const Color(0xff0a4e9b), useMaterial3:true), home:const LoginPage());
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState()=>_LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final email=TextEditingController(), password=TextEditingController(); String? error; bool loading=false;
  Future<void> login() async { setState(()=>loading=true); try { final data=await Api.request('POST','/auth/login',{'email':email.text.trim(),'password':password.text}); Api.token=data['token']; if(mounted) Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const ProjectsPage())); } catch(e){setState(()=>error=e.toString().replaceFirst('Exception: ',''));} finally {if(mounted)setState(()=>loading=false);} }
  @override Widget build(BuildContext context)=>Scaffold(body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:420),child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.receipt_long,size:64,color:Color(0xff0a4e9b)),const SizedBox(height:16),const Text('Legalizaciones USCOM',style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Correo electrónico')),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Contraseña')),const SizedBox(height:16),FilledButton(onPressed:loading?null:login,child:Text(loading?'Ingresando...':'Ingresar')),if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Colors.red)))]))));
}

class ProjectsPage extends StatefulWidget { const ProjectsPage({super.key}); @override State<ProjectsPage> createState()=>_ProjectsPageState(); }
class _ProjectsPageState extends State<ProjectsPage> { List<dynamic> projects=[]; bool loading=true; String? error;
  @override void initState(){super.initState();load();}
  Future<void> load() async {try{final data=await Api.request('GET','/projects');if(mounted)setState(()=>projects=data as List<dynamic>);}catch(e){if(mounted)setState(()=>error=e.toString());}finally{if(mounted)setState(()=>loading=false);}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Mis legalizaciones'),actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh))]),floatingActionButton:FloatingActionButton.extended(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const NewProjectPage())).then((_)=>load()),icon:const Icon(Icons.add),label:const Text('Nuevo proyecto')),body:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Text(error!)):projects.isEmpty?const Center(child:Text('Aún no tienes legalizaciones.')):ListView(children:projects.map((p)=>Card(child:ListTile(title:Text(p['name']),subtitle:Text('${p['city']} · ${p['status']}'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ExpensesPage(project:p))).then((_)=>load()))).toList())); }
}

class NewProjectPage extends StatefulWidget { const NewProjectPage({super.key}); @override State<NewProjectPage> createState()=>_NewProjectPageState(); }
class _NewProjectPageState extends State<NewProjectPage>{final name=TextEditingController(),city=TextEditingController(),advance=TextEditingController();String base='COP',advanceCurrency='COP';String? error;
 Future<void> save()async{try{await Api.request('POST','/projects',{'name':name.text,'city':city.text,'baseCurrency':base,'advanceCurrency':advanceCurrency,'advanceAmount':advance.text});if(mounted)Navigator.pop(context);}catch(e){setState(()=>error=e.toString());}}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Nueva legalización')),body:Padding(padding:const EdgeInsets.all(18),child:ListView(children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Nombre del proyecto')),TextField(controller:city,decoration:const InputDecoration(labelText:'Ciudad')),DropdownButtonFormField(value:base,items:['COP','USD'].map((v)=>DropdownMenuItem(value:v,child:Text('Moneda base: $v'))).toList(),onChanged:(v)=>setState(()=>base=v!)),DropdownButtonFormField(value:advanceCurrency,items:['COP','USD'].map((v)=>DropdownMenuItem(value:v,child:Text('Moneda anticipo: $v'))).toList(),onChanged:(v)=>setState(()=>advanceCurrency=v!)),TextField(controller:advance,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Valor del anticipo')),const SizedBox(height:16),FilledButton(onPressed:save,child:const Text('Crear proyecto')),if(error!=null)Text(error!,style:const TextStyle(color:Colors.red))])));}

class ExpensesPage extends StatefulWidget { final dynamic project; const ExpensesPage({super.key,required this.project}); @override State<ExpensesPage> createState()=>_ExpensesPageState(); }
class _ExpensesPageState extends State<ExpensesPage>{List<dynamic> expenses=[];String? error;bool loading=true;final city=TextEditingController(),description=TextEditingController(),quantity=TextEditingController(text:'1'),unit=TextEditingController();String currency='COP';
 @override void initState(){super.initState();load();} Future<void> load()async{try{final d=await Api.request('GET','/projects/${widget.project['id']}/expenses');if(mounted)setState(()=>expenses=d as List<dynamic>);}catch(e){if(mounted)setState(()=>error=e.toString());}finally{if(mounted)setState(()=>loading=false);}}
 Future<void> add()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(content:const Text('¿QUIERE REGISTRAR ESTE GASTO?'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('NO')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('SÍ'))]));if(ok!=true)return;try{await Api.request('POST','/projects/${widget.project['id']}/expenses',{'city':city.text,'expenseDate':DateTime.now().toIso8601String(),'description':description.text,'quantity':quantity.text,'currency':currency,'unitValue':unit.text});description.clear();unit.clear();await load();}catch(e){setState(()=>error=e.toString());}}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(widget.project['name'])),body:Padding(padding:const EdgeInsets.all(16),child:ListView(children:[const Text('Registrar gasto',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),TextField(controller:city,decoration:const InputDecoration(labelText:'Ciudad')),TextField(controller:description,decoration:const InputDecoration(labelText:'Descripción')),TextField(controller:quantity,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Cantidad')),DropdownButtonFormField(value:currency,items:['COP','USD'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>currency=v!)),TextField(controller:unit,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Valor unitario')),FilledButton(onPressed:add,child:const Text('Registrar gasto')),if(error!=null)Text(error!,style:const TextStyle(color:Colors.red)),const Divider(),const Text('Gastos registrados',style:TextStyle(fontWeight:FontWeight.bold)),if(loading)const CircularProgressIndicator(),...expenses.map((e)=>ListTile(title:Text(e['description']),subtitle:Text('${e['city']} · ${e['currency']}'),trailing:Text('${e['totalValue']}')))])));}
