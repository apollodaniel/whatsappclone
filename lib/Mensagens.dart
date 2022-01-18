import 'package:flutter/material.dart';

import 'model/Pessoa.dart';

class Mensagens extends StatefulWidget {

  Pessoa pessoa;

  Mensagens({required this.pessoa});

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pessoa.nome),
      ),
    );
  }
}
