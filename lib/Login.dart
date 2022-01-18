import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';

import 'Home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late FirebaseAuth mAuth;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;

    if(mAuth.currentUser != null){
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
        child:Padding(
        padding: EdgeInsets.all(32),
    child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/logo.png",
                width: 200,
                height: 150,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8, top: 32),
                child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "Email",
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)))),
              ),
              TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      hintText: "Senha",
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)))),
              Padding(
                padding: EdgeInsets.only(top: 32, bottom: 16),
                child: ElevatedButton(
                  onPressed: () => login(),
                  child: Text(
                    "Logar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                ),
              ),
              Center(
                child: GestureDetector(
                  child: Text(
                    "Não cadastrado ainda? Clique aqui",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Cadastro()
                    ));
                  },
                ),
              )
            ],
          ),
        ) ,
        ),
      )
    );
  }

  login(){
    print("login");
    String email = _emailController.text;
    String password = _passwordController.text;

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email ou senha não podem estar vázios!")));
    }else{
      bool sucess = true;
      mAuth.signInWithEmailAndPassword(email: email, password: password).catchError((error){
        sucess = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      });
      if(sucess){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }
    }
  }

}
