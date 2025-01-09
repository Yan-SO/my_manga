import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTopNavigationBar extends StatefulWidget
    implements PreferredSizeWidget {
  const WebTopNavigationBar({
    super.key,
    required this.controller,
  });

  final WebViewController controller;

  @override
  State<WebTopNavigationBar> createState() => _WebTopNavigationBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WebTopNavigationBarState extends State<WebTopNavigationBar> {
  final ValueNotifier<int> _progressNotifier = ValueNotifier<int>(0);
  final MangaRepository _repository = MangaRepository();
  String _title = "Loading...";

  @override
  void initState() {
    super.initState();
    widget.controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          _progressNotifier.value = progress;
        },
        onNavigationRequest: (request) async {
          if (await _repository.getSetting('showNavigationQuest') == 'true') {
            if (!await _isSameSite(currentUrl: _title, nextUrl: request.url)) {
              print("Tentativa bloqueada: ${request.url}");
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          _updateTitle();
        },
        onPageFinished: (url) {
          _updateTitle();
        },
      ),
    );
    _updateTitle();
  }

  Future<bool> _isSameSite(
      {required String? currentUrl, required String? nextUrl}) async {
    final currentUri = Uri.tryParse(currentUrl ?? "");
    final nextUri = Uri.tryParse(nextUrl ?? "");
    if (currentUri?.host == nextUri?.host) {
      return true;
    }
    final resp = await showCustomAlert(
      context,
      title: "Mudar de site?",
      message:
          "Tem certeza de que deseja ir para o site ${nextUri?.host ?? "este site, que não possui um host"}?",
      showConfirm: true,
    );
    return resp ?? false;
  }

  Future<void> _updateTitle() async {
    final url = await widget.controller.currentUrl();
    setState(() {
      _title = url ?? "No URL";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              _title,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (await widget.controller.canGoBack()) {
                widget.controller.goBack();
              }
            },
            child: const Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              widget.controller.reload();
            },
            child: const Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.loop_outlined),
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: ValueListenableBuilder<int>(
          valueListenable: _progressNotifier,
          builder: (context, progress, child) {
            return progress < 100
                ? LinearProgressIndicator(
                    value: progress / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[200],
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressNotifier.dispose();
    super.dispose();
  }
}
