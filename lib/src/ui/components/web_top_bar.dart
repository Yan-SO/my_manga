import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTopBar extends StatefulWidget implements PreferredSizeWidget {
  const WebTopBar({super.key, required this.controller, required this.title});

  final WebViewController controller;
  final String title;

  @override
  State<WebTopBar> createState() => _WebTopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WebTopBarState extends State<WebTopBar> {
  final ValueNotifier<int> _progressNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    widget.controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          _progressNotifier.value = progress;
        },
      ),
    );
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
              widget.title,
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
