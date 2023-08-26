import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/Fund.dart';
import 'models/Stock.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const fundsTable = 'funds';
  static const stocksTable = 'stocks';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnPrice = 'price';
  static const columnFundId = 'fundId';
  static const columnStockName = 'name';
  static const columnStockPercentage = 'percentage';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<Database> getDatabase() async {
    await init();
    return _db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $fundsTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnPrice TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $stocksTable (
        $columnId INTEGER PRIMARY KEY,
        $columnFundId INTEGER NOT NULL,
        $columnStockName TEXT NOT NULL,
        $columnStockPercentage REAL NOT NULL
      )
    ''');
  }

  Future<int> insertFund(Fund fund) async {
    return await _db.insert(fundsTable, fund.toMap());
  }

  Future<int> insertStock(Stock stock) async {
    return await _db.insert(stocksTable, stock.toMap());
  }

  Future<List<Fund>> queryAllFunds() async {
    final fundMaps = await _db.query(fundsTable);
    return fundMaps.map((map) => Fund.fromMap(map)).toList();
  }

  Future<List<Stock>> queryStocksForFund(int fundId) async {
    final stockMaps = await _db.query(stocksTable, where: '$columnFundId = ?', whereArgs: [fundId]);
    return stockMaps.map((map) => Stock.fromMap(map)).toList();
  }

}
