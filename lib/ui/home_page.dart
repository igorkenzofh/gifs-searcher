import 'dart:convert';
import 'package:share/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

var url_trending =
    ('https://api.giphy.com/v1/gifs/trending?api_key=7yB8Xc3SCD3you79GwCsz8wro6ZPOVfG&limit=25&rating=g');

// TODO 2: Importar packages e criar HomePage como um stful

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  //TODO 3: Criar função async para pegar os gifs. Criar variavel chamada _search e _offset=0
  Future _getGifs() async {
    // Dois tipos de buscas, o search e os trendings
    http.Response response;

    // TODO 4: Criar método para diferenciar se search ou trending
    if (_search == null || _search.isEmpty) {
      response = await http.get(url_trending);
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=7yB8Xc3SCD3you79GwCsz8wro6ZPOVfG&q=$_search&limit=19&offset=$_offset&rating=g&lang=en');
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    // TODO 5: Criar layout
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              // TODO 7: Vincular barra de pesquisa com busca
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  // TODO 9.5: Resetar o offset quando for pesquisar de novo
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            // TODO 5.1: Criar FutureBuilder que vai construir depois que pegar os dados da api
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          ),
        ],
      ),
    );
  }

  // TODO 9: Criando botão de carregar mais gifs
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1; // retornar o ultimo slot da grid vazio
    }
  }

  // TODO 6: Criar Grid de gifs pegando dados da API
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        // TODO 9.1: Substituir itemCount por
        // itemCount: snapshot.data['data'].length,
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          // TODO 9.2: Função para se nao estiver pesquisando retornar trending gifs
          if (_search == null ||
              index <
                  snapshot.data['data']
                      .length) // Ou se o item nao for o último intem
            return GestureDetector(
              // TODO 10.2: Adicionando função para ir pra  pg gif_page
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data['data'][index])));
              },
              // TODO 11.1: Compartilhar gif pressionando
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              },
              child:
                  // TODO 12: Fazendo as imagens aparecerem suavemente retirando image.network e add fadein
                  // Image.network(
                  //     snapshot.data['data'][index]['images']['fixed_height']['url'],
                  //     height: 300,
                  //     fit: BoxFit.cover),
                  // TODO 12.1: Importar package transparent image
                  FadeInImage.memoryNetwork(
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: kTransparentImage,
                      image: snapshot.data['data'][index]['images']
                          ['fixed_height']['url']),
            );
          // TODO 9.3: Caso contrário retornar o ultimo slot com Carregar mais
          else
            return Container(
              child: GestureDetector(
                // TODO 9.4: Função onTap para pegar o offset e carregar os próximos 19
                onTap: () {
                  setState(() {
                    // o setstate obriga a recarregar o FutureBuilder
                    _offset += (19);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_outlined,
                        color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Carregar mais...',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              ),
            );
        });
  }
}

// TODO 8 : Recapitulando Pesquisa de gifs
//  Assim que submeter um texto na barra, ele vai atribuir à 'text' no TextField em onsubmitted.
//  Esse 'text' é o input que vai ser atribuido a _search na função getGifs e vai dar um setState
// O setstate vai mandar reconstruir o FutureBuilder. O futurbuilder vai pegar o futuro getGifs
// O getGifs vai analisar se _search == null ou não. Ele vai pegar e atribuir o text atribuido a _search ao 'q'
// Isso vai retornar um Map com q=_search, e aí o FutureBuilder vai construir a Grid com a URL de pesquisa
