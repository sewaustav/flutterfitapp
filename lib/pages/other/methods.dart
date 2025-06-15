import 'dart:math';

class Calc {
  num calcBenchPress(num weight, num reps) {
    final epley = weight * (1 + reps / 30);
    final brzycki = weight * (36 / (37 - reps));
    final lander = weight * 100 / (101.3 - 2.67123 * reps);
    final lombardi = weight * (pow(reps, 0.10));
    final mayhew = (100 * weight) / (52.2 + 41.9 * exp(-0.055 * reps));
    final oconner = weight * (1 + 0.025 * reps);
    final wathan = (100 * weight) / (48.8 + 53.8 * exp(-0.075 * reps));

    final result = (epley + brzycki + lander + lombardi + mayhew + oconner + wathan) / 7;
    return result;
  }

  num calcEpley(num weight, num reps) {
    final result = (weight*reps)/30 + weight;
    return result;
  }

}

class Weight {
  double lbsToKg(double lbs) {
    return lbs * 0.45359237;
  }

  double kgToLbs(double kg) {
    return kg / 0.45359237;
  }

}
