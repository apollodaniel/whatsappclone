import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Message.dart';

import 'model/Pessoa.dart';

class Mensagens extends StatefulWidget {
  Pessoa pessoa;

  Mensagens({required this.pessoa});

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _mensagensController = TextEditingController();

  List<Message> _mensagens = [];


  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;


  }

  _recuperaMensagens()async{

  }

  @override
  Widget build(BuildContext context) {
    _recuperaMensagens();



    StreamBuilder streamBuilder = StreamBuilder(
      stream: firestore.collection("mensagens").doc(mAuth.currentUser!.uid).collection(widget.pessoa.id).snapshots(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if(snapshot.hasError){
              return Center(
                child: Text("Um erro ocorreu"),
              );
            }else{
              QuerySnapshot querySnapshot = snapshot.data;

              List<Message> messages = querySnapshot.docs.map(
                      (e) {
                        return Message(content: e.get("content"), date: e.get("date"), sender: e.get("sender"));
              }).toList();

              return Expanded(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {

                      Alignment alignment = Alignment.centerRight;
                      Color cor = Colors.green;
                      double larguraContainer = MediaQuery.of(context).size.width *  80 / 100;

                      if(messages[index].sender == widget.pessoa.id){
                        alignment = Alignment.centerLeft;
                        cor = ThemeData.dark().primaryColor;
                      }


                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(messages[index].content),
                          ),
                        ),
                      );
                    },
                  )
              );
            }
            break;
        }
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.pessoa.profile_picture),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(widget.pessoa.nome),
              )
            ],
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/bg.jpg"),
                    opacity: 0.8,
                    fit: BoxFit.cover)),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      streamBuilder,
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: TextField(
                                  controller: _mensagensController,
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 20),
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: ThemeData.dark().primaryColor,
                                      contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                                      hintText: "Digite uma mensagem...",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(32)),
                                      prefixIcon: IconButton(
                                          icon: Icon(Icons.camera_alt),
                                          onPressed: () {})),
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: Color(0xff075E54),
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                              mini: true,
                              onPressed: () => _salvarMensagem(),
                            )
                          ],
                        ),
                      ),
                    ])
              ),
            )));
  }

  _salvarMensagem()async{

    String mensagem = _mensagensController.text;

    User user = mAuth.currentUser!;
    if(mensagem.isNotEmpty)
    {
      Message message = Message(content: mensagem, date: DateTime.now().toString(), sender: mAuth.currentUser!.uid);
      await firestore
          .collection("mensagens")
          .doc(user.uid)
          .collection(widget.pessoa.id)
          .add(message.toMap());
      _mensagensController.clear();
    }
  }

}
