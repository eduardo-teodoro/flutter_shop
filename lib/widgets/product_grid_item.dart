import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';

import 'package:shop/utils/app_routes.dart';

import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //obtendo o produto a partir do provider, vendo de product_grid
    final product = Provider.of<Product>(
      context,
      //segundo parametro para que a classe possa escutar
      listen: false,
    );
    final cart = Provider.of<Cart>(
      context,
      //segundo parametro para que a classe possa escutar
      listen: false,
    );

    //ClipRRect cortar de forma arredondada um elemento
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            //zoom na imagem dentro do quadrado
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.PRODUCT_DETAIL,
              arguments: product,
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //       builder: (ctx) => ProductDetailPage(product: product)),
            // );
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            //Terceiro parametro é um child que você pode passar para o consumer, é um trcho de código que nunca irá ser modificado. Exemplo
            //Uma alteração n interface que nunca irá ser modificado
            builder: (ctx, product, _) => IconButton(
              onPressed: () {
                product.toggleFavorite();
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              //é pesquisado o Scaffold mais próximo em execução
              //Scaffold.of(context).showSnackBar();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Produto adicionado com sucesso!"),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "DESFAZER",
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
              cart.addItem(product);
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
