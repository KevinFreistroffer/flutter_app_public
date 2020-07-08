import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';

import '../../consumables_data.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/storage.service.dart';
import '../../services/consumables_storage.service.dart';
import '../../constants.dart';

class ListOfConsumables extends StatefulWidget {
  ListOfConsumables({Key key}) : super(key: key);

  @override
  _ListOfConsumablesState createState() => _ListOfConsumablesState();
}

class _ListOfConsumablesState extends State<ListOfConsumables> {
  double calories = 0.0;
  double fat = 0.0;
  double protein = 0.0;
  double carbs = 0.0;
  String servingSizeString = '1';
  int selected = -1;

  // test if consumables are mutatable
  // private store
  // .data.map(uuid).toBuildList()
  final _consumables = new BuiltList<Map<String, dynamic>>(
      new ConsumablesData().data.toBuiltList());
  // public store mutatable
  Iterable<Map<String, dynamic>> consumables =
      new ConsumablesData().data.map((consumable) => consumable);

  @override
  void initState() {
    super.initState();
  }

  void toggleExpansionTile(int id) {
    var foundConsumable = findConsumableById(id);
    consumables.forEach((consumableObj) {
      if (consumableObj['id'] != id) {
        consumableObj['isExpanded'] = false;
      }
    });

    foundConsumable['isExpanded'] = !foundConsumable['isExpanded'];
  }

  void handleServingSizeOnChange(int id, String newValue) {
    var foundConsumable = findConsumableById(id);
    // private found consumable;
    var _foundConsumable = findPrivateStoreConsumableById(id);
    double multiplierToCalculateNewValues = 0.0;

    switch (newValue) {
      case '1':
        multiplierToCalculateNewValues = 1.00;
        break;
      case '3/4':
        multiplierToCalculateNewValues = 0.75;
        break;
      case '1/2':
        multiplierToCalculateNewValues = 0.5;
        break;
      case '1/4':
        multiplierToCalculateNewValues = 0.25;
        break;
      case '1/8':
        multiplierToCalculateNewValues = .125;
        break;
      case '1/16':
        multiplierToCalculateNewValues = 0.0625;
        break;
      case '1/32':
        multiplierToCalculateNewValues = 0.03125;
        break;
      default:
        break;
    }

    foundConsumable["servingSizeString"] = newValue;
    foundConsumable['calories'] =
        (_foundConsumable['calories'] * multiplierToCalculateNewValues) *
            foundConsumable['quantity'];
    foundConsumable['fat'] =
        (_foundConsumable['fat'] * multiplierToCalculateNewValues) *
            foundConsumable['quantity'];
    foundConsumable['protein'] =
        (_foundConsumable['protein'] * multiplierToCalculateNewValues) *
            foundConsumable['quantity'];
    foundConsumable['carbs'] =
        (_foundConsumable['carbs'] * multiplierToCalculateNewValues) *
            foundConsumable['quantity'];

    var newConsumablesState = consumables.map((consumableObj) {
      if (consumableObj['id'] == id) {
        consumableObj = foundConsumable;
      }

      return consumableObj;
    }).toList();

    setState(() {
      consumables = newConsumablesState;
    });
  }

  Map<String, dynamic> findConsumableById(int id) {
    return consumables.firstWhere((consumableObj) {
      return consumableObj['id'] == id;
    });
  }

  Map<String, dynamic> findPrivateStoreConsumableById(int id) {
    return _consumables.firstWhere((consumableObj) {
      return consumableObj['id'] == id;
    });
  }

