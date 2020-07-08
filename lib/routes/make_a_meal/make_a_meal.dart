import 'package:flutter/material.dart';

class MakeAMeal extends StatelessWidget {
  const MakeAMeal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a meal'),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientaiton) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Make a Meal'),
              ],
            ),
          );
        },
      ),
    );
  }
}
