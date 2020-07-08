import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  double calories = 0.0;
  double fat = 0.0;
  double protein = 0.0;
  double carbs = 0.0;

  void getValues() async {
    final prefs = await SharedPreferences.getInstance();

    calories = prefs.getDouble('calories') ?? calories;
    fat = prefs.getDouble('fat') ?? fat;
    protein = prefs.getDouble('protein') ?? protein;
    carbs = prefs.getDouble('carbs') ?? carbs;
  }

  void setValues(Map<String, dynamic> consumable) async {
    getValues();

    final prefs = await SharedPreferences.getInstance();

    calories += consumable['calories'];
    fat += consumable['fat'];
    protein += consumable['protein'];
    carbs += consumable['carbs'];

    // save in localStorage
    prefs.setDouble('calories', calories);
    prefs.setDouble('fat', fat);
    prefs.setDouble('protein', protein);
    prefs.setDouble('carbs', carbs);
  }

  void reset() async {
    final prefs = await SharedPreferences.getInstance();

    calories = 0;
    fat = 0;
    protein = 0;
    carbs = 0;

    prefs.remove('calories');
    prefs.remove('fat');
    prefs.remove('protein');
    prefs.remove('carbs');
  }
}
