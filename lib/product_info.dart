import 'package:flutter/material.dart';
import 'database_provider.dart';
import 'product.dart';

class ProductInfo extends StatelessWidget {
  final int id;

  ProductInfo(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Info'),
      ),
      body: FutureBuilder(
        future: DatabaseProvider.db.getProduct(id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Product p = snapshot.data as Product;
            return Text(
              'Id: ${p.id}\nName: ${p.productName}'
                  '\nQuantity: ${p.quantity}\nPrice: ${p.price}',
              style: TextStyle(fontSize: 25.0),
            );
          } else
            return Text('waiting');
        },
      ),
    );
  }
}
