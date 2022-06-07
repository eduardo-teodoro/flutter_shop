import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_list.dart';
import 'product_grid_item.dart';

class ProductGrid extends StatelessWidget {
  final bool _showFavoriteOnly;
  //construtor
  ProductGrid(this._showFavoriteOnly);
  @override
  Widget build(BuildContext context) {
    //variável com a lista de produtos do arquivo dummy_data
    //  final List<Product> loadedProducts = dummyProducts;
    final provider = Provider.of<ProductList>(context);

    final List<Product> loadedProducts = _showFavoriteOnly? provider.favoriteItems : provider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      //quantidade de itens de o Grid irá renderizar
      itemCount: loadedProducts.length,
      //informando como será construido cada elemento exibido na Gridview
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedProducts[i],
        child: ProductGridItem(),
      ),
      //Sliver é uma área dentro de um scroll WithFixedCrossAxisCount quantidade de elementos na horizontal
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //quantidade de elementos na horizontal
        crossAxisCount: 2,
        //dimensão de cada elemento
        childAspectRatio: 3 / 2,
        // espaço na vertical entre os elementos
        crossAxisSpacing: 10,
        // espaço na horizontal entre os elementos
        mainAxisSpacing: 10,
      ),
    );
  }
}
