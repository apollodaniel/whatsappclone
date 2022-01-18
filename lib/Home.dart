import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbaConversas.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  late TabController _controller;

  List<String> actions = ["Configurações", "Logout"];

  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    _controller = TabController(length: 2, vsync: this);
  }

  onSelectedAction(String item){

    if(item == actions[0]){
      //configuracoes

    }else if(item == actions[1]){
      //logout
      _deslogarUsuario();
    }

  }

  _deslogarUsuario() async{
    await mAuth.signOut();
    Navigator.pushReplacementNamed(
        context,
        "/login"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: onSelectedAction,
            itemBuilder: (context) {
              return actions.map(
                (item) {
                  return PopupMenuItem<String>(child: Text(item),value: item);
                }
              ).toList();
            },
          )
        ],
        title: Text("Whatsapp"),
        bottom: TabBar(
          controller: _controller,
          indicatorColor: Colors.greenAccent,
          tabs: [
            Tab(
              text: "Conversas",
            ),
            Tab(
              text: "Contatos",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          AbaConversas(),
          AbaContatos(),
        ],
      ),
    );
  }
}
