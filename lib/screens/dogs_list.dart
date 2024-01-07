import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DogsListScreen extends StatefulWidget {
  const DogsListScreen({super.key, required this.enableSubBreeds});

  final bool enableSubBreeds;

  @override
  State<StatefulWidget> createState() {
    return _DogsListScreenState();
  }
}

class _DogsListScreenState extends State<DogsListScreen> {
  List<String> _breeds = [];
  String _selectedBreed = '';
  List<String> _subBreeds = [];
  String _selectedSubBreed = '';
  bool _isLoading = true;
  List<String> _imageUrls = [];

  @override
  initState() {
    super.initState();
    _fetchBreeds();
  }

  _fetchBreeds() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/list'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = await json.decode(response.body);
      setState(
        () {
          _breeds = List<String>.from(data['message']);
          if (_selectedBreed.isEmpty && _breeds.isNotEmpty) {
            _selectedBreed = _breeds.first;
            _fetchSubBreeds();
            _fetchImages();
            if(widget.enableSubBreeds == false) {
              _isLoading = false;
            }
          }
        },
      );
    }
  }

  _fetchSubBreeds() async {
    print('https://dog.ceo/api/breed/$_selectedBreed/list');
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breed/$_selectedBreed/list'),
    );
    Map<String, dynamic> data = await json.decode(response.body);
    _subBreeds = List<String>.from(data['message']);
    if (_subBreeds.isNotEmpty) {
      setState(() {
        _selectedSubBreed = _subBreeds.first;
        print(_selectedSubBreed);
      });
    } else {
      setState(() {
        _selectedSubBreed = '';
        _isLoading = false;
      });
    }
  }

  _fetchImages() async {
    var response;
    if (widget.enableSubBreeds == true && _selectedSubBreed.isNotEmpty) {
      response = await http.get(Uri.parse(
          'https://dog.ceo/api/breed/$_selectedBreed/$_selectedSubBreed/images'));
    } else {
      response = await http
          .get(Uri.parse('https://dog.ceo/api/breed/$_selectedBreed/images'));
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> data = await json.decode(response.body);
      setState(
        () {
          _imageUrls = List<String>.from(data['message']);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.enableSubBreeds
              ? 'List By Breed & Sub Breed'
              : 'List By Breed',
          style: GoogleFonts.alata(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    DropdownMenu<String>(
                      initialSelection: _breeds.first,
                      dropdownMenuEntries: _breeds.map((String breed) {
                        return DropdownMenuEntry<String>(
                          value: breed,
                          label: breed.toUpperCase(),
                        );
                      }).toList(),
                      label: const Text('Breed'),
                      onSelected: (selectedBreed) {
                        setState(() {
                          _selectedBreed = selectedBreed!;
                          _selectedSubBreed = '';
                          _fetchSubBreeds();
                          _fetchImages();
                        });
                      },
                      menuHeight: 200,
                      width: 180,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (_selectedSubBreed.isNotEmpty &&
                        widget.enableSubBreeds &&
                        _subBreeds.isNotEmpty)
                      DropdownMenu<String>(
                        initialSelection: _subBreeds.first,
                        dropdownMenuEntries: _subBreeds.map((String subBreed) {
                          return DropdownMenuEntry<String>(
                            value: subBreed,
                            label: subBreed.toUpperCase(),
                          );
                        }).toList(),
                        label: const Text('Sub Breed'),
                        onSelected: (selectedSubBreed) {
                          setState(() {
                            _selectedSubBreed = selectedSubBreed!;
                            _fetchImages();
                          });
                        },
                        menuHeight: 200,
                        width: 180,
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Image.network(
                                _imageUrls[index],
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
