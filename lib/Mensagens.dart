import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Helper.dart';
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

  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  var message_widget;
  List<Message> messages = [];

  String id_chat = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    getMessage();
  }

  getMessage() async {
    firestore.collection("mensagens").snapshots().listen((querySnapshot) {
      for (DocumentSnapshot doc in querySnapshot.docs) {
        if (doc.get("users").contains(mAuth.currentUser!.uid) &&
            doc.get("users").contains(widget.pessoa.id)) {
          dynamic data = doc.data();

          id_chat = doc.id;
          List<Message> messages_local = [];

          for (var value in data["messages"]) {
            Message message_temp = Message(
                content: value["content"],
                date: value["date"],
                sender: value["sender"]);
            messages_local.add(message_temp);
          }

          setState(() {
            messages = messages_local;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    messages.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

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
                        Expanded(
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                              Alignment alignment = Alignment.centerRight;
                              Color cor = Colors.green;
                              double larguraContainer =
                                  MediaQuery.of(context).size.width * 80 / 100;

                              if (messages[index].sender == widget.pessoa.id) {
                                alignment = Alignment.centerLeft;
                                cor = ThemeData.dark().primaryColor;
                              }

                              Widget message = Text(messages[index].content);

                              String content = messages[index].content;
                              if(Helper.isValidLink(content) && Helper.isImage(content.split("/").last)){
                                message = Column(
                                  children: [
                                    Image.network(content),
                                    Text(content.split("/").last)
                                  ],
                                );
                              }

                              return Align(
                                alignment: alignment,
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Container(
                                    width: larguraContainer,
                                    decoration: BoxDecoration(
                                        color: cor,
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(8))),
                                    padding: EdgeInsets.all(16),
                                    child: message,
                                  ),
                                ),
                              );
                          },
                        )),
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
                                        fillColor:
                                            ThemeData.dark().primaryColor,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(32, 8, 32, 8),
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
                                onPressed: _salvarMensagem,
                              )
                            ],
                          ),
                        ),
                      ])),
            )));
  }

  _salvarMensagem() async {
    String mensagem = _mensagensController.text;

    String _chatId = id_chat;

    if (id_chat.isEmpty) {
      _chatId = widget.pessoa.id + "||" + mAuth.currentUser!.uid;
    }

    if (mensagem.isNotEmpty) {
      Message message = Message(
          content: mensagem,
          date: DateTime.now().toString(),
          sender: mAuth.currentUser!.uid);

      DocumentSnapshot snapshot =
          await firestore.collection("mensagens").doc(_chatId).get();

      dynamic data = snapshot.data();

      if (data == null) {
        data = <String, dynamic>{};
        data["users"] = [
          widget.pessoa.id,
          mAuth.currentUser!.uid,
        ];
        data["messages"] = [message.toMap()];
        snapshot.reference.set(data);
      } else {
        if (!data.containsKey("messages")) {
          data["messages"] = [message.toMap()];
        } else {
          data["messages"].add(message.toMap());
        }

        data["users"] = [widget.pessoa.id, mAuth.currentUser!.uid];
        snapshot.reference.update(data);
      }
      _mensagensController.clear();
    }
  }
}
