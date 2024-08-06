// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/fonts_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';
import 'package:my_mangas/src/ui/screens/fonts_web_page.dart';

class FontsPage extends StatefulWidget {
  FontsPage({super.key});

  @override
  State<FontsPage> createState() => _FontsPageState();
}

class _FontsPageState extends State<FontsPage> {
  late Future<List<FontsModel>> _fontesFuture;
  final MangaRepository _repository = MangaRepository();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameFontController = TextEditingController();

  List<FontsModel> _list = [];

  File? _image;

  @override
  void initState() {
    super.initState();
    _loadFonts();
  }

  @override
  void dispose() {
    _nameFontController.dispose();
    super.dispose();
  }

  void _setImage(File img) {
    _image = img;
  }

  Future<void> _loadFonts() async {
    _fontesFuture = _repository.getAllFonts();
    _fontesFuture.then((resp) {
      setState(() {
        _list = resp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(' Fontes '),
      ),
      body: FutureBuilder(
        future: _fontesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                SizedBox(height: 8),
                _addFonts(context),
                SizedBox(height: 30),
                _fontsTitle(),
                SizedBox(height: 15),
                _listFonts(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _listFonts() {
    if (_list.isEmpty) return Text('Sem fontes adiciondas');

    return Expanded(
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  //sub ttitulo com os filhos
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FontsWebPage(
                          font: _list[index],
                        ),
                      ),
                    );
                  },
                  subtitle: Text('mangas: ${_list[index].children}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outlined),
                    onPressed: () {
                      if (_list[index].id != null) {
                        _repository.deletefonts(_list[index].id!).then((_) {
                          _loadFonts();
                        });
                      } else {
                        AlertDialog(
                          title:
                              Text('o ${_list[index].fontName} não tem um id'),
                        );
                      }
                    },
                  ),
                  leading: _list[index].imgUrl != null
                      ? CircleAvatar(
                          backgroundImage:
                              FileImage(File(_list[index].imgUrl!)))
                      : CircleAvatar(
                          backgroundColor: Colors.black,
                        ),
                  title: Text(_list[index].fontName),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Text _fontsTitle() {
    return Text(
      ".   . . . . . . Fontes . . . . . .   .",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.double,
      ),
    );
  }

  Widget _addFonts(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Color.fromARGB(186, 0, 0, 0),
      child: Row(
        children: [
          SizedBox(width: 8),
          PikerImage(
            onImagePicked: _setImage,
            height: 150,
            width: 150,
            fontSize: 22,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: "Nome da fonte"),
                    controller: _nameFontController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o título';
                      }
                      if (_image == null) {
                        return 'escolha uma imagem';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // testar ↓↓↓
                        _repository.insertFont(FontsModel(
                          imgUrl: _image?.path,
                          fontName: _nameFontController.text,
                          children: 0,
                        ));
                        _loadFonts();
                      }
                    },
                    child: Text(
                      'Adicionar',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
    );
  }
}
