import 'package:flutter/material.dart';
import 'product_info.dart';
import 'product.dart';
import 'database_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  List<Product> products = [];
  late int updateId;
  var control = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Product information',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  letterSpacing: 2.0),
            ),
            TextField(
              controller: control[0],
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            TextField(
              controller: control[1],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            TextField(
              controller: control[2],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (control[0].text.isEmpty ||
                        control[1].text.isEmpty ||
                        control[2].text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please fill all fields');
                      return;
                    }
                    DatabaseProvider.db
                        .insert(Product(
                        productName: control[0].text,
                        quantity: int.parse(control[1].text),
                        price: double.parse(control[2].text)))
                        .then((value) {
                      print(value);
                    });
                    for (var element in control) {
                      element.clear();
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (control[0].text.isEmpty ||
                        control[1].text.isEmpty ||
                        control[2].text.isEmpty) {
                      Fluttertoast.showToast(msg: 'determine a product to update by long pressing the tile');
                      return;
                    }
                    DatabaseProvider.db
                        .updateProduct(Product(
                        id: updateId,
                        productName: control[0].text,
                        quantity: int.parse(control[1].text),
                        price: double.parse(control[2].text)))
                        .then((value) {
                      if (value != 0) {
                        Fluttertoast.showToast(msg: 'Updated');
                      } else {
                        Fluttertoast.showToast(msg: 'Not updated');
                      }
                    });
                    for (var element in control) {
                      element.clear();
                    }
                    updateId = -1;
                    setState(() {});
                  },
                  icon: const Icon(Icons.update),
                  label: const Text('Update Product'),
                ),
              ],
            ),
            const Text(
              'Your Products:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  letterSpacing: 2.0),
            ),
            FutureBuilder(
              future: DatabaseProvider.db.products,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Product> products = snapshot.data as List<Product>;
                  if (products.isNotEmpty) {
                    return Container(
                      height: 250,
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            color: Colors.blue[200],
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductInfo(products[index].id??0),
                                    ));
                              },
                              onLongPress: () {
                                updateId = products[index].id ?? 0;
                                control[0].text = products[index].productName;
                                control[1].text =
                                    products[index].quantity.toString();
                                control[2].text =
                                    products[index].price.toString();
                                setState(() {});
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 1),
                              leading: Text(
                                products.elementAt(index).productName,
                                style: const TextStyle(
                                  letterSpacing: 2.0,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text('Price: ${products[index].price}'),
                              subtitle:
                              Text('Quantity: ${products[index].quantity}'),
                              trailing: TextButton.icon(
                                onPressed: () {
                                  DatabaseProvider.db
                                      .removeProduct(products[index].id??0)
                                      .then((value) {
                                    if (value != 0) {
                                      Fluttertoast.showToast(msg: 'deleted successfully');
                                    } else {
                                      Fluttertoast.showToast(msg: 'nothing deleted');
                                    }
                                  });
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                label: const Text(''),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Text('no products');
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'delete all',
        onPressed: () {
          DatabaseProvider.db.removeAll().then((value) {
            Fluttertoast.showToast(msg: '$value product(s) deleted');
          });
          setState(() {});
        },
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }
}
