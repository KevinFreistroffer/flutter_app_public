import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_keto/actions/position_actions.dart';
import 'package:flutter_keto/actions/times_actions.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../constants.dart';
import '../../../theme.dart';
import '../../../services/position_service.dart';
import '../../../services/times_service.dart';
import '../../../models/times_model.dart';
import '../../../state/app_state.dart';
import '../../../state/position_state.dart';
import '../../../state/times_state.dart';
import 'package:flutter_keto/store.dart';

/**
 * Import the class or service to get the latitude and longitude
 */

class BottomLayer extends CustomPainter {
  final BuildContext context;
  final Orientation orientation;
  AppTheme theme;
  Size mqSize;
  BottomLayer(this.context, this.orientation) {
    theme = Provider.of(context, listen: false);
  }
  @override
  void paint(Canvas canvas, Size size) {
    mqSize = MediaQuery.of(context).size;
    // if orientation is landscape than mqSize.width * .4, height
    double width = orientation == Orientation.portrait
        ? mqSize.width * .7
        : mqSize.width * .5;
    double height = orientation == Orientation.portrait
        ? mqSize.height * .5
        : mqSize.height * .75;
    final rect = Offset(-width / 2, 0) & Size(width, height);
    final startAngle = math.pi;
    final sweepAngle = math.pi;
    final useCenter = false;
    final paint = Paint()
      ..color = theme.secondary.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TopLayer extends CustomPainter {
  final BuildContext context;
  final Orientation orientation;
  AppTheme theme;
  Size mqSize;
  TopLayer(this.context, this.orientation) {
    theme = Provider.of(context, listen: false);
  }
  @override
  void paint(Canvas canvas, Size size) {
    mqSize = MediaQuery.of(context).size;
    // if orientation is landscape than mqSize.width * .4, height
    double width = orientation == Orientation.portrait
        ? mqSize.width * .7
        : mqSize.width * .5;
    double height = orientation == Orientation.portrait
        ? mqSize.height * .5
        : mqSize.height * .75;
    final rect = Offset(-width / 2, 0) & Size(width, height);
    final startAngle = math.pi;
    final sweepAngle = math.pi * .2;
    final useCenter = false;
    final paint = Paint()
      ..color = theme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Tracking extends StatefulWidget {
  final String status;
  final TabController controller;
  final Orientation orientation;
  Tracking({
    Key key,
    this.controller,
    this.status,
    this.orientation,
  }) : super(key: key);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  PositionService _positionService = PositionService();
  TimesService _timesService = TimesService();

  @override
  void initState() {
    super.initState();
    _positionService.getCurrentPosition().then((Position position) async {
      print('getCurrentPosition position $position');
      store.dispatch(
        SetCoordinatesAction(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      final times = await _timesService.getSunriseAndSunset(
        position.latitude,
        position.longitude,
      );

      if (times.success) {
        store.dispatch(
          SetTimesAction(
            sunrise: times.data.sunrise,
            sunset: times.data.sunset,
            dayLength: times.data.dayLength,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of(context, listen: false);

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      widget.status,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 215),
                opacity: widget.status == Constants.SSH_DISCONNECTED ||
                        widget.status == Constants.SSH_CONNECTING
                    ? 0.5
                    : 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: widget.orientation == Orientation.portrait
                          ? 125
                          : 150,
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: size.width,
                            height: size.width * .75,
                            child: Stack(
                              overflow: Overflow.visible,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Positioned(
                                  top: -size.height * .15,
                                  child: CustomPaint(
                                    painter: BottomLayer(
                                      context,
                                      widget.orientation,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -size.height * .15,
                                  child: CustomPaint(
                                    painter: TopLayer(
                                      context,
                                      widget.orientation,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: size.width * .1,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      bottom: widget.orientation ==
                                              Orientation.portrait
                                          ? 0
                                          : size.height * .05,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          '20°',
                                          /**
                                                               * And this is the degree or the pan angle. at sunrise on the summer
                                                               * // soltice, the angle is either -90, 0, or 180.
                                                               * 0 
                                                               */
                                          style: TextStyle(
                                            fontSize: 50,
                                            color: theme.onBackground
                                                .withOpacity(0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: widget.orientation ==
                                          Orientation.landscape
                                      ? 100
                                      : 0,
                                  child: Container(
                                    width: 150,
                                    //color: Colors.red,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              state.positionState.latitude ==
                                                          null &&
                                                      state.positionState
                                                              .longitude ==
                                                          null
                                                  ? MainAxisAlignment.center
                                                  : MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: state.positionState
                                                              .latitude ==
                                                          null &&
                                                      state.positionState
                                                              .longitude ==
                                                          null
                                                  ? null
                                                  : 80,
                                              child: Text(
                                                'Latitude',
                                                style: TextStyle(
                                                    color: theme.onBackground
                                                        .withOpacity(0.5)),
                                              ),
                                            ),
                                            Text(
                                              // coords.latitude
                                              //         .toStringAsFixed(3) ??
                                              'N/A',
                                              style: TextStyle(
                                                color: theme.onBackground
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: state.positionState
                                                              .latitude ==
                                                          null &&
                                                      state.positionState
                                                              .longitude ==
                                                          null
                                                  ? null
                                                  : 80,
                                              child: Text(
                                                'Longitude: ',
                                                style: TextStyle(
                                                    color: theme.onBackground
                                                        .withOpacity(0.5)),
                                              ),
                                            ),
                                            Text(
                                              // coords.longitude
                                              //         .toStringAsFixed(3) ??
                                              'N/A',
                                              style: TextStyle(
                                                color: theme.onBackground
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   child: Container(
                                //     width: 200,
                                //     constraints:
                                //         BoxConstraints(
                                //             maxWidth:
                                //                 size.width *
                                //                     .6),
                                //     child: Row(
                                //       children: <Widget>[
                                //         Expanded(
                                //           child: Container(
                                //             padding:
                                //                 EdgeInsets
                                //                     .all(
                                //                         10),
                                //             child:
                                //                 RaisedButton(
                                //               onPressed:
                                //                   () {
                                //                 if (status ==
                                //                     Constants
                                //                         .CONNECTING) {
                                //                   return null;
                                //                 } else if (status ==
                                //                     Constants
                                //                         .DISCONNECTED) {
                                //                   _sshToRaspberryPi();
                                //                 } else {
                                //                   _disconnectClient();
                                //                 }
                                //                 // so pretty much display Getting location

                                //                 // Connecting ..............
                                //                 // Connected.
                                //                 // Getting location .............
                                //                 // "Could not connect to the server.
                                //                 // Try turning off and turning on the Raspberry Pi or the Wifi Network."
                                //               },
                                //               child: Text(
                                //                 _connectButtonText,
                                //                 style:
                                //                     TextStyle(
                                //                   color: theme
                                //                       .onBackground,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0),
                    Container(
                      //color: Colors.yellow,
                      width: widget.orientation == Orientation.portrait
                          ? size.width * .78
                          : size.width * .55,
                      //height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Feather.sunrise,
                                      size: 30,
                                      color: theme.secondary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '7:32am',
                                      style: TextStyle(
                                        color: theme.onBackground,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Feather.sunset,
                                      size: 30,
                                      color: theme.secondary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '7:45pm',
                                      style: TextStyle(
                                        color: theme.onBackground,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