  void incrementQuantity(int id) {
    setState(() {
      consumables = consumables.map((consumable) {
        double multiplierToCalculateNewValues = 0.0;

        if (consumable['id'] == id) {
          switch (consumable['servingSizeString']) {
            case '1':
              multiplierToCalculateNewValues = 1.0;
              break;
            case '3/4':
              multiplierToCalculateNewValues = 0.75;
              break;
            case '1/2':
              multiplierToCalculateNewValues = 0.5;
              break;
            case '1/4':
              multiplierToCalculateNewValues = 0.25;
              break;
            case '1/8':
              multiplierToCalculateNewValues = .125;
              break;
            case '1/16':
              multiplierToCalculateNewValues = 0.0625;
              break;
            case '1/32':
              multiplierToCalculateNewValues = 0.03125;
              break;
            default:
              break;
          }

          consumable['quantity'] += 1;

          var _foundConsumable = findPrivateStoreConsumableById(id);

          consumable['calories'] =
              ((_foundConsumable['calories'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['fat'] =
              ((_foundConsumable['fat'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['protein'] =
              ((_foundConsumable['protein'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['carbs'] =
              ((_foundConsumable['carbs'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
        }

        return consumable;
      }).toList();
    });
  }

  void decrementQuantity(int id) {
    // find id value
    // multiply (_consumable['calories'] * found.servingSize) * found.quantity

    setState(() {
      consumables = consumables.map((consumable) {
        double multiplierToCalculateNewValues = 0.0;

        if (consumable['id'] == id) {
          switch (consumable['servingSizeString']) {
            case '1':
              multiplierToCalculateNewValues = 1.0;
              break;
            case '3/4':
              multiplierToCalculateNewValues = 0.75;
              break;
            case '1/2':
              multiplierToCalculateNewValues = 0.5;
              break;
            case '1/4':
              multiplierToCalculateNewValues = 0.25;
              break;
            case '1/8':
              multiplierToCalculateNewValues = .125;
              break;
            case '1/16':
              multiplierToCalculateNewValues = 0.0625;
              break;
            case '1/32':
              multiplierToCalculateNewValues = 0.03125;
              break;
            default:
              break;
          }

          consumable['quantity'] =
              consumable['quantity'] == 1 ? 1 : consumable['quantity'] - 1;

          var _foundConsumable = findPrivateStoreConsumableById(id);

          consumable['calories'] =
              ((_foundConsumable['calories'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['fat'] =
              ((_foundConsumable['fat'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['protein'] =
              ((_foundConsumable['protein'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
          consumable['carbs'] =
              ((_foundConsumable['carbs'] * multiplierToCalculateNewValues) *
                  consumable['quantity']);
        }

        return consumable;
      }).toList();
    });
  }

  void addToMeal(Map<String, dynamic> consumable) {
    Storage storage = new Storage();

    // add to storagea
    storage.setValues(consumable);
  }

  void addEntireMeal(String mealName) {
    switch (mealName) {
      case Constants.COFFEE:
        final Map<String, dynamic> mct = consumables
            .firstWhere((consumable) => consumable['name'] == 'MCT Oil');
        final Map<String, dynamic> butter = consumables
            .firstWhere((consumable) => consumable['name'] == 'Butter');

        setQuantityAndAddToMeal(mct, 1);
        setQuantityAndAddToMeal(butter, 1);

        break;
      case Constants.BREAKFAST:
        final Map<String, dynamic> egg = _consumables
            .firstWhere((consumable) => consumable['name'] == 'Egg');
        final Map<String, dynamic> bacon = _consumables
            .firstWhere((consumable) => consumable['name'] == 'Bacon');

        setQuantityAndAddToMeal(egg, 2);
        setQuantityAndAddToMeal(bacon, 1);

        break;
      default:
        break;
    }
  }

  void setQuantityAndAddToMeal(Map<String, dynamic> consumable, int quantity) {
    int consQuantity = consumable['quantity'].toInt();

    int numOfLoops = 0;
    if (consQuantity < quantity) {
      numOfLoops = quantity - consQuantity;

      for (var i = 0; i < numOfLoops; i++) {
        incrementQuantity(consumable['id']);
      }
    } else if (consQuantity > quantity) {
      numOfLoops = consQuantity - quantity;

      for (var i = 0; i < numOfLoops; i++) {
        decrementQuantity(consumable['id']);
      }
    }

    var updatedConsumable = consumables.firstWhere(
        (foundConsumable) => foundConsumable['id'] == consumable['id']);

    if (updatedConsumable['quantity'].toInt() == quantity) {
      addToMeal(updatedConsumable);
    }
  }

  Future<void> signOut() async {
    final StorageService _storage = StorageService();
    _storage.remove('email');
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    //final Size size = MediaQuery.of(context).size;
// Icon(
//                   Icons.account_circle,
//                   size: 40,
//                 ),
    return Scaffold(
      appBar: AppBar(
        title: Text('Foods & Drinks'),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: PopupMenuButton(
              onSelected: (result) {
                switch (result) {
                  case Constants.SIGN_OUT:
                    signOut();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: Constants.SIGN_OUT,
                  child: Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: consumables.length,
            itemBuilder: (BuildContext context, int index) {
              return ExpansionTile(
                key: GlobalKey(),
                initiallyExpanded: selected == index,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        consumables.toList()[index]['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                onExpansionChanged: (isExpanding) {
                  setState(() {
                    if (isExpanding) {
                      selected = index;
                    } else {
                      selected = -1;
                    }
                  });
                },
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // These are the column names
                            Container(
                              constraints: BoxConstraints(
                                minWidth: 80,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Calories: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Fat: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Protein: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Carbs: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // End of column names

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  (consumables.toList()[index]['calories'] *
                                          consumables.toList()[index]
                                              ['servingSize'])
                                      .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  (consumables.toList()[index]['fat'] *
                                          consumables.toList()[index]
                                              ['servingSize'])
                                      .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  (consumables.toList()[index]['protein'] *
                                          consumables.toList()[index]
                                              ['servingSize'])
                                      .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  (consumables.toList()[index]['carbs'] *
                                          consumables.toList()[index]
                                              ['servingSize'])
                                      .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              // Serving Size Row
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 100,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: Text(
                                            'Serving size: ',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          consumables
                                                  .toList()[index]
                                                      ['servingSize']
                                                  .toString() +
                                              consumables.toList()[index]
                                                  ['servingSizeName'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' (' +
                                              consumables
                                                  .toList()[index]
                                                      ['servingSizeMeasurement']
                                                  .toString() +
                                              consumables.toList()[index][
                                                  'servingSizeMeasurementName'] +
                                              ')',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // End of Serving Size Row

                              // Quantity Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              'Quantity: ',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                                consumables
                                                    .toList()[index]['quantity']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          decrementQuantity(consumables
                                              .toList()[index]['id']);
                                        },
                                        child: Icon(Icons.remove),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            right: 10, left: 10),
                                        child: Text('|'),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          incrementQuantity(consumables
                                              .toList()[index]['id']);
                                        },
                                        child: Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // End of Quantity Row

                              // Change Quantity Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    margin: EdgeInsets.only(right: 20),
                                    child: Text(
                                      'Change serving size',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: DropdownButton(
                                      value: consumables.toList()[index]
                                          ['servingSizeString'],
                                      onChanged: (
                                        dynamic newValue,
                                      ) {
                                        handleServingSizeOnChange(
                                          consumables.toList()[index]['id'],
                                          newValue,
                                        );
                                      },
                                      items: <String>[
                                        '1',
                                        '3/4',
                                        '1/2',
                                        '1/4',
                                        '1/8',
                                        '1/16',
                                        '1/32'
                                      ].map<DropdownMenuItem>(
                                        (String value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  RaisedButton(
                                    color: Colors.green,
                                    onPressed: () {
                                      addToMeal(consumables.toList()[index]);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        Text('Add to meal',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // End of Change Quantity Row
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: new BottomNavBar(),
    );
  }
}

// Serving Size: 1 Tbsp 14grams
// Quantity 1
// Serving Size: 15mL
