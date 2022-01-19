import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Mensagens.dart';
import 'package:whatsapp/model/Pessoa.dart';

class AbaContatos extends StatefulWidget {
  const AbaContatos({Key? key}) : super(key: key);

  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  List<Pessoa> pessoas = [];

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

    firestore.collection("users").snapshots().listen((event) {
      List<Pessoa> pessoas_local = [];
      for (DocumentSnapshot doc in event.docs) {
        String uid = doc.id;
        String nome = "";
        if (uid == mAuth.currentUser!.uid) {
          nome = "${doc.get("nome")}   ( você )";
        } else {
          nome = doc.get("nome");
        }

        Pessoa pessoa = Pessoa(
            nome: nome,
            email: doc.get("email"),
            profile_picture: doc.get("profile_picture"),
            id: doc.id
        );
        pessoas_local.add(pessoa);
      }
      setState(() {
        pessoas = pessoas_local;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: pessoas.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(4),
            child: GestureDetector(
              onTap: (){
                if(pessoas[index].email != mAuth.currentUser!.email){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  Mensagens(pessoa: pessoas[index]),));
                }
              },
              child: Card(
                child: ListTile(
                  leading: GestureDetector(
                    child: CircleAvatar(
                      backgroundImage:
                      NetworkImage(pessoas[index].profile_picture),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(pessoas[index].nome),
                            content: Image.network(
                              pessoas[index].profile_picture,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  title: Text(pessoas[index].nome),
                  subtitle: Text(pessoas[index].email),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
