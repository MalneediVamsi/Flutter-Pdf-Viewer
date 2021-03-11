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
  String corruptedPathPDF = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Pdf_render example app'),
          ),
          backgroundColor: Colors.grey,
          body: Container(
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
                                  Container(
                                      width: 50,
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(0),
                                      color: Colors.black12,
                                      child: PdfPageView(
                                        pdfDocument: pdfDocument,
                                        pageNumber: index + 1,
                                      )
                                  ),

                            )
                    ),
              )
          )
      ),
    );
  }
}