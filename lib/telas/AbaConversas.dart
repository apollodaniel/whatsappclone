
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Message.dart';
import 'package:whatsapp/model/Pessoa.dart';

import '../Helper.dart';
import '../Mensagens.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> conversas = [];

  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  late ListView listView;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;


    firestore.collection("mensagens").snapshots().listen((event) {
      _getMensagens();
    });

  }

  _getMensagens() async {

    QuerySnapshot snapshot = await firestore.collection("mensagens").get();

    List<dynamic> messages = [];
    for(DocumentSnapshot doc in snapshot.docs){
      if(doc.id.contains(mAuth.currentUser!.uid)){
        messages.add(doc.data());
      }
    }


    List<Conversa> conversasLocal = [];

    for(var message in messages){

      message["users"].remove(mAuth.currentUser!.uid);

      var message_ = {};

      print(message["users"][0]);
      QuerySnapshot querySnapshot = await firestore.collection("users").get();
      for(DocumentSnapshot doc in querySnapshot.docs){
        if(doc.id == message["users"][0]){
          message_["email"] = doc.get("email");
          message_["nome"] = doc.get("nome");
          message_["profile_picture"] = doc.get("profile_picture");
          message_["id"] = message["users"][0];
        }
      }

      List<Message> mensagens = [];
      for(var mensagem in message["messages"]){

        Message _mensagem = Message(content: mensagem["content"], date: mensagem["date"], sender: mensagem["sender"]);
        mensagens.add(_mensagem);

      }

      print(message_.toString());
      conversasLocal.add(Conversa(email: message_["email"], id: message_["id"], profile_picture: message_["profile_picture"], name: message_["nome"], messages: mensagens));

    }

    setState(() {
      conversas = conversasLocal;
    });

  }



  @override
  Widget build(BuildContext context) {
    conversas.sort((a, b) => DateTime.parse(b.messages.last.date).compareTo(DateTime.parse(a.messages.last.date)));


    return ListView.builder(
      itemCount: conversas.length,
      itemBuilder: (context, index) {
        try {



          String message_content_raw = conversas[index].messages.last.content;
          String message_content = isImage(message_content_raw)
              ? "Sent a image"
              : message_content_raw;
          String profile_picture = conversas[index].profile_picture;
          String name = conversas[index].name;
          message_content =
              mAuth.currentUser!.uid == conversas[index].messages.last.sender
                  ? "Voc??: $message_content"
                  : "$name: $message_content";
          String date = conversas[index].messages.last.date;
          DateTime date_parsed = DateTime.parse(date);
          String formated_date = "";
          if (date_parsed.difference(DateTime.now()).inDays != 0 &&
              date_parsed.isBefore(DateTime.now())) {
            formated_date = DateFormat("dd/MM/yyyy").format(date_parsed);
          } else {
            formated_date = DateFormat("HH:mm").format(date_parsed);
          }

          return GestureDetector(
            child: Card(
              child: ListTile(
                leading: GestureDetector(
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(conversas[index].profile_picture),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(name),
                          content: Image.network(
                            profile_picture,
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
                title: Text(conversas[index].name),
                subtitle: Text(
                  "${formated_date} - ${message_content}",
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Mensagens(
                        pessoa: Pessoa(
                            nome: conversas[index].name,
                            email: conversas[index].email,
                            profile_picture: conversas[index].profile_picture,
                            id: conversas[index].id)),
                  ));
            },
          );
        } catch (_) {
          return Container();
        }
      },
    );
  }

  isImage(String message_raw) {
    if (Helper.isValidLink(message_raw) &&
        Helper.isImage(message_raw.split("/").last)) {
      return true;
    }
    return false;
  }
}
