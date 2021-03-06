import 'package:flutter/material.dart';
import 'package:share/share.dart';

// TODO 10: Criando uma nova pagina para entrar dentro do gif escolhido

class GifPage extends StatelessWidget {
  //TODO 10.1: Criar map
  final Map _gifData;
  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_gifData['title']),
        backgroundColor: Colors.black,
        // TODO 11: Compartilhando Gifs, criar action
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(_gifData['images']['fixed_height']['url']);
              })
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData['images']['fixed_height']['url']),
      ),
    );
  }
}
