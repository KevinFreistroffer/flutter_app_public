import 'package:flutter/material.dart';
import '../models/consumable.dart';

class MealService {
  var meal;

  void addToConsumed(Consumable consumable) async {
    // So 2 objects
    // Totals of fat calories etc.

    // Consumables of consumables
    // if ID doesn't exist, or does exist though servingSize is not the same
    // - add to [] and calculate();
    // if ID does exist and servingSize is the same
    // - find consumable.findWhere id == id, and increment quantity and calculate();

    //  - check if consumed storage exists
    //    - if not create the []
    //    - else
    //    - if consumable[id] does not exist in consumed
    //      - add it
    //    - else
    //      - find consumable.findWhere id == id
    //        - if servingSize is not the same
    //          - add it
    //        - else
    //          - increment quantity
    //  calculate();
  }

  void calculate() {
    // - create private object to store values;

    // - get consumed[]
    // - if length > 0
    //   - loop through each and calculate totals
    //   - storage set value totals with maybe extra properties like total items
  }
}
