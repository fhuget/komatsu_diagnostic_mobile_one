import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewScreen extends StatefulWidget {
  final String title;
  final String document;
  const PdfViewScreen({super.key, required this.title, required this.document});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PdfTextSearchResult _searchResult;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    _searchResult = PdfTextSearchResult();
    super.initState();
  }

  void _searchText(String text) async {
    _searchResult = await _pdfViewerKey.currentState?.searchTextAsync(text) ?? PdfTextSearchResult();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 255, 145, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  onQueryChanged: (query) {
                    _searchText(query);
                  },
                ),
              );
            },
          ),
          if (_searchResult.totalInstanceCount > 0)
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                _searchResult.previousInstance();
              },
            ),
          if (_searchResult.totalInstanceCount > 0)
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                _searchResult.nextInstance();
              },
            ),
        ],
      ),
      body: SfPdfViewer.asset(
        widget.document,
        key: _pdfViewerKey,
      ),
    );
  }
}

extension on SfPdfViewerState? {
  searchTextAsync(String text) {}
}

class CustomSearchDelegate extends SearchDelegate {
  final Function(String) onQueryChanged;

  CustomSearchDelegate({required this.onQueryChanged});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onQueryChanged(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onQueryChanged(query);
    return Container();
  }
}
