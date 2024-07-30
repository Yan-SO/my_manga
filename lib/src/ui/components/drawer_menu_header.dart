import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DrawerMenuHeader extends StatelessWidget {
  const DrawerMenuHeader({
    super.key,
    required title,
    required WebViewController controller,
  })  : _controller = controller,
        _title = title;

  final WebViewController _controller;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (await _controller.canGoBack()) {
                    _controller.goBack();
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
                  _controller.reload();
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
          Text(_title),
        ],
      ),
    );
  }
}
