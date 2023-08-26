import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../database/models/Fund.dart';
import '../database/models/Stock.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ViewModel/FundViewModel.dart';

class FundDetailsPage extends StatefulWidget {
  final String fundName;
  final int fundId;
  final String fundPrice;

  FundDetailsPage(
      {required this.fundName, required this.fundPrice, required this.fundId});

  @override
  _FundDetailsPageState createState() => _FundDetailsPageState();
}

class _FundDetailsPageState extends State<FundDetailsPage> {
  late FundViewModel _viewModel;
  TextEditingController _stockNameController = TextEditingController();
  TextEditingController _stockPercentageController = TextEditingController();
  var isLoading = true;
  var totalAllocatedPercentage = 0.00;
  var originalRemainingPercentage = 0.00;

  Fund? fund = null;
  var stocks = null;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _viewModel = Provider.of<FundViewModel>(context);
  //
  //   updateOriginalRemainingPercentage();
  //
  //   print("didChangeDependencies");
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _viewModel = Provider.of<FundViewModel>(context, listen: false);

      isLoading = false;

      updateOriginalRemainingPercentage();

      setState(() {});

      print("initState WidgetsBinding addPostFrameCallback");
    });
  }

  updateOriginalRemainingPercentage() {
    _viewModel.loadFundsAndStocks(() {
      var fundLocal =
          _viewModel.funds.firstWhere((fund) => fund.id == widget.fundId);
      double calculatedTotalAllocatedPercentage = 0.0; // Use a local variable

      print("stocks length -> ${fundLocal.stocks.length}");
      for (var element in fundLocal.stocks) {
        calculatedTotalAllocatedPercentage += element.percentage;
        print(
            "stocks name-> ${element.name} id->${element.id} percentage->${element.percentage}");
      }

      print(
          "fund name -> ${fundLocal.name} id-> ${fundLocal.id} price-> ${fundLocal.price} stocks-> ${fundLocal.stocks.length}");
      setState(() {
        totalAllocatedPercentage = calculatedTotalAllocatedPercentage;
        originalRemainingPercentage = 100 - totalAllocatedPercentage ;
        stocks = fundLocal.stocks;
        fund = fundLocal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final fundPriceDouble = double.parse(widget.fundPrice);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fundName),
      ),
      body: isLoading
          ? null
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Fund Price: Rs ${widget.fundPrice} Fund id:${widget.fundId}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                  child: // Wrap the ListView.builder with a Consumer widget
                      Consumer<FundViewModel>(
                    builder: (context, fundViewModel, child) {
                      final funds = fundViewModel
                          .funds; // Access the data from the provider

                      final stocks = funds
                          .where((element) => element.id == widget.fundId)
                          .first
                          .stocks;

                      // Use the funds data to build your UI
                      return ListView.builder(
                        itemCount: stocks.length,
                        itemBuilder: (context, index) {
                          final stock = stocks[index];
                          final stockPrice =
                          (stock.percentage * fundPriceDouble/100)
                              .toStringAsFixed(2);
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 6, bottom: 6),
                                child: ListTile(
                                  title: Text(stock.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${(stock.percentage).toStringAsFixed(8).replaceAll(RegExp(r'0{1,6}$'), '').replaceAll(RegExp(r'\.$'), '')}% of Fund'),
                                      Text('Stock Price: Rs $stockPrice'),
                                    ],
                                  ),
                                  onTap: () {
                                    _showUpdateStockDialog(context, stock);
                                  },
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300], // Light grey color
                                height: 1, // Height of the divider
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                print(
                    "originalRemainingPercentage -> $originalRemainingPercentage");
                print(
                    "originalRemainingPercentage+0.009999<0.001111 -> ${originalRemainingPercentage - 0.000999 < 0.009999}");
                if (originalRemainingPercentage - 0.000099 < 0.000999) {
                  Fluttertoast.showToast(
                    msg: 'No funds remaining',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  _showAddStockDialog(context);
                }
              },
              child: Icon(Icons.add),
            ),
    );
  }

  void _showAddStockDialog(BuildContext context) {
    bool _isAddButtonEnabled = false; // Initialize to false

    StateSetter? setStateCallback;

    double remainingPercentage = 100 - totalAllocatedPercentage ;

    //final stockPercentage = _stockPercentageController.text;

    void _updateAddButtonStatus() {
      final stockPercentage =
          double.tryParse(_stockPercentageController.text) ?? 0;

      final stockName = _stockNameController.text;

      if (_stockPercentageController.text.isNotEmpty) {
        print("stockPercentage -> ${stockPercentage.toString()}");
        print("_stockPercentageController -> ${((100 - stockPercentage))}");
        print(
            "stockPercentage > originalRemainingPercentage -> ${stockPercentage > originalRemainingPercentage}");

        if (stockPercentage > originalRemainingPercentage) {
          Fluttertoast.showToast(
            msg:
                'Max percentage that can be added is ${originalRemainingPercentage}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          _stockPercentageController.text = "${originalRemainingPercentage}";


          print("_stockPercentageController value -> ${_stockPercentageController.text}");
          _stockPercentageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _stockPercentageController.text.length),
          );

          remainingPercentage = 0.0;
        } else {
          //_stockPercentageController.text = (stockPercentage ).toString();
          remainingPercentage = (originalRemainingPercentage - stockPercentage);
        }
      } else {
        remainingPercentage = originalRemainingPercentage;
      }

      print("stockPercentage -> ${stockPercentage.toString()}");
      print("stockName -> ${stockName}");
      if (stockName.isNotEmpty && stockPercentage > 0) {
        print("_isAddButtonEnabled = true");
        _isAddButtonEnabled = true;
      } else {
        print("_isAddButtonEnabled = false");
        _isAddButtonEnabled = false;
      }

      // Update the state to reflect the changes
      setStateCallback?.call(() {
        print("setStateCallback called");
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateCallback = setState;
            return AlertDialog(
              title: Text('Add Stock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _stockNameController,
                    decoration: InputDecoration(labelText: 'Stock Name'),
                    onChanged: (_) =>
                        _updateAddButtonStatus(), // Update status on change
                  ),
                  TextField(
                    controller: _stockPercentageController,
                    decoration: InputDecoration(labelText: 'Stock Percentage'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) =>
                        _updateAddButtonStatus(), // Update status on change
                  ),
                  Text(
                    'Remaining Percentage: ${(remainingPercentage).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _stockNameController.clear();
                    _stockPercentageController.clear();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isAddButtonEnabled
                      ? () {
                          final stockPercentage = double.tryParse(
                                  _stockPercentageController.text) ??
                              0;

                          final stockName = _stockNameController.text;
                          final stock = Stock(
                              name: stockName.trim(),
                              percentage: stockPercentage.toDouble() ,
                              fundId: widget.fundId);

                          _viewModel.addStockToFund(fund:fund!,stock:stock, callback: ({required bool isError, String? errorMessage}) {
                            if (isError) {
                              // Handle the error case here
                              if (errorMessage != null) {
                                print(errorMessage);

                                Fluttertoast.showToast(
                                  msg:
                                  errorMessage,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            } else {
                              // Handle the success case here
                              print("Stock added successfully");

                              updateOriginalRemainingPercentage();

                              Navigator.of(context).pop();
                              _stockNameController.clear();
                              _stockPercentageController.clear();
                            }
                          });

                        }
                      : null, // Disable the button if fields are not filled
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showUpdateStockDialog(BuildContext context, Stock stock) {
    double updatedStockPercentage = stock.percentage;
    double updatedRemainingPercentage = originalRemainingPercentage;

    TextEditingController _stockNameController =
    TextEditingController(text: stock.name);
    TextEditingController _stockPercentageController =
    TextEditingController(text: updatedStockPercentage.toStringAsFixed(0));

    bool isUpdateButtonEnabled = true; // Initially enabled

    void _updateRemainingPercentage() {
      final newStockPercentage =
          double.tryParse(_stockPercentageController.text) ?? 0;
      updatedRemainingPercentage = originalRemainingPercentage +
          (updatedStockPercentage - newStockPercentage);

      // Check conditions and update the button status
      if (newStockPercentage < 0 ||
          newStockPercentage > 100 ||
          updatedRemainingPercentage < 0 ||
          updatedRemainingPercentage > 100) {
        _stockPercentageController.text =
            (originalRemainingPercentage + updatedStockPercentage).toString();
        updatedRemainingPercentage = 0.00;

        Fluttertoast.showToast(
          msg:
          'Max percentage that can be added is ${(originalRemainingPercentage + updatedStockPercentage)}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        print("_stockPercentageController value -> ${_stockPercentageController.text}");
        _stockPercentageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _stockPercentageController.text.length),
        );
      }

      if (newStockPercentage == 0 || _stockNameController.text.isEmpty) {
        isUpdateButtonEnabled = false;
      } else {
        isUpdateButtonEnabled = true;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Stock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _stockNameController,
                    decoration: InputDecoration(labelText: 'Stock Name'),
                    onChanged: (_) {
                      final newStockPercentage =
                          double.tryParse(_stockPercentageController.text) ?? 0;

                      if (newStockPercentage == 0 ||
                          _stockNameController.text.isEmpty) {
                        isUpdateButtonEnabled = false;
                      } else {
                        isUpdateButtonEnabled = true;
                      }
                      setState(() {});
                    },
                  ),
                  TextField(
                    controller: _stockPercentageController,
                    decoration: InputDecoration(labelText: 'Stock Percentage'),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalInputFormatter()],
                    onChanged: (_) {
                      setState(() {
                        _updateRemainingPercentage();
                      });
                    },
                  ),
                  Text(
                    'Remaining Percentage: ${(updatedRemainingPercentage).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: isUpdateButtonEnabled
                      ? () {
                    final stockName = _stockNameController.text;
                    final stockPercentage =
                        double.tryParse(_stockPercentageController.text) ??
                            0;

                    if (stockPercentage > 0 &&
                        stockPercentage <= 100 &&
                        updatedRemainingPercentage >= 0 &&
                        updatedRemainingPercentage < 100) {
                      final updatedStock = Stock(
                        id: stock.id,
                        fundId: stock.fundId,
                        name: stockName.trim(),
                        percentage: stockPercentage.toDouble(),
                      );

                      // Update the ViewModel and remaining percentage
                      _viewModel.updateStock(
                        fund: fund!,
                        oldName: stock.name,
                        stock: updatedStock,
                        callback: ({
                          required bool isError,
                          String? errorMessage,
                        }) {
                          if (isError) {
                            // Handle the error case here
                            if (errorMessage != null) {
                              print(errorMessage);

                              Fluttertoast.showToast(
                                msg: errorMessage,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          } else {
                            // Handle the success case here
                            print("Stock updated successfully");

                            originalRemainingPercentage =
                                updatedRemainingPercentage;
                            updateOriginalRemainingPercentage();
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg:
                        'Max percentage that can be added is ${originalRemainingPercentage}',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );

                      print("_stockPercentageController value -> ${_stockPercentageController.text}");
                      _stockPercentageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _stockPercentageController.text.length),
                      );
                    }
                  }
                      : null,
                  child: Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    _viewModel.removeStock(stock);
                    updateOriginalRemainingPercentage();
                    Navigator.of(context).pop();
                  },
                  child: Text('Remove'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove spaces
    final newText = newValue.text.replaceAll(" ", "");

    if (newText.isEmpty || newText == "." || newText == "-") {
      return newValue.copyWith(text: newText);
    } else if (newText.contains(".") && newText.endsWith(".")) {
      final updatedText = newText.replaceAll(".", "");
      final selectionIndex = newValue.selection.end - (newText.length - updatedText.length);
      return TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
    } else if (double.tryParse(newText) != null) {
      return newValue.copyWith(text: newText);
    } else {
      return oldValue;
    }
  }
}

