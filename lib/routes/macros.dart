import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/macro.dart';

class Macros extends StatelessWidget {
  const Macros({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;

    // final int calories = Macro.calories;
    // final int fat = Macro.fat;
    // final int protein = Macro.protein;
    // final int carbs = Macro.carbs;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Macros'),
      // ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.only(
                  top: 60,
                  right: 34,
                  bottom: 20,
                  left: 34,
                ),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 34),
                        child: Text(
                          'Macros',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Calories:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(Macro.calories.toString()),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Fat:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(Macro.fat.toString())
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Protein:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(Macro.protein.toString())
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Carbs:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(Macro.carbs.toString())
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        'Remaining',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: new BottomNavBar(),
    );
  }
}
