import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/screens/manga_page.dart';

class ItemCard extends StatelessWidget {
  final MangaModel manga;
  final DateTime nowDate;
  final VoidCallback findMangas;

  const ItemCard({
    super.key,
    required this.manga,
    required this.nowDate,
    required this.findMangas,
  });

  @override
  Widget build(BuildContext context) {
    final toRead = manga.totalChapters - manga.chaptersRead;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MangaPage(mangaId: manga.id!, nowDate: nowDate),
          ),
        );
        findMangas();
      },
      child: Card(
        color: Theme.of(context).colorScheme.tertiary,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            SizedBox(
              // Imagem
              height: 72,
              width: 72,
              child: manga.imgUrl == null
                  ? const Placeholder()
                  : ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.file(File(manga.imgUrl!)),
                      ),
                    ),
            ), // Imagem
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    manga.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tempo sem ler: ${nowDate.difference(manga.lastRead).inDays} dias',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (toRead > 0)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Theme.of(context).colorScheme.onPrimary,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '$toRead',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
