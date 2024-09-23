import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/image_view_screen.dart';
import 'package:komatsu_diagnostic/partcatalogue.dart';
import 'package:komatsu_diagnostic/omm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("CRUDItems");
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 145, 0),
        title: const Text("Komatsu Diagnostic"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/unitedtractors.png"),
                  fit: BoxFit.cover, // Membuat gambar menutupi seluruh area
                ),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
              child: const ListTile(
                trailing: Icon(Icons.search),
                title: Text("Find Error Code"),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PartCataloguePage()));
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
              decoration: InputDecoration(
                labelText: 'Type Here Error Code',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: myItems.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                List<String> units = snapshot.data!.docs
                    .map((doc) => doc['NamaUnits'] as String)
                    .toSet()
                    .toList();
                return DropdownButton<String>(
                  hint: const Text('Filter by Units'),
                  value: _selectedUnit,
                  items: units.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  },
                  isExpanded: true,
                );
              },
            ),
          ),
          Expanded(
            child: _searchText.isEmpty
                ? const Center(
                    child: Text(
                      'Komatsu Diagnostic\nPT. Unitedtractors Ujung Pandang.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: myItems.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        var filteredDocs = streamSnapshot.data!.docs;

                        if (_selectedUnit != null) {
                          filteredDocs = filteredDocs
                              .where((doc) => doc['NamaUnits'] == _selectedUnit)
                              .toList();
                        }

                        if (_searchText.isNotEmpty) {
                          filteredDocs = filteredDocs
                              .where((doc) => (doc['KodeError'] as String)
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()))
                              .toList();
                        }

                        return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                filteredDocs[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  subtitle: Text(
                                    documentSnapshot['NamaUnits'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  title: Text(
                                    "[${documentSnapshot['KodeError']}] ${documentSnapshot['NamaError']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewScreen(
                                          imageUrls: List<String>.from(
                                              documentSnapshot['imageUrls']),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
