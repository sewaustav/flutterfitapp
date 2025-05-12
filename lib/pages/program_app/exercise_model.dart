import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 0)
class Exercise {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String muscleGroup;

  @HiveField(2)
  final String? secondGroup;

  @HiveField(3)
  final String? thirdGroup;

  @HiveField(4)
  final int? rating;

  @HiveField(5)
  final String? img;

  @HiveField(6)
  final int? id;

  Exercise({
    required this.name,
    required this.muscleGroup,
    this.secondGroup,
    this.thirdGroup,
    this.rating,
    this.img,
    this.id
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      muscleGroup: json['muscle_group'],
      secondGroup: json['second_group'],
      thirdGroup: json['third_group'],
      rating: json['rating'],
      img: json['img'],
      id: json['id']
    );
  }
}