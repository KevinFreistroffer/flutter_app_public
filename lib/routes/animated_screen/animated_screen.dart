import 'package:flutter/material.dart';
import '../../wait.dart';

class AnimatedScreen extends StatefulWidget {
  @override
  _AnimatedScreentState createState() => _AnimatedScreentState();
}

class _AnimatedScreentState extends State<AnimatedScreen> {
  bool _showWelcomeAnimation = false;
  bool _showCreateAccountAnimation = false;

  @override
  initState() {
    super.initState();
    _animateWelcome();
  }

  Future<void> _animateWelcome() async {
    await wait(ms: 100);
    setState(() => _showWelcomeAnimation = true);
    await wait(ms: 1800);
    setState(() => _showCreateAccountAnimation = true);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).primaryColor,
            ],
            stops: [0.2, 0.5, 0.7, 1],
            center: Alignment(0, 0),
            focal: Alignment(-0.1, 0.6),
            focalRadius: 2,
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, 60, 20, 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _showWelcomeAnimation ? 1.0 : 0,
              child: Container(
                decoration: BoxDecoration(
                  //color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  'Hello.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 75,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * .005),
            Container(
              width: size.width,
              height: 2,
              color: Colors.white.withOpacity(0.2),
            ),
            SizedBox(height: size.height * .005),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _showCreateAccountAnimation ? 1.0 : 0,
              child: Container(
                width: size.width * .80,
                padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                child: Column(children: <Widget>[
                  Text(
                    'Would you like to create a free account to save your progress?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'YES',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/dashboard', (route) => false);
                        },
                      ),
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'NO',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
