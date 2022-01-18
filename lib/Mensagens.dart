import 'package:flutter/material.dart';

import 'model/Pessoa.dart';

class Mensagens extends StatefulWidget {
  Pessoa pessoa;

  Mensagens({required this.pessoa});

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _mensagensController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.pessoa.nome),
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
                      Text("Mensagens"),
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
                              onPressed: () {},
                            )
                          ],
                        ),
                      ),
                    ]),
              ),
            )));
  }
}
