import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RandomDogsScreen extends StatefulWidget {
  const RandomDogsScreen({super.key, required this.enableSubBreeds});

  final bool enableSubBreeds;

  @override
  State<StatefulWidget> createState() {
    return _RandomDogsScreenState();
  }
}

class _RandomDogsScreenState extends State<RandomDogsScreen> {
  String _imageUrl = ''; //initial image
  List<String> _breeds = []; //list of all master breeds
  String _selectedBreed = ''; //current selected breed in the dropdown
  bool _isLoading = true; //used it to wait while fetching data
  List<String> _subBreeds = [];
  String _selectedSubBreed = '';

  //this method is called in init state to initialize the list of breeds and to load first image
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
          }
        },
      );
      //fetching the starting image, when opening the screen
      final imageResponse = await http.get(
          Uri.parse('https://dog.ceo/api/breed/$_selectedBreed/images/random'));
      Map<String, dynamic> imageData = await json.decode(imageResponse.body);
      setState(() {
        _imageUrl = imageData['message'].toString();
        _isLoading = false;
      });
    } else {
      throw Exception('There was an error');
    }
  }

  //this method is called when users try to load a new random image
  _fetchNewImage() async {
    if (_selectedSubBreed.isEmpty) {
      final response = await http.get(
          Uri.parse('https://dog.ceo/api/breed/$_selectedBreed/images/random'));
      Map<String, dynamic> data = await json.decode(response.body);
      setState(() {
        _imageUrl = data['message'].toString();
      });
    } else {
      final response = await http.get(
          Uri.parse('https://dog.ceo/api/breed/$_selectedBreed/$_selectedSubBreed/images/random'));
      Map<String, dynamic> data = await json.decode(response.body);
      setState(() {
        _imageUrl = data['message'].toString();
      });
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
      });
    }
  }

  @override
  initState() {
    super.initState();
    _fetchBreeds(); //initializing the list of breeds and loading first image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.enableSubBreeds ? 'By Breed and Sub Breed' : 'Only By Breed',
          style: GoogleFonts.alata(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      //_isLoading waits for fetched data, if not, it returns a circular indicator
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        _imageUrl,
                        width: 350,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                _fetchSubBreeds();
                              });
                            },
                            menuHeight: 200,
                            width: 180,
                          ),
                          if (_selectedSubBreed.isNotEmpty &&
                              widget.enableSubBreeds &&
                              _subBreeds.isNotEmpty)
                            DropdownMenu<String>(
                              initialSelection: _subBreeds.first,
                              dropdownMenuEntries:
                                  _subBreeds.map((String subBreed) {
                                return DropdownMenuEntry<String>(
                                  value: subBreed,
                                  label: subBreed.toUpperCase(),
                                );
                              }).toList(),
                              label: const Text('Sub Breed'),
                              onSelected: (selectedSubBreed) {
                                setState(() {
                                  _selectedSubBreed = selectedSubBreed!;
                                });
                              },
                              menuHeight: 200,
                              width: 180,
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _fetchNewImage, //calling the method to fetch a new random image
                      child: const Text('New image'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
