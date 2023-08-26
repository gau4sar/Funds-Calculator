import 'package:flutter/material.dart';

import '../../database/DatabaseHelper.dart';
import '../../database/models/Fund.dart';
import '../../database/models/Stock.dart';

class FundViewModel extends ChangeNotifier {
  List<Fund> funds = [];

  Future<void> loadFundsAndStocks(Function callback) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    final fundsData = await db.query('funds');
    funds = fundsData.map((fund) {
      return Fund.fromMap(fund);
    }).toList();

    // Load stocks for each fund
    for (final fund in funds) {
      final stocksData =
          await db.query('stocks', where: 'fundId = ?', whereArgs: [fund.id]);
      final stocks = stocksData.map((stock) => Stock.fromMap(stock)).toList();
      fund.stocks.addAll(stocks);
    }

    notifyListeners();
    callback();
  }

  Future<void> removeStock(Stock stock) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    // Remove the stock from the database
    await db.delete(
      'stocks',
      where: 'id = ?',
      whereArgs: [stock.id],
    );

    // Remove the stock from the ViewModel
    final fundIndex = funds.indexWhere((f) => f.id == stock.fundId);
    if (fundIndex != -1) {
      funds[fundIndex].stocks.removeWhere((s) => s.id == stock.id);
      notifyListeners();
    }
  }

  Future<void> updateFund({
    required Fund updatedFund,
    required String oldName,
    required Function({required bool isError, String? errorMessage}) callback,
  }) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    // Check if the updated fund name already exists (excluding the current fund)
    // Check if the fund name already exists
    Fund? existingFund = funds.firstWhere(
        (existingFund) =>
            existingFund.name.toLowerCase() == updatedFund.name.toLowerCase(),
        orElse: () => Fund(id: -1, name: "noname", price: "-1", stocks: []));
    if (updatedFund.name != oldName &&
        existingFund.name == "noname" &&
        existingFund.id == -1) {
      // Update the fund in the database
      await db.update('funds', updatedFund.toMap(),
          where: 'id = ?', whereArgs: [updatedFund.id]);

      final fundIndex = funds.indexWhere((fund) => fund.id == updatedFund.id);
      if (fundIndex != -1) {
        funds[fundIndex] = updatedFund;
        notifyListeners();
        callback(isError: false);
      }
    } else {
      callback(isError: true, errorMessage: 'Fund name already exists');
      return;
    }
  }

  Future<void> addFund({
    required Fund fund,
    required Function({required bool isError, String? errorMessage}) callback,
  }) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    print(
        "Adding fund name-> ${fund.name} id->${fund.id} price->${fund.price}");
    for (var element in funds) {
      print(
          "fund name-> ${element.name} id->${element.id} price->${element.price}");
    }

    // Check if the fund name already exists
    Fund? existingFund = funds.firstWhere(
        (existingFund) =>
            existingFund.name.toLowerCase() == fund.name.toLowerCase(),
        orElse: () => Fund(id: -1, name: "noname", price: "-1", stocks: []));

    print("existingFund ${existingFund.name} ${existingFund.id}");
    if (existingFund.name == "noname" && existingFund.id == -1) {
      await db.insert('funds', fund.toMap());

      funds.add(fund);
      notifyListeners();
      callback(isError: false, errorMessage: '');
    } else {
      callback(isError: true, errorMessage: 'Fund name already exists');
      return;
    }
  }

  Future<void> addStockToFund({
    required Fund fund,
    required Stock stock,
    required Function({required bool isError, String? errorMessage}) callback,
  }) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    // Check if the stock name already exists in the same fund

    Stock? existingStock = fund.stocks.firstWhere(
        (existingStock) =>
            existingStock.name.toLowerCase().trim() ==
            stock.name.toLowerCase().trim(),
        orElse: () =>
            Stock(id: -1, fundId: -1, name: "noname", percentage: -1));

    if (existingStock.name == "noname" && existingStock.id == -1) {
      // Insert the stock into the database and get its auto-generated ID
      final stockId = await db.insert('stocks', stock.toMap());

      // Update the stock's ID with the auto-generated ID
      final updatedStock = Stock(
        id: stockId,
        fundId: stock.fundId,
        name: stock.name.trim(),
        percentage: stock.percentage,
      );

      // Update the ViewModel's fund list with the updated stock
      final fundIndex = funds.indexWhere((f) => f.id == fund.id);
      if (fundIndex != -1) {
        fund.stocks.add(updatedStock);
        notifyListeners();
        callback(isError: false);
        print("addStockToFund successful");
      } else {
        callback(isError: true, errorMessage: 'Failed to add stock to fund');
        print("addStockToFund failed");
      }
    } else {
      callback(
          isError: true,
          errorMessage: 'Stock name already exists in the same fund');
      return;
    }
  }

  Future<void> updateStock({
    required Fund fund,
    required Stock stock,
    required String oldName,
    required Function({required bool isError, String? errorMessage}) callback,
  }) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    // Check if the updated stock name already exists in the same fund (excluding the current stock)

    Stock? existingStock = fund.stocks.firstWhere(
        (existingStock) =>
            existingStock.name.toLowerCase().trim() ==
            stock.name.toLowerCase().trim(),
        orElse: () =>
            Stock(id: -1, fundId: -1, name: "noname", percentage: -1));

    if (stock.name != oldName &&
        existingStock.name == "noname" &&
        existingStock.id == -1) {
      // Update the stock in the database
      await db.update(
        'stocks',
        stock.toMap(),
        where: 'id = ?',
        whereArgs: [stock.id],
      );

      // Update the stock in the ViewModel
      final fundIndex = funds.indexWhere((f) => f.id == stock.fundId);
      if (fundIndex != -1) {
        final stockIndex = fund.stocks.indexWhere((s) => s.id == stock.id);
        if (stockIndex != -1) {
          fund.stocks[stockIndex] = stock;
          notifyListeners();
          callback(isError: false);
        }
      }
    } else {
      callback(
          isError: true,
          errorMessage: 'Stock name already exists in the same fund');
      return;
    }
  }

  Future<void> removeFund(Fund fund) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getDatabase();

    // Remove the fund and its associated stocks from the database
    await db.delete('funds', where: 'id = ?', whereArgs: [fund.id]);
    await db.delete('stocks', where: 'fundId = ?', whereArgs: [fund.id]);

    // Remove the fund from the ViewModel
    final fundIndex = funds.indexWhere((f) => f.id == fund.id);
    if (fundIndex != -1) {
      funds.removeAt(fundIndex);
      notifyListeners();
    }
  }
}
