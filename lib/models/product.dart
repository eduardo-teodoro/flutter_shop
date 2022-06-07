import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    //para ter a reatividade
    notifyListeners();
  }

  //método para alterar o vlor de Favorito
  Future<void> toggleFavorite() async {

    try{
    _toggleFavorite();
    final response = await http.patch(
      Uri.parse("${Constants.PRODUCT_BASE_URL}/$id.json"),
      //o body recebe um json
      body: jsonEncode({
        "isFavorite": isFavorite,
      }),
    );
    if (response.statusCode >= 400) {
      _toggleFavorite();
    }      

    }catch(error){
      _toggleFavorite();
    }



  }
}
