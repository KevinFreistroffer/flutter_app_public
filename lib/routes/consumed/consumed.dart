import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';

class Consumed extends StatelessWidget {
  const Consumed({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumed so far'),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientaiton) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Consumed so far'),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: new BottomNavBar(),
    );
  }
}
