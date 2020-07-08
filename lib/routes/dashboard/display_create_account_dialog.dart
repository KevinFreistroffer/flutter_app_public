import 'package:flutter/material.dart';

// Future<dynamic> _displayCreateAccountDialog() {
//   final styles = Styles.alertDialog;

//   return showDialog(
//     barrierDismissible: true,
//     context: context,
//     builder: (context) {
//       final Size size = MediaQuery.of(context).size;
//       final AppTheme theme = Provider.of<AppTheme>(context);

//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         titlePadding: styles['titlePadding'],
//         buttonPadding: styles['buttonPadding'],
//         contentPadding: styles['contentPadding'],
//         backgroundColor: Colors.white,
//         title: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(10),
//             ),
//             color: theme.secondary,
//           ),
//           padding: EdgeInsets.fromLTRB(
//             size.width * .1,
//             size.width * .125,
//             size.width * .1,
//             size.width * .125,
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: Text(
//             'Would you like to create an account to save your progress?',
//             style: TextStyle(
//               fontSize: 22,
//               height: 1.4,
//               fontWeight: FontWeight.w100,
//             ),
//           ),
//         ),
//         actions: <Widget>[
//           GestureDetector(
//             child: Text(
//               'Yes',
//               style: TextStyle(fontSize: 20),
//             ),
//             onTap: () async {
//               await wait(ms: 800);
//               await _pageController.nextPage(
//                 duration: Duration(milliseconds: 215),
//                 curve: Curves.easeIn,
//               );
//               Navigator.of(context).pop();
//             },
//           ),
//           GestureDetector(
//             child: Text(
//               'No',
//               style: TextStyle(fontSize: 20),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//               // hide the main content?
//               // display the nickname page?
//             },
//           )
//         ],
//       );
//     },
//   );
// }
