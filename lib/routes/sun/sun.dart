import 'package:flutter/material.dart';

class Sun extends StatefulWidget {
  Sun({Key key}) : super(key: key);

  @override
  _SunState createState() => _SunState();
}

class _SunState extends State<Sun> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: null,
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Container(
            height: size.height,
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * 0.125, 0, size.width * 0.125, 0),
            color: Color.fromRGBO(253, 247, 227, 1),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: size.height *
                        (orientation == Orientation.landscape ? 0.125 : 0.25),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            'Hi',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * .06),
                  Text(
                    'Start Application',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: size.height * .03),
                  Container(
                      width: size.width,
                      constraints: BoxConstraints(
                        maxWidth: 200,
                      ),
                      child: RaisedButton(
                        padding: EdgeInsets.all(15),
                        color: Color.fromRGBO(0, 43, 54, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text(
                          'RUN',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/list',
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
            title: Text('Account'), icon: Icon(Icons.account_box)),
        BottomNavigationBarItem(
            title: Text('Account'), icon: Icon(Icons.account_box)),
      ]),
    );
  }
}
