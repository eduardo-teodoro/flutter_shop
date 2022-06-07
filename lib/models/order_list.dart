import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';

class OrderList with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

//para obter os produtos cadastrados
  Future<void> loadOrders() async {
    _items.clear();
    //
    final response = await http.get(
      Uri.parse("${Constants.ORDER_BASE_URL}.json"),
    );
    if (response.body == "null") return;
    //print(jsonDecode(response.body));
    //a resposta será armazenada em um map
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach(
      (orderId, orderData) {
        _items.add(
          Order(
            id: orderId,
            date: DateTime.parse(orderData["date"]),
            total: orderData["total"],
            products: (orderData["products"] as List<dynamic>).map((item) {
              return CartItem(
                id: item["id"],
                productId: item["productId"],
                name: item["name"],
                quantity: item["quantity"],
                price: item["price"],
              );
            }).toList(),
          ),
        );
      },
    );
    //para que a notificação seja feita
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse("${Constants.ORDER_BASE_URL}.json"),
      //o body recebe um json
      body: jsonEncode(
        {
          "total": cart.totalAmount,
          //data no formato padronizado
          "date": date.toIso8601String(),
          //percorrendo os itens do carrinho
          "products": cart.items.values
              .map(
                (cartItem) =>
                    //retornando um map
                    {
                  "id": cartItem.id,
                  "productId": cartItem.productId,
                  "name": cartItem.name,
                  "quantity": cartItem.quantity,
                  "price": cartItem.price
                },
              )
              .toList(),
        },
      ),

      //método then serve para guardar a resposta
    );
    final id = jsonDecode(response.body)["name"];
    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        date: date,
      ),
    );
    notifyListeners();
  }
}
