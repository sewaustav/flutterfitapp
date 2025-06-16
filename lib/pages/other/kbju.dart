import 'dart:math';

// --- Константы и перечисления ---

// Пол человека
enum Gender { male, female }

// Уровень активности
enum ActivityLevel {
  sedentary, // Сидячий образ жизни (мало или нет физической активности)
  lightlyActive, // Легкая активность (1-3 дня в неделю легких упражнений)
  moderatelyActive, // Умеренная активность (3-5 дней в неделю умеренных упражнений)
  veryActive, // Высокая активность (6-7 дней в неделю интенсивных упражнений)
  superActive // Очень высокая активность (ежедневные очень интенсивные упражнения или физическая работа)
}

// Цель пользователя
enum Goal {
  maintain, // Поддержание веса
  mildWeightLoss, // Мягкое снижение веса (около 0.25 кг в неделю)
  moderateWeightLoss, // Умеренное снижение веса (около 0.5 кг в неделю)
  extremeWeightLoss, // Экстремальное снижение веса (около 1 кг в неделю)
  mildWeightGain, // Мягкий набор веса (около 0.25 кг в неделю)
  moderateWeightGain, // Умеренный набор веса (около 0.5 кг в неделю)
}

// --- Расширения для удобства ---

extension ActivityLevelExtension on ActivityLevel {
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.superActive:
        return 1.9;
    }
  }
}

extension GoalExtension on Goal {
  double get calorieAdjustment {
    switch (this) {
      case Goal.maintain:
        return 0;
      case Goal.mildWeightLoss:
        return -250;
      case Goal.moderateWeightLoss:
        return -500;
      case Goal.extremeWeightLoss:
        return -1000;
      case Goal.mildWeightGain:
        return 250;
      case Goal.moderateWeightGain:
        return 500;
    }
  }
}

// --- Класс для результатов КБЖУ ---

class MacroNutrientGoals {
  final double calories;
  final double proteinGrams;
  final double fatGrams;
  final double carbGrams;

  MacroNutrientGoals({
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
  });
}

// --- Основная логика расчета (функции) ---

/// Расчет базального метаболизма (BMR) по формуле Миффлина-Сан-Жеора.
double calculateBMR({
  required Gender gender,
  required double weightKg,
  required double heightCm,
  required int ageYears,
}) {
  if (gender == Gender.male) {
    return (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) + 5;
  } else {
    return (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) - 161;
  }
}

/// Расчет общего дневного расхода энергии (TDEE).
double calculateTDEE({
  required double bmr,
  required ActivityLevel activityLevel,
}) {
  return bmr * activityLevel.multiplier;
}

/// Основная функция для расчета КБЖУ.
/// Возвращает объект MacroNutrientGoals с рассчитанными значениями.
MacroNutrientGoals calculateMacros({
  required Gender gender,
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required ActivityLevel activityLevel,
  required Goal goal,
  double proteinPercentage = 0.25, // % калорий из белка (рекомендуется 25-35%)
  double fatPercentage = 0.25, // % калорий из жира (рекомендуется 20-30%)
}) {
  // Проверка на допустимые значения процентов
  if (proteinPercentage + fatPercentage >= 1.0) {
    throw ArgumentError('Сумма процентов белка и жира должна быть меньше 1.0');
  }
  if (proteinPercentage < 0 || fatPercentage < 0) {
    throw ArgumentError('Проценты белка и жира не могут быть отрицательными');
  }

  double bmr = calculateBMR(
    gender: gender,
    weightKg: weightKg,
    heightCm: heightCm,
    ageYears: ageYears,
  );

  double tdee = calculateTDEE(
    bmr: bmr,
    activityLevel: activityLevel,
  );

  double targetCalories = tdee + goal.calorieAdjustment;

  // Гарантируем минимальное количество калорий для безопасности
  if (targetCalories < 1200 && gender == Gender.female) {
    targetCalories = 1200;
    print('Внимание: Расчетные калории ниже 1200 ккал. Установлено на 1200 ккал для вашей безопасности.');
  }
  if (targetCalories < 1500 && gender == Gender.male) {
    targetCalories = 1500;
    print('Внимание: Расчетные калории ниже 1500 ккал. Установлено на 1500 ккал для вашей безопасности.');
  }

  // Расчет белков (4 ккал на 1 грамм)
  double proteinCalories = targetCalories * proteinPercentage;
  double proteinGrams = proteinCalories / 4;

  // Расчет жиров (9 ккал на 1 грамм)
  double fatCalories = targetCalories * fatPercentage;
  double fatGrams = fatCalories / 9;

  // Расчет углеводов (4 ккал на 1 грамм)
  double carbCalories = targetCalories - proteinCalories - fatCalories;
  double carbGrams = carbCalories / 4;

  return MacroNutrientGoals(
    calories: targetCalories,
    proteinGrams: proteinGrams,
    fatGrams: fatGrams,
    carbGrams: carbGrams,
  );
}