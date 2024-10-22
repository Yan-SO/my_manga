import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebDrawerMenuHeader extends StatelessWidget {
  const WebDrawerMenuHeader({
    super.key,
    required title,
    required WebViewController controller,
    subtitle,
  })  : _controller = controller,
        _subtitle = subtitle,
        _title = title;

  final String? _subtitle;
  final WebViewController _controller;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
          const Spacer(),
          Text(
            _subtitle ?? "",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
