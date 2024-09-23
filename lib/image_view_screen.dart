import 'package:flutter/material.dart';
import 'package:zoom_view/zoom_view.dart';

class ImageViewScreen extends StatefulWidget {
  final List<String> imageUrls;
  const ImageViewScreen({super.key, required this.imageUrls});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 9;
  final List<String> _displayedImages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadMoreImages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreImages();
      }
    });
  }

  void _loadMoreImages() {
    setState(() {
      int nextPage = _currentPage + 1;
      int startIndex = _currentPage * _perPage;
      int endIndex = startIndex + _perPage;
      if (startIndex < widget.imageUrls.length) {
        _displayedImages.addAll(widget.imageUrls.sublist(
            startIndex,
            endIndex > widget.imageUrls.length
                ? widget.imageUrls.length
                : endIndex));
        _currentPage = nextPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Images'),
      ),
      body: ZoomListView(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _displayedImages.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < _displayedImages.length) {
              return Container(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  _displayedImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
