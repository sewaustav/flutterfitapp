enum ActivityLevel {
  low,
  light,
  moderate,
  high,
  veryHigh
}

enum Purpose {
  loss,
  maintain,
  gain
}

class Person {
  double weight;
  double height;
  int age;
  ActivityLevel activity;
  Purpose purpose;
  bool isMale;

  Person({
    required this.weight,
    required this.height,
    required this.age,
    required this.activity,
    required this.purpose,
    required this.isMale,
  });
}

class BrmCalculator {
  final Person person;

  BrmCalculator(this.person);

  double calculate() {
    double base = 10 * person.weight + 6.25 * person.height - 5 * person.age;
    base += person.isMale ? 5 : -161;

    double multiplier = switch (person.activity) {
      ActivityLevel.low => 1.2,
      ActivityLevel.light => 1.375,
      ActivityLevel.moderate => 1.55,
      ActivityLevel.high => 1.725,
      ActivityLevel.veryHigh => 1.9,
    };

    return base * multiplier;
  }
}

class NutrientCalculator {
  final Person person;
  final double totalCalories;

  NutrientCalculator(this.person, this.totalCalories);

  Map<String, double> calculate() {
    double proteinCoef = switch (person.purpose) {
      Purpose.loss => 2,
      Purpose.maintain => 2.2,
      Purpose.gain => 2.5,
    };
    double fatCoef = switch (person.purpose) {
      Purpose.loss => 0.9,
      Purpose.maintain => 1.1,
      Purpose.gain => 1.3
    };

    double protein = proteinCoef * person.weight;
    double fats = fatCoef * person.weight;
    double proteinCalories = protein * 4;
    double fatCalories = fats * 9;

    double carbsCalories = totalCalories - proteinCalories - fatCalories;
    double carbs = carbsCalories / 4;

    return {
      'protein': protein,
      'fats': fats,
      'carbohydrates': carbs
    };
  }
}