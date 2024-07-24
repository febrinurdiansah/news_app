import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String linkNews;

  const DetailScreen({super.key, required this.linkNews});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}


class _DetailScreenState extends State<DetailScreen> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  final blockedUrls = [
    'https://www.youtube.com/',
    'https://shopee.co.id/',
    'https://www.tokopedia.com',
  ];

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            loadingPercentage = progress;
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (blockedUrls.any((url) => request.url.startsWith(url))) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.linkNews));
      }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        controller.clearCache();
        controller.clearLocalStorage();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () async {
                    final massenger = ScaffoldMessenger.of(context);
                    if (await controller.canGoBack()) {
                        await controller.goBack();
                    } else {
                      massenger.showSnackBar(
                        SnackBar(
                          duration: Duration(milliseconds: 200),
                          content: Text(
                            'Tidak bisa kembali',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      );
                      return;
                    }
                  }, 
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () async {
                    final massenger = ScaffoldMessenger.of(context);
                    if (await controller.canGoForward()) {
                        await controller.goForward();
                    } else {
                      massenger.showSnackBar(
                        SnackBar(
                          duration: Duration(milliseconds: 200),
                          content: Text(
                            'Tidak ada riwayat penelusuran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      );
                      return;
                    }
                  }, 
                ),
                IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: () {
                    controller.reload();
                  },
                ),
                MenuPopUpWidget(
                  controller: controller,
                )
              ],
            )
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(
              controller: controller
            ),
            loadingPercentage < 100
              ? LinearProgressIndicator(
                color: Colors.red,
                value: loadingPercentage / 100.0,
              ) : Container()
          ],
        ),
      ),
    );
  }
}

enum _MenuPop {
  copyLink
}
class MenuPopUpWidget extends StatelessWidget {
  final WebViewController controller;

  const MenuPopUpWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuPop>(
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuPop>(
          value: _MenuPop.copyLink,
          child: Text("Salin Link Berita")
          ),
        ],
      onSelected: (value) async{
        if (value == _MenuPop.copyLink){
          String? currentUrl = await controller.currentUrl();
          if (currentUrl != null) {
            Clipboard.setData(ClipboardData(text: currentUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text(
                  'Tautan telah disalin ke papan klip',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            );
          }
        }
      },
      );
  }
}