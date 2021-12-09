import 'product.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  static const int version = 1;
  static  Database? _database;
  static const String tableName = 'products';
  Future<Database> get database async {
    return _database ??= await initDB();
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    path += 'products.db';
    return await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        await db.execute('''
          create table $tableName (
            id integer primary key autoincrement,
            productName text not null,
            quantity integer not null,
            price real not null
          )
          ''');
      },
    );
  }

  Future<List<Product>> get products async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(tableName, orderBy: 'id asc');
    List<Product> prds = [];
    for (var value in result) {
      prds.add(Product.fromMap(value));
    }
    return prds;
  }

  Future insert(Product product) async {
    final db = await database;
//    return await db.rawInsert('''insert into products (pName,quantity,price)
//                  values (?,?,?)'''
//        ,[product.productName,product.quantity,product.price]);
    return await db.insert(tableName, product.toMap());
  }

  Future<Product> getProduct(int id) async {
    final db = await database;
    List<Map<String, dynamic>> product =
    await db.query(tableName, where: 'id=?', whereArgs: [id]);
    return Product.fromMap(product[0]);
  }

  Future removeAll() async {
    final db = await database;
    return await db.delete(tableName);
  }

  Future<int> removeProduct(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id=?', whereArgs: [id]);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(tableName, product.toMap(),
        where: 'id=?', whereArgs: [product.id]);
  }
}