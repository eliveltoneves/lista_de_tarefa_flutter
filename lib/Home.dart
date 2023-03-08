import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];
  Map<String, dynamic> _ultimoTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {

    final diretorio = await getApplicationSupportDirectory();
    return File("${diretorio.path}/dados.json");

  }

  _salvarTarefa(){

    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["status"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    
    _salvarArquivo();
    _controllerTarefa.text = "";

  }
  
  _salvarArquivo() async {

    var arquivo = await _getFile();   

    String dados = jsonEncode(_listaTarefas);
    arquivo.writeAsString(dados);

  }

  _lerArquivo() async {

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _lerArquivo().then((dados){
      setState(() {
        _listaTarefas = jsonDecode(dados);
      });
    });

  }

  Widget criarItemLista(context, index){

    //final item = _listaTarefas[index]["titulo"];


    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {

          //recuperar o ultimo item excluido
          _ultimoTarefaRemovida = _listaTarefas[index];
          //Remover item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          final snackbar = SnackBar(
            backgroundColor: Colors.deepPurple,
            duration: Duration(seconds: 5),
            content: Text("Tarefa removida!!"),
            action: SnackBarAction(
              textColor: Colors.white,
              label: "Desfazer",
              onPressed: () {

                setState(() {
                  _listaTarefas.insert(index, _ultimoTarefaRemovida);
                });
                _salvarArquivo();
                
              }, 
            ),
            //duration: ,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.purpleAccent,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ignore: prefer_const_constructors
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
                  title: Text(_listaTarefas[index]['titulo']),
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  //secondary: const Icon(Icons.admin_panel_settings),
                  value: _listaTarefas[index]['status'],
                   onChanged: (valorAlterado) {
                      setState(() {
                        _listaTarefas[index]['status'] = valorAlterado;
                      });
                     
                     _salvarArquivo();

                   }
                )
    );

  }

  @override
  Widget build(BuildContext context) {

    _salvarArquivo();
    //print("itens: " + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purpleAccent,
        onPressed: (){
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: InputDecoration(
                    labelText: "Digite sua tarefa"
                  ),
                  onChanged: (text){

                  },
                ),
                actions: [
                  TextButton(
                  onPressed: () => Navigator.pop(context),
                   child: Text("Cancelar")
                   ),
                  TextButton(
                  onPressed: (){
                    _salvarTarefa();
                    Navigator.pop(context);
                  },
                   child: Text("Salvar")
                   )
                ],
              );
            }
          );
        },
        ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Expanded(
            
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista
              ) 
            ),
        ],
      )
    );
  }
}