import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Goal { 
  strength,
  weightLoss,
  endurance,
  muscle
}

enum Experience {
  beginner,
  intermediate,
  advanced
}

enum Equipment {
  home,
  gym,
  minimal
}

class WorkoutGenerator {
  // Baziniai pratimai pagal raumenų grupes
  static final Map<String, List<Map<String, dynamic>>> _exerciseDatabase = {
    'legs': [
      {'name': 'Pritūpimai', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Išpuolimai', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Rumuniškas atkėlimas', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Kojų spaudimas', 'equipment': [Equipment.gym]},
      {'name': 'Blauzdų kėlimas', 'equipment': [Equipment.gym]},
    ],
    'chest': [
      {'name': 'Atsispaudimai', 'equipment': [Equipment.home, Equipment.minimal]},
      {'name': 'Štanga gulint', 'equipment': [Equipment.gym]},
      {'name': 'Hanteliai gulint', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Skersinis traukimas', 'equipment': [Equipment.gym]},
    ],
    'back': [
      {'name': 'Prisitraukimai', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Irklavimas su štanga', 'equipment': [Equipment.gym]},
      {'name': 'Irklavimas su hanteliu', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Viršutinis traukimas', 'equipment': [Equipment.gym]},
    ],
    'shoulders': [
      {'name': 'Spaudimas virš galvos', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Žvaigždė su hanteliais', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Pečių traukimas į šonus', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Arnold press', 'equipment': [Equipment.gym, Equipment.home]},
    ],
    'arms': [
      {'name': 'Bicepso lenkimas', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Tricepso tiesimas', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Hammer curl', 'equipment': [Equipment.gym, Equipment.home]},
      {'name': 'Tricepso atsispaudimai', 'equipment': [Equipment.home, Equipment.minimal]},
    ],
    'core': [
      {'name': 'Planka', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Rusiškas sukinys', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Pilvo preso sutraukimas', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Kojų kėlimas kabant', 'equipment': [Equipment.gym]},
    ],
    'cardio': [
      {'name': 'Bėgimas', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
      {'name': 'Dviratis', 'equipment': [Equipment.gym]},
      {'name': 'Šokinėjimas per virvutę', 'equipment': [Equipment.home, Equipment.minimal]},
      {'name': 'HIIT', 'equipment': [Equipment.home, Equipment.gym, Equipment.minimal]},
    ],
  };

  // Sukurti treniruočių planą pagal vartotojo parametrus
  static List<Map<String, dynamic>> generateWorkoutPlan({
    required Goal goal,
    required Experience experience,
    required Equipment equipment,
    required int daysPerWeek,
  }) {
    List<Map<String, dynamic>> workoutPlan = [];
    
    // Nustatome treniruočių tipą pagal tikslą
    Map<String, dynamic> trainingParams = _getTrainingParameters(goal, experience);
    
    // Pritaikome treniruočių suskirstymą pagal dienų skaičių
    List<List<String>> splitDays = _getSplitDays(daysPerWeek);

    // Generuojame treniruotes kiekvienai dienai
    for (int dayIndex = 0; dayIndex < daysPerWeek; dayIndex++) {
      String dayName = _getWeekdayName(dayIndex);
      List<String> muscleGroups = splitDays[dayIndex];
      
      List<Map<String, dynamic>> exercises = [];
      
      // Pridedame pratimus kiekvienai raumenų grupei
      for (String muscleGroup in muscleGroups) {
        int exercisesPerMuscle = _getExercisesPerMuscle(goal, experience, muscleGroup);
        exercises.addAll(_selectExercisesForMuscleGroup(
          muscleGroup, 
          exercisesPerMuscle, 
          equipment
        ));
      }
      
      // Cardio pratimas, jei tikslas - svorio metimas ar ištvermė
      if (goal == Goal.weightLoss || goal == Goal.endurance) {
        exercises.add(_selectExercisesForMuscleGroup('cardio', 1, equipment)[0]);
      }
      
      workoutPlan.add({
        'day': dayName,
        'muscleGroups': muscleGroups,
        'exercises': exercises,
        'rest': trainingParams['rest'],
        'intensity': trainingParams['intensity'],
      });
    }
    
    return workoutPlan;
  }
  
  // Gauti treniruotės parametrus pagal tikslą
  static Map<String, dynamic> _getTrainingParameters(Goal goal, Experience experience) {
    switch (goal) {
      case Goal.strength:
        return {
          'sets': experience == Experience.beginner ? 3 : (experience == Experience.intermediate ? 4 : 5),
          'reps': [4, 6],
          'rest': '2-3 min',
          'intensity': 'Didelė',
          'tempo': 'Vidutinis-lėtas'
        };
      case Goal.muscle:
        return {
          'sets': experience == Experience.beginner ? 3 : (experience == Experience.intermediate ? 4 : 5),
          'reps': [8, 12],
          'rest': '1-2 min',
          'intensity': 'Vidutinė-didelė',
          'tempo': 'Vidutinis'
        };
      case Goal.weightLoss:
        return {
          'sets': 3,
          'reps': [12, 15],
          'rest': '30-60 s',
          'intensity': 'Vidutinė',
          'tempo': 'Greitas'
        };
      case Goal.endurance:
        return {
          'sets': 2,
          'reps': [15, 20],
          'rest': '30 s',
          'intensity': 'Žema-vidutinė',
          'tempo': 'Greitas'
        };
      default:
        return {
          'sets': 3,
          'reps': [8, 12],
          'rest': '1 min',
          'intensity': 'Vidutinė',
          'tempo': 'Vidutinis'
        };
    }
  }
  
  // Gauti treniruočių suskirstymą pagal dienų skaičių
  static List<List<String>> _getSplitDays(int daysPerWeek) {
    switch (daysPerWeek) {
      case 2:
        return [
          ['chest', 'back', 'shoulders'],
          ['legs', 'arms', 'core'],
        ];
      case 3:
        return [
          ['chest', 'shoulders', 'arms'],
          ['back', 'arms'],
          ['legs', 'core'],
        ];
      case 4:
        return [
          ['chest', 'arms'],
          ['back', 'arms'],
          ['legs'],
          ['shoulders', 'core'],
        ];
      case 5:
        return [
          ['chest'],
          ['back'],
          ['legs'],
          ['shoulders'],
          ['arms', 'core'],
        ];
      case 6:
        return [
          ['chest'],
          ['back'],
          ['legs'],
          ['shoulders'],
          ['arms'],
          ['core'],
        ];
      default: // 1 diena
        return [
          ['chest', 'back', 'legs', 'shoulders', 'arms', 'core'],
        ];
    }
  }
  
  // Išrinkti pratimus pagal raumenų grupę
  static List<Map<String, dynamic>> _selectExercisesForMuscleGroup(
    String muscleGroup,
    int count,
    Equipment equipment
  ) {
    List<Map<String, dynamic>> availableExercises = _exerciseDatabase[muscleGroup]!
        .where((exercise) =>
            (exercise['equipment'] as List<Equipment>).contains(equipment))
        .toList();

    // Konvertuojame enum laukus į String
    List<Map<String, dynamic>> converted = availableExercises.map((exercise) {
      return {
        ...exercise,
        'equipment': (exercise['equipment'] as List<Equipment>).map((e) => e.name).toList(),
      };
    }).toList();

    converted.shuffle();
    return converted.take(count).toList();
  }
  
  // Gauti pratimų skaičių pagal raumenų grupę
  static int _getExercisesPerMuscle(Goal goal, Experience experience, String muscleGroup) {
    // Pagrindinis skaičius priklauso nuo patirties
    int base = experience == Experience.beginner ? 1 : 
               experience == Experience.intermediate ? 2 : 3;
    
    // Koreguojame pagal tikslą
    if (goal == Goal.strength && (muscleGroup == 'legs' || muscleGroup == 'back')) {
      base += 1;
    } else if (goal == Goal.muscle && 
              (muscleGroup == 'chest' || muscleGroup == 'back' || muscleGroup == 'legs')) {
      base += 1;
    }
    
    // Limituojame maksimalų skaičių
    return base > 4 ? 4 : base;
  }
  
  // Gauti savaitės dienos pavadinimą
  static String _getWeekdayName(int index) {
    List<String> weekdays = ['Pirmadienis', 'Antradienis', 'Trečiadienis', 
                             'Ketvirtadienis', 'Penktadienis', 'Šeštadienis', 'Sekmadienis'];
    return weekdays[index % 7];
  }
  
  // Išsaugoti sugeneruotą planą Firestore duomenų bazėje
  static Future<String> saveWorkoutPlan(List<Map<String, dynamic>> workoutPlan) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Vartotojas neprisijungęs');
      }
      
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workout_plans')
          .add({
        'name': 'Asmeninis planas ${DateTime.now().toString().substring(0, 10)}',
        'createdAt': FieldValue.serverTimestamp(),
        'workoutDays': workoutPlan,
      });
      
      return docRef.id;
    } catch (e) {
      print('Klaida išsaugant treniruočių planą: $e');
      throw e;
    }
  }
} 