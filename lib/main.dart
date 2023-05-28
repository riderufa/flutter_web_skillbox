import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;
  late InAppWebViewController? _inAppWebViewController;
  late TextEditingController _textEditingController;
  final ValueNotifier<bool> _canGoBack = ValueNotifier(false);
  final ValueNotifier<bool> _canGoForward = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<Uri> _uri = ValueNotifier(Uri.parse('https://yandex.ru'));

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              height: 70,
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _canGoBack,
                    builder: (context, value, child) {
                      return GestureDetector(
                        onTap: () {
                          if (value) {
                            _inAppWebViewController!.goBack();
                          }
                        },
                        child: SizedBox(
                          width: 40,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: value ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _canGoForward,
                    builder: (context, value, child) {
                      return GestureDetector(
                        onTap: () {
                          if (value) {
                            _inAppWebViewController!.goForward();
                          }
                        },
                        child: SizedBox(
                          width: 40,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: value ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _isLoading,
                    builder: (context, value, child) {
                      return GestureDetector(
                        onTap: () {
                          value
                              ? _inAppWebViewController!.goBack()
                              : _inAppWebViewController!.reload();
                        },
                        child: SizedBox(
                          width: 40,
                          child: value
                              ? const Icon(Icons.cancel)
                              : const Icon(Icons.refresh),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 300,
                    child: ValueListenableBuilder(
                      valueListenable: _uri,
                      builder: (context, uri, child) {
                        return TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              hintText: uri.toString(),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.all(5)),
                          onSubmitted: (value) async {
                            _uri.value = Uri.parse(value);
                            await _inAppWebViewController?.loadUrl(
                              urlRequest: URLRequest(url: _uri.value),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    onWebViewCreated: (controller) {
                      _inAppWebViewController = controller;
                    },
                    initialOptions: options,
                    initialUrlRequest: URLRequest(
                      url: Uri.parse('https://yandex.ru'),
                    ),
                    onLoadStart: (controller, url) async {
                      _isLoading.value = true;
                      _canGoBack.value = await controller.canGoBack();
                      _canGoForward.value = await controller.canGoForward();
                    },
                    onLoadStop: (controller, url) {
                      _isLoading.value = false;
                    },
                    onProgressChanged:
                        (InAppWebViewController controller, int progress) {
                      setState(() {
                        _progress = progress / 100;
                      });
                    },
                  ),
                  _progress < 1
                      ? SizedBox(
                          height: 3,
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
