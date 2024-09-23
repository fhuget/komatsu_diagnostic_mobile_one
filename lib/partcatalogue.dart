import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/home_screen.dart';
import 'package:komatsu_diagnostic/omm.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PartCataloguePage extends StatefulWidget {
  const PartCataloguePage({super.key});

  @override
  _PartCataloguePageState createState() => _PartCataloguePageState();
}

class _PartCataloguePageState extends State<PartCataloguePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Stream<List<PartCatalogueItem>> getPartCatalogueItems() {
    if (_searchText.isEmpty) {
      return FirebaseFirestore.instance
          .collection('PartCatalogue')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PartCatalogueItem.fromDocument(doc))
              .toList());
    } else {
      return FirebaseFirestore.instance
          .collection('PartCatalogue')
          .where('JenisMobil', isGreaterThanOrEqualTo: _searchText)
          .where('JenisMobil', isLessThanOrEqualTo: '$_searchText\uf8ff')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PartCatalogueItem.fromDocument(doc))
              .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 145, 0),
        title: const Text("Part Catalogue"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/unitedtractors.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.orange.withOpacity(0.6),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "PT. UNITEDTRACTORS\nUJUNG PANDANG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
              child: const ListTile(
                trailing: Icon(Icons.search),
                title: Text("Find Error Code"),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const PartCataloguePage()));
              },
              child: const ListTile(
                trailing: Icon(Icons.book),
                title: Text("Part Catalogue"),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OMMPage()));
              },
              child: const ListTile(
                trailing: Icon(Icons.build),
                title: Text("OMM"),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Jenis Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PartCatalogueItem>>(
              stream: getPartCatalogueItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => View(
                            url: item.pdfUrl,
                            jenisMobil: item.jenisMobil,
                          ),
                        ),
                      ),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                item.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(item.jenisMobil),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PartCatalogueItem {
  final String id;
  final String jenisMobil;
  final String imageUrl;
  final String pdfUrl;

  PartCatalogueItem({
    required this.id,
    required this.jenisMobil,
    required this.imageUrl,
    required this.pdfUrl,
  });

  factory PartCatalogueItem.fromDocument(DocumentSnapshot doc) {
    return PartCatalogueItem(
      id: doc.id,
      jenisMobil: doc['JenisMobil'] ?? 'Unknown',
      imageUrl: doc['imageUrl'] ?? '',
      pdfUrl: doc['pdfUrl'] ?? '',
    );
  }
}

class View extends StatefulWidget {
  final String url;
  final String jenisMobil;

  const View({super.key, required this.url, required this.jenisMobil});

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<View> {
  late PdfViewerController _pdfViewerController;
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    _searchController.addListener(() async {
      if (_searchController.text.isNotEmpty) {
        _searchResult = await _pdfViewerController.searchText(_searchController.text);
        setState(() {});
      } else {
        _pdfViewerController.clearSelection();
        setState(() {
          _searchResult.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _jumpToNextMatch() {
    if (_searchResult.currentInstanceIndex < _searchResult.totalInstanceCount - 1) {
      _searchResult.nextInstance();
      setState(() {});
    }
  }

  void _jumpToPreviousMatch() {
    if (_searchResult.currentInstanceIndex > 0) {
      _searchResult.previousInstance();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jenisMobil),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Find in PDF',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _jumpToPreviousMatch,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: _jumpToNextMatch,
                ),
              ],
            ),
          ),
          Text('Matches found: ${_searchResult.totalInstanceCount}'),
          Expanded(
            child: SfPdfViewer.network(
              widget.url,
              controller: _pdfViewerController,
            ),
          ),
        ],
      ),
    );
  }
}
