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


    getConversas();

  }
  getConversas() async{

    List<DocumentSnapshot> docs = [];
    QuerySnapshot snapshot = await
    firestore
        .collection("mensagens").get();

    for(DocumentSnapshot doc in snapshot.docs) {
      print("1");
      if (doc.get("users").contains(mAuth.currentUser!.uid)) {
        QuerySnapshot snapshot_users = await firestore.collection("users").get();


        for(DocumentSnapshot doc_ in snapshot_users.docs){
          if(doc.id.split("||").contains(doc_.id)){
            doc.reference.collection("mensagens").snapshots().listen((event) {

              setState(() {
                conversas.clear();
              });

              List<Message> mensagens = event.docs.map(
                      (event) {
                    return Message(content: event.get("content"),
                        date: event.get("date"),
                        sender: event.get("sender"));
                  }
              ).toList();

              if(doc_.id != mAuth.currentUser!.uid){
                Conversa conversa = Conversa(email: doc_.get("email"),id: doc_.id,profile_picture: doc_.get("profile_picture"), name: doc_.get("nome"), messages: mensagens);
                setState(() {
                  conversas.add(conversa);
                });
              }
            });
          }
        }
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversas.length,
      itemBuilder: (context, index) {
        String date = conversas[index].messages.last.date;
        DateTime date_parsed = DateTime.parse(date);
        String formated_date = "";

        String message_content_raw = conversas[index].messages.last.content;
        String message_content =  isImage(message_content_raw) ? "Sent a image" : message_content_raw;
        String profile_picture = conversas[index].profile_picture;
        String name = conversas[index].name;
        message_content = mAuth.currentUser!.uid == conversas[index].messages.last.sender ? "Você: $message_content" : "$name: $message_content";

        if(date_parsed.difference(DateTime.now()).inDays != 0 && date_parsed.isBefore(DateTime.now())){
          formated_date =  DateFormat("dd/MM/yyyy").format(date_parsed);
        }else{
          formated_date = DateFormat("HH:mm").format(date_parsed);
        }




        return GestureDetector(
          child: Card(
            child: ListTile(
              leading: GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(conversas[index].profile_picture),
                ),
                onTap: (){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text(name),
                      content: Image.network(profile_picture,height: 180, width: 180, fit: BoxFit.cover,),

                    );
                  },);
                },
              ),
              title: Text(conversas[index].name),
              subtitle: Text(
                "${formated_date} - ${message_content}",
              ),
            ),
          ),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  Mensagens(pessoa: Pessoa(nome: conversas[index].name, email: conversas[index].email, profile_picture: conversas[index].profile_picture, id: conversas[index].id)),));
          },
        );
      },
    );
  }

  isImage(String message_raw){
    if(Helper.isValidLink(message_raw) && Helper.isImage(message_raw.split("/").last)){
      return true;
    }
    return false;
  }

}
