// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/home_menu.dart';
import 'package:my_mangas/src/ui/components/item_card.dart';
import 'package:my_mangas/src/ui/screens/manipulation_page.dart';

class MangaListPage extends StatefulWidget {
  MangaListPage({super.key});

  @override
  State<MangaListPage> createState() => _MangaListPageState();
}

class _MangaListPageState extends State<MangaListPage> {
  late Future<List<MangaModel>> _mangasFuture;

  final MangaRepository _mangaRepository = MangaRepository();
  final TextEditingController _searchController = TextEditingController();
  List<MangaModel> _filteredMangas = [];
  List<MangaModel> _allMangasList = [];

  @override
  void initState() {
    super.initState();
    _findMangas();
    _searchController.addListener(() {
      _filterMangas(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      _filterMangas(_searchController.text);
    });
    _searchController.dispose();
    super.dispose();
  }

  void _sortMangasByDate(List<MangaModel> mangas) {
    mangas.sort((a, b) => b.lastRead.compareTo(a.lastRead));
  }

  void _findMangas() {
    _mangasFuture = _mangaRepository.getAllMangas();
    _mangasFuture.then((mangas) {
      setState(() {
        _allMangasList = mangas;
        _filteredMangas = _allMangasList;
        _sortMangasByDate(_filteredMangas);
      });
    });
  }

  void _filterMangas(String filter) {
    setState(() {
      if (filter.isNotEmpty) {
        _filteredMangas = _allMangasList.where((manga) {
          return manga.title.toLowerCase().contains(filter.toLowerCase());
        }).toList();
      } else {
        _filteredMangas = _allMangasList;
      }
      _sortMangasByDate(_filteredMangas);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime nowDate = DateTime.now();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManipulationPage(dateNow: nowDate),
            ),
          );
          _findMangas();
        },
        child: const Icon(Icons.add),
      ),
      drawer: HomeMenu(context: context),
      appBar: _appBar(context),
      body: _futureBuilder(nowDate),
    );
  }

  FutureBuilder<List<MangaModel>> _futureBuilder(DateTime nowDate) {
    return FutureBuilder<List<MangaModel>>(
      future: _mangasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Adicione um novo manga!'));
        } else {
          return ListView.builder(
            itemCount: _filteredMangas.length,
            itemBuilder: (context, index) {
              return ItemCardManga(
                manga: _filteredMangas[index],
                nowDate: nowDate,
                findMangas: _findMangas,
              );
            },
          );
        }
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
