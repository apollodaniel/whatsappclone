import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Pessoa.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  File? image;

  Pessoa pessoa =
      Pessoa(nome: "Guest", email: "johndoe@gmail.com", profile_picture: "");

  TextEditingController _nomeController = TextEditingController();

  String? nomeError;

  AppBar appBar = AppBar(
    title: Text("Configurações"),
  );

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
      for (DocumentSnapshot doc in event.docs) {
        if (doc.id == mAuth.currentUser!.uid) {
          setState(() {
            pessoa = Pessoa(
                nome: doc.get("nome"),
                email: doc.get("email"),
                profile_picture: doc.get("profile_picture"));
            _nomeController.text = pessoa.nome;
          });
        }
      }
    });
    setState(() {
      _nomeController.text = pessoa.nome;
    });
  }

  pickImage(bool fromCamera) async {
    print("a");
    var picker = ImagePicker.platform;

    XFile? file;

    if(fromCamera){
      file = await picker.getImage(source: ImageSource.camera);

    }else{
      file = await picker.getImage(source: ImageSource.gallery);
    }
    if (file != null) {
      File _file = File(file.path);
      setState(() {
        image = _file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var image_;
    if(image == null){
      image_ = NetworkImage(pessoa.profile_picture);
    }else{
      image_ = FileImage(image!);
    }
    var imageWidget_ = image == null ? Image.network(pessoa.profile_picture) : Image.file(image!);
    
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height -
                appBar.preferredSize.height -
                MediaQuery.of(context).padding.top,
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: image_,
                    maxRadius: 80,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: imageWidget_,
                          actions: [
                            ElevatedButton(
                                onPressed: () async {
                                  await pickImage(false);
                                  Navigator.pop(context);
                                },
                                child: Text("Galeria")),
                            ElevatedButton(
                                onPressed: () async {
                                  await pickImage(true);
                                  Navigator.pop(context);

                                },
                                child: Text("Câmera"))
                          ],
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, top: 32),
                  child: TextField(
                      controller: _nomeController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: "Nome",
                          errorText: nomeError,
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)))),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String nome = _nomeController.text;
                      bool isValidName = validarNome(nome);
                      if (isValidName) {
                        bool sucess = true;
                        if(image != null){
                          Reference ref = storage.ref("profiles").child("${mAuth.currentUser!.uid}.${image!.path.split(".").last}");
                          await ref.putFile(image!).catchError((_){
                            sucess = false;
                          });
                          pessoa.profile_picture = await ref.getDownloadURL();
                        }
                        await mAuth.currentUser!.updateDisplayName(nome);
                        firestore
                            .collection("users")
                            .doc(mAuth.currentUser!.uid)
                            .set({
                          "nome": nome,
                          "email": pessoa.email,
                          "profile_picture": pessoa.profile_picture
                        }).catchError((_){
                          sucess = false;
                        });
                        if(sucess){
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Atualizado com sucesso!")));
                        }else{
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Houve um erro ao salvar!")));
                        }
                      }
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  validarNome(String nome) {
    if (nome.isEmpty) {
      setState(() {
        nomeError = "Não pode estar vázio";
      });
    } else if (nome.split(" ").length == 1) {
      setState(() {
        nomeError = "Digite seu nome completo";
      });
    } else {
      setState(() {
        nomeError = null;
      });
      return true;
    }
    return false;
  }
}
