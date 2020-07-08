import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottom_nav_bar.dart';

class Totals extends StatefulWidget {
  Totals({Key key}) : super(key: key);

  @override
  _TotalsState createState() => _TotalsState();
}

class _TotalsState extends State<Totals> {
  double calories = 0.0;
  double fat = 0.0;
  double protein = 0.0;
  double carbs = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfStorageValuesExistOtherwiseSetDefaultValues();
  }

  checkIfStorageValuesExistOtherwiseSetDefaultValues() async {
    final perfs = await SharedPreferences.getInstance();

    setState(() {
      calories = perfs.getDouble('calories') ?? calories;
      fat = perfs.getDouble('fat') ?? fat;
      protein = perfs.getDouble('protein') ?? protein;
      carbs = perfs.getDouble('carbs') ?? carbs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Totals'),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return ListView(
            padding: EdgeInsets.only(
              top: 20,
              right: 20,
              bottom: 20,
              left: 20,
            ),
            children: <Widget>[
              Container(
                width: size.width,
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Calories:',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            calories.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width,
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Fat:',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text(
                            fat.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width,
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Protein:',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text(
                            protein.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width,
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Carbs:',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text(
                            carbs.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: new BottomNavBar(),
    );
  }
}
