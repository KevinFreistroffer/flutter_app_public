import 'package:flutter/material.dart';

class Consumable {
  Consumable({
    Key key,
    @required this.id,
    @required this.category,
    @required this.name,
    @required this.servingSize,
    @required this.servingSizeString,
    @required this.servingSizeName,
    @required this.servingSizeMeasurementName,
    @required this.servingSizeMeasurement,
    @required this.calories,
    @required this.fat,
    @required this.fatMeasurement,
    @required this.protein,
    @required this.proteinMeasurement,
    @required this.carbs,
    @required this.carbsMeasurement,
    @required this.quantity,
    @required this.isExpanded,
  });
  final int id;
  final List<String> category;
  final String name;
  final double servingSize;
  final String servingSizeString;
  final String servingSizeName;
  final String servingSizeMeasurementName;
  final double servingSizeMeasurement;
  final double calories;
  final double fat;
  final String fatMeasurement;
  final double protein;
  final String proteinMeasurement;
  final double carbs;
  final String carbsMeasurement;
  final double quantity;
  final bool isExpanded;
}
