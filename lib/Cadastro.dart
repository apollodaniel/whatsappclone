import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String? nome_error;
  String? email_error;
  String? password_error;

  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;

  AppBar appBar = AppBar(
    title: Text("Cadastro"),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height - appBar.preferredSize.height - MediaQuery.of(context).padding.top,
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/usuario.png",
                      width: 80,
                      height: 80,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 32),
                      child: TextField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                              hintText: "Nome",
                              errorText: nome_error,
                              contentPadding:
                              EdgeInsets.fromLTRB(32, 16, 32, 16),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32)))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              hintText: "Email",
                              errorText: email_error,
                              contentPadding:
                              EdgeInsets.fromLTRB(32, 16, 32, 16),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32)))),
                    ),
                    TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            errorText: password_error,
                            hintText: "Senha",
                            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32)))),
                    Padding(
                      padding: EdgeInsets.only(top: 32, bottom: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool canRegister = validarCampos();
                          if (canRegister) {
                            await mAuth.createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text
                            ).whenComplete(() {
                              mAuth.currentUser
                                  ?.updateDisplayName(_nomeController.text);
                              firestore
                                  .collection("users")
                                  .doc(mAuth.currentUser?.uid)
                                  .set(
                                  {
                                    "nome": _nomeController.text,
                                    "email": _emailController.text,
                                    "profile_picture":"https://firebasestorage.googleapis.com/v0/b/whatsapp-30d59.appspot.com/o/blank-profile-picture-973460.png?alt=media&token=2f58af8f-18e2-49d2-b573-240a4f2ca132"
                                  }
                              );
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Registrado com sucesso!"))
                              );
                              Map<String, dynamic> result = {
                                "email":_emailController.text,
                                "senha":_passwordController.text
                              };
                              Navigator.pop(context, result);
                            });
                          }
                        },
                        child: Text(
                          "Cadastrar",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                            padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                      ),
                    ),

                  ],
                ),
             )
          ),
        ),
      );
  }

  validarCampos() {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    bool nomeBool = validarNome(nome);
    bool emailBool = validarEmail(email);
    bool passwordBool = validarSenha(password);

    if (nomeBool && emailBool & passwordBool) {
      return true;
    } else {
      return false;
    }
  }

  validarNome(String nome) {
    if (nome.isEmpty) {
      setState(() {
        nome_error = "Não pode estar vázio";
      });
    } else if (nome.split(" ").length == 1) {
      setState(() {
        nome_error = "Digite seu nome completo";
      });
    } else {
      setState(() {
        nome_error = null;
      });
      return true;
    }
    return false;
  }

  validarEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        email_error = "Não pode estar vázio";
      });
    } else if (!email.contains("@") ||
        email.split("@")[1].isEmpty ||
        !email.split("@")[1].contains(".")) {
      setState(() {
        email_error = "Email não válido";
      });
    } else {
      setState(() {
        email_error = null;
      });
      return true;
    }
    return false;
  }

  validarSenha(String senha) {
    if (senha.isEmpty) {
      setState(() {
        password_error = "Não pode estar vázio";
      });
    } else if (senha.length < 4) {
      setState(() {
        password_error = "Senha muito curta";
      });
    } else {
      setState(() {
        password_error = null;
      });
      return true;
    }
    return false;
  }
}
