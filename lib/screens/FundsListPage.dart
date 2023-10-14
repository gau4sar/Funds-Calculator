import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funds_calculator/utils/Utils.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../data/response/status.dart';
import '../database/models/Fund.dart';
import 'FundDetailsPage.dart';
import 'ViewModel/FundViewModel.dart';
import 'ViewModel/StocksViewModel.dart'; // Import your FundDetailsPage

class FundsListPage extends StatefulWidget {
  @override
  _FundsListPageState createState() => _FundsListPageState();
}

class _FundsListPageState extends State<FundsListPage> {

  late FundViewModel _viewModel;
  List<Fund> funds = [];
  var isLoading = true;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _viewModel = Provider.of<FundViewModel>(context);
  //   _viewModel.loadFundsAndStocks(() {
  //     // Your callback code here
  //     print("loadFundsAndStocks loaded");
  //   });
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      _viewModel = Provider.of<FundViewModel>(context, listen: false);

      loadFunds();

      print("initState WidgetsBinding addPostFrameCallback FundsListPage");
    });
  }

  void loadFunds(){
    _viewModel.loadFundsAndStocks(() {
      // Your callback code here
      //funds = _viewModel.funds;
    });

    isLoading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Funds List'),
      ),
      body: isLoading
          ? null
          : Consumer<FundViewModel>(builder: (context, fundViewModel, child) {
              print("funds -> ${funds.length}");
              funds = _viewModel.funds;

              return ListView.builder(
                itemCount: funds.length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return ListTile(
                    title: Text(fund.name),
                    subtitle: Text('Fund Price: ${fund.price}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FundDetailsPage(
                            fundName: fund.name,
                            fundPrice: fund.price,
                            fundId: fund.id!,
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await _showUpdateFundDialog(context, fund);
                      },
                    ),
                  );
                },
              );
            }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a new fund
          _showAddFundDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _showAddFundDialog(BuildContext context) {
    String fundPrice = '';
    TextEditingController fundNameController = TextEditingController();
    final stockViewModel = Get.put(StocksViewModel());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Fund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: fundNameController,
                  decoration: InputDecoration(labelText: 'Fund Name'),
                ),
                hideOnLoading: true,
                loadingBuilder: (context) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                // Use a conditional widget to display the loading indicator when needed
                suggestionsCallback: (String pattern) => stockViewModel.getTickerSearchResponse(pattern),
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  fundNameController.text = suggestion;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Fund Price'),
                onChanged: (value) => fundPrice = value,
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
              onPressed: () {
                if (fundNameController.text .isNotEmpty && fundPrice.isNotEmpty) {
                  final newFund = Fund(name: fundNameController.text .trim(), price: fundPrice, stocks: []);

                  _viewModel.addFund(fund: newFund, callback: ({required bool isError, String? errorMessage}) {
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
                      print("Stock added successfully");

                      loadFunds();

                      Navigator.of(context).pop();
                    }
                  });
                }
                else{
                  Utils.toastMessage("Please fill all the details");
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateFundDialog(BuildContext context, Fund fund) async {
    String updatedName = fund.name;
    String updatedPrice = fund.price;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Fund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Fund Name'),
                onChanged: (value) => updatedName = value,
                controller: TextEditingController(text: updatedName),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Fund Price'),
                onChanged: (value) => updatedPrice = value,
                controller: TextEditingController(text: updatedPrice),
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
              onPressed: () {
                if (updatedName.isNotEmpty && updatedPrice.isNotEmpty) {
                  final updatedFund = Fund(
                    id: fund.id,
                    name: updatedName.trim(),
                    price: updatedPrice,
                    stocks: fund.stocks,
                  );

                  _viewModel.updateFund(updatedFund:updatedFund,oldName: fund.name, callback: ({required bool isError, String? errorMessage}) {
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

                      Navigator.of(context).pop();
                    }
                  });

              }},
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                _viewModel.removeFund(fund);
                Navigator.of(context).pop();
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

}
