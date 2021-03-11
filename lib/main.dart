import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset('assets/demo.pdf', 'sample.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    // final url =
    // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
    final url = "https://pdfkit.org/docs/guide.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                RaisedButton(
                    child: Text("Open PDF"),
                    onPressed: () {
                      if (pathPDF != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PDFScreen(path: pathPDF)),
                        );
                      }
                    }),
              ],
            );
          },
        )),
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String path;
  PDFScreen({Key key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int pages = 0;
  bool isReady = false;
  String errorMessage = '';
  GlobalKey pdfKey = GlobalKey();
  bool isActive = true;
  double scale = 1.0;
  double top = 10.0;
  double initialLocalFocalPoint;
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.portrait) {
            final Completer<PDFViewController> _controller =
            Completer<PDFViewController>();
            return Scaffold(
              appBar: AppBar(
                title: Text("Document"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    child: PDFView(
                        key: pdfKey,
                        filePath: widget.path,
                        fitEachPage: true,
                        fitPolicy: FitPolicy.BOTH,
                        dualPageMode: false,
                        enableSwipe: true,
                        swipeHorizontal: true,
                        autoSpacing: true,
                        pageFling: true,
                        defaultPage: 0,
                        pageSnap: true,
                        backgroundColor: bgcolors.BLACK,
                        onRender: (_pages) {
                          print("OK RENDERED!!!!!");
                          setState(() {
                            pages = _pages;
                            isReady = true;
                          });
                        },
                        onError: (error) {
                          setState(() {
                            errorMessage = error.toString();
                          });
                          print(error.toString());
                        },
                        onPageError: (page, error) {
                          setState(() {
                            errorMessage = '$page: ${error.toString()}';
                          });
                          print('$page: ${error.toString()}');
                        },
                        onViewCreated: (PDFViewController pdfViewController) {
                          _controller.complete(pdfViewController);
                        },
                        onPageChanged: (int page, int total) {
                          print('page change: $page/$total');
                        },
                        onZoomChanged: (double zoom) {
                          print("Zoom is now $zoom");
                        }),
                  ),
                  errorMessage.isEmpty
                      ? !isReady
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : Container()
                      : Center(child: Text(errorMessage))
                ],
              ),
              bottomNavigationBar:  Container(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                  height: 100,
                  child: PdfDocumentLoader(
                    assetName: 'assets/demo.pdf',
                    documentBuilder: (context, pdfDocument, pageCount) =>
                        LayoutBuilder(
                            builder: (context, constraints) =>
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pageCount,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                        onTap: (){

                                        },
                                        child: Container(
                                            width: 50,
                                            margin: EdgeInsets.all(5),
                                            padding: EdgeInsets.all(0),
                                            color: Colors.black12,
                                            child: PdfPageView(
                                              pdfDocument: pdfDocument,
                                              pageNumber: index + 1,
                                            ),
                                        ),
                                      ),
                                )
                        ),
                  )
              ),
              floatingActionButton: FutureBuilder<PDFViewController>(
                future: _controller.future,
                builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                  if (snapshot.hasData) {
                    return FloatingActionButton.extended(
                      label: Text("Go to ${pages ~/ 2}"),
                      onPressed: () async {
                        //print(await snapshot.data.getZoom());
                        //print(await snapshot.data.getPageWidth(1));
                        //print(await snapshot.data.getPageHeight(1));
                        await snapshot.data.setPage(pages ~/ 2);
                        await snapshot.data.resetZoom(1);
                        //await snapshot.data.setZoom(3.0);
                        //print(await snapshot.data.getScreenWidth());
                      },
                    );
                  }

                  return Container();
                },
              ),
            );
          } else {
            final Completer<PDFViewController> _controller =
            Completer<PDFViewController>();
            return PDFView(
              filePath: widget.path,
              fitEachPage: true,
              dualPageMode: true,
              displayAsBook: true,
              dualPageWithBreak: true,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              defaultPage: 0,
              pageSnap: true,
              backgroundColor: bgcolors.BLACK,
              onRender: (_pages) {
                print("OK RENDERED!!!!!");
                setState(() {
                  pages = _pages;
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                print(error.toString());
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
                print('$page: ${error.toString()}');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onPageChanged: (int page, int total) {
                print('page change: $page/$total');
              },
            );
          }
        });
  }
}
