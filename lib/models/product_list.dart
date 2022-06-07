import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

import '../utils/constants.dart';

class ProductList with ChangeNotifier {
  
  List<Product> _items = [];
  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();
  int get itemsCount {
    return _items.length;
  }

//para obter os produtos cadastrados
  Future<void> loadProducts() async {
    _items.clear();
    //
    final response = await http.get(
      Uri.parse("${Constants.PRODUCT_BASE_URL}.json"),
    );
    if (response.body == "null") return;
    //print(jsonDecode(response.body));
    //a resposta será armazenada em um map
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach(
      (productId, productData) {
        _items.add(
          Product(
            id: productId,
            name: productData["name"],
            description: productData["description"],
            price: productData["price"],
            imageUrl: productData["imageUrl"],
            isFavorite: productData["isFavorite"],
          ),
        );
      },
    );
    //para que a notificação seja feita
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data["id"] != null;

    final product = Product(
      id: hasId ? data["id"] as String : Random().nextDouble().toString(),
      name: data["name"] as String,
      description: data["description"] as String,
      price: data["price"] as double,
      imageUrl: data["imageUrl"] as String,
    );

    if (hasId) {
      //chama o método para alterar
      return updateProduct(product);
    } else {
      //chama mo método para inserir
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    //A resposta foi adicionado numa variável de fututo, depois é realizada
    //a leitura dessa variável e adicionada a memoria junto com o produto
    final response = await http.post(Uri.parse("${Constants.PRODUCT_BASE_URL}.json"),
        //o body recebe um json
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        })
        //método then serve para guardar a resposta
        );
    final id = jsonDecode(response.body)["name"];
    _items.add(Product(
      id: id,
      description: product.description,
      imageUrl: product.imageUrl,
      name: product.name,
      price: product.price,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    //obtendo o index para saber se está dentro da lista de produtos
    int index = _items.indexWhere((p) => p.id == product.id);
    //Se o index for maior ou igual a zeror quer dizer que existe um produto dentro da lista
    if (index >= 0) {
      await http.patch(Uri.parse("${Constants.PRODUCT_BASE_URL}/${product.id}.json"),
          //o body recebe um json
          body: jsonEncode({
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "isFavorite": product.isFavorite,
          }));

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    //Se o index for maior ou igual a zeror quer dizer que existe um produto dentro da lista
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse("${Constants.PRODUCT_BASE_URL}/${product.id}.json"),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
            msg: "Não foi possivel excluir o produto",
            statusCode: response.statusCode);
      }
    }
  }

  /*
 //mostra apenas os favoritos, ou não
  bool _showFavoriteOnly = false;

  //[..._items] retorna um clone dos itens , sema a ação de adição ou edição
  //List<Product> get items => [..._items];
  List<Product> get items {
    if (_showFavoriteOnly) {
      //where serve para filtrar
      return _items.where((prod) => prod.isFavorite).toList();
    }

    return [..._items];
  }

  void showFavoriteOnly() {
    _showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoriteOnly = false;
    notifyListeners();
  } 
 */

}
