import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/screens/manga_page.dart';

class ItemCardManga extends StatelessWidget {
  final MangaModel manga;
  final DateTime nowDate;

  const ItemCardManga({
    super.key,
    required this.manga,
    required this.nowDate,
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
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              width: 0.5, color: Theme.of(context).colorScheme.onSecondary),
        ),
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            SizedBox(
              // Imagem
              height: 72,
              width: 72,
              child: _buildImage(manga.imgUrl),
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

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null) return const Placeholder();

    final file = File(imageUrl);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Placeholder();
        } else if (snapshot.hasData && snapshot.data == true) {
          return ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(file),
            ),
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
