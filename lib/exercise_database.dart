import 'workout_generator.dart';

class ExerciseDatabase {
  // Detalesnė pratimų duomenų bazė su aprašymais
  static final Map<String, List<Map<String, dynamic>>> exercises = {
    'legs': [
      {
        'name': 'Pritūpimai',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Stovėkite pėdomis pečių plotyje, nuleiskite klubus tiesiai žemyn, išlaikydami nugarą tiesia. Keliai neturi išeiti už pirštų linijos.',
        'example': 'https://www.youtube.com/watch?v=ultWZbUMPL8',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['quadriceps', 'glutes', 'hamstrings'],
      },
      {
        'name': 'Išpuolimai',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Ženkite vieną žingsnį pirmyn ir lenkite abi kojas, kol priekinės kojos šlaunis bus lygiagreti grindims. Užpakalinės kojos kelis beveik liečia grindis.',
        'example': 'https://www.youtube.com/watch?v=QOVaHwm-Q6U',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['quadriceps', 'glutes', 'hamstrings'],
      },
      {
        'name': 'Rumuniškas atkėlimas',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovėkite tiesiai, laikydami svorį prieš save. Lenkitės klubuose, nuleisdami svorį žemyn, išlaikydami nugarą tiesia. Keliai šiek tiek sulenkti.',
        'example': 'https://www.youtube.com/watch?v=hCDzSR6bW10',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['hamstrings', 'lower_back', 'glutes'],
      },
      {
        'name': 'Kojų spaudimas',
        'equipment': [Equipment.gym],
        'description': 'Sėdėdami aparate, spauskite platformą kojomis, ištiesdami kelius, bet neužrakindami jų.',
        'example': 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['quadriceps', 'glutes', 'hamstrings'],
      },
      {
        'name': 'Blauzdų kėlimas',
        'equipment': [Equipment.gym],
        'description': 'Stovėdami arba sėdėdami, pakelkite kulnus aukštyn, įtempdami blauzdos raumenis, tada nuleiskite žemyn.',
        'example': 'https://www.youtube.com/watch?v=gwLzBJYoWlI',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['calves'],
      },
      {
        'name': 'Kojų tiesimas',
        'equipment': [Equipment.gym],
        'description': 'Sėdėdami aparate, tieskite kojas priešais save, keldami svorį.',
        'example': 'https://www.youtube.com/watch?v=YyvSfVjQeL0',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['quadriceps'],
      },
      {
        'name': 'Kojų lenkimas',
        'equipment': [Equipment.gym],
        'description': 'Gulėdami arba sėdėdami aparate, lenkite kojas, traukdami svorį link savęs.',
        'example': 'https://www.youtube.com/watch?v=1Tq3QdYUuHs',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['hamstrings'],
      },
    ],
    'chest': [
      {
        'name': 'Atsispaudimai',
        'equipment': [Equipment.home, Equipment.minimal],
        'description': 'Remkitės rankomis į grindis pečių plotyje, nuleiskite kūną, lenkdami alkūnes, tada atsistumkite aukštyn.',
        'example': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['chest', 'triceps', 'shoulders'],
      },
      {
        'name': 'Štanga gulint',
        'equipment': [Equipment.gym],
        'description': 'Gulėdami ant suoliuko, nuleiskite štangą link krūtinės, tada spauskite aukštyn, neužrakindami alkūnių.',
        'example': 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['chest', 'triceps', 'shoulders'],
      },
      {
        'name': 'Hanteliai gulint',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Gulėdami ant suoliuko, nuleiskite hantelius į šonus, tada spauskite aukštyn, neužrakindami alkūnių.',
        'example': 'https://www.youtube.com/watch?v=SHsUIZiNdeY',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['chest', 'triceps', 'shoulders'],
      },
      {
        'name': 'Skersinis traukimas',
        'equipment': [Equipment.gym],
        'description': 'Stovėdami tarp blokelių, traukite rankenas priešais save, išlaikydami rankas šiek tiek sulenktas.',
        'example': 'https://www.youtube.com/watch?v=Iwe6AmxVf7o',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['chest', 'shoulders'],
      },
      {
        'name': 'Štanga įstrižai',
        'equipment': [Equipment.gym],
        'description': 'Gulėdami ant įstrižo suoliuko, spauskite štangą nuo krūtinės aukštyn.',
        'example': 'https://www.youtube.com/watch?v=jPLdzuHckI8',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['upper_chest', 'triceps', 'shoulders'],
      },
    ],
    'back': [
      {
        'name': 'Prisitraukimai',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Kabėdami ant skersinio, traukite save aukštyn, kol smakras bus virš skersinio, tada lėtai nusileiskite.',
        'example': 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['lats', 'biceps', 'shoulders'],
      },
      {
        'name': 'Irklavimas su štanga',
        'equipment': [Equipment.gym],
        'description': 'Pasilenkę į priekį, traukite štangą link pilvo, išlaikydami nugarą tiesia.',
        'example': 'https://www.youtube.com/watch?v=kBWAon7ItDw',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['middle_back', 'lats', 'biceps'],
      },
      {
        'name': 'Irklavimas su hanteliu',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Viena ranka ir keliu remkitės į suoliuką, kita ranka traukite hantelį link šono.',
        'example': 'https://www.youtube.com/watch?v=pYcpY20QaE8',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['middle_back', 'lats', 'biceps'],
      },
      {
        'name': 'Viršutinis traukimas',
        'equipment': [Equipment.gym],
        'description': 'Sėdėdami prie viršutinio traukimo aparato, traukite rankeną žemyn link krūtinės.',
        'example': 'https://www.youtube.com/watch?v=CAwf7n6Luuc',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['lats', 'biceps', 'shoulders'],
      },
      {
        'name': 'Žemo traukimo irklavimas',
        'equipment': [Equipment.gym],
        'description': 'Sėdėdami prie žemo traukimo aparato, traukite rankeną link pilvo.',
        'example': 'https://www.youtube.com/watch?v=xQNrFHEMhI4',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['middle_back', 'lats', 'biceps'],
      },
    ],
    'shoulders': [
      {
        'name': 'Spaudimas virš galvos',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovint arba sėdint, spauskite svorį nuo pečių lygio virš galvos.',
        'example': 'https://www.youtube.com/watch?v=_RlRDWO2jfg',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['shoulders', 'triceps'],
      },
      {
        'name': 'Žvaigždė su hanteliais',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovėdami, kelkite hantelius į šonus, kol rankos bus lygiagrečios su grindimis.',
        'example': 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['lateral_deltoids'],
      },
      {
        'name': 'Pečių traukimas į šonus',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovėdami, kelkite rankas priešais save, kol jos bus lygiagrečios su grindimis.',
        'example': 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['front_deltoids'],
      },
      {
        'name': 'Arnold press',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Sėdėdami, pradėkite su hanteliais prie krūtinės, delnai į save, sukite rankas ir spauskite virš galvos.',
        'example': 'https://www.youtube.com/watch?v=6Z15_WdXmVw',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['shoulders', 'triceps'],
      },
      {
        'name': 'Užpakalinių pečių kėlimas',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Pasilenkę į priekį, kelkite hantelius į šonus, siekdami užpakalinių pečių raumenų.',
        'example': 'https://www.youtube.com/watch?v=0GSu6Z-Oj7U',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['rear_deltoids', 'traps'],
      },
    ],
    'arms': [
      {
        'name': 'Bicepso lenkimas',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovėdami, lenkite rankas per alkūnes, keldami svorį prie pečių, tada lėtai nuleiskite.',
        'example': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['biceps'],
      },
      {
        'name': 'Tricepso tiesimas',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Laikydami svorį virš galvos, nuleiskite jį už galvos, lenkdami alkūnes, tada tieskite rankas.',
        'example': 'https://www.youtube.com/watch?v=_gsUck-7M74',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['triceps'],
      },
      {
        'name': 'Hammer curl',
        'equipment': [Equipment.gym, Equipment.home],
        'description': 'Stovėdami, lenkite rankas per alkūnes, laikydami hantelius plaktuko pozicijoje.',
        'example': 'https://www.youtube.com/watch?v=zC3nLlEvin4',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['biceps', 'forearms'],
      },
      {
        'name': 'Tricepso atsispaudimai',
        'equipment': [Equipment.home, Equipment.minimal],
        'description': 'Remkitės rankomis už nugaros į kėdę ar suoliuką, nuleiskite kūną lenkdami alkūnes, tada ištieskite.',
        'example': 'https://www.youtube.com/watch?v=0326dy_-CzM',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['triceps'],
      },
      {
        'name': 'Preacher curl',
        'equipment': [Equipment.gym],
        'description': 'Sėdėdami ant suoliuko, padėję rankas ant nuožulnaus paviršiaus, lenkite alkūnes keldami svorį.',
        'example': 'https://www.youtube.com/watch?v=fIWP-FRFNU0',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['biceps'],
      },
    ],
    'core': [
      {
        'name': 'Planka',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Remkitės ant alkūnių ir pirštų galiukų, išlaikydami kūną tiesioje linijoje nuo galvos iki kulnų.',
        'example': 'https://www.youtube.com/watch?v=ASdvN_XEl_c',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['abs', 'lower_back'],
      },
      {
        'name': 'Rusiškas sukinys',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Sėdėdami ant grindų, kelkite kojas, sukite viršutinę kūno dalį iš vienos pusės į kitą.',
        'example': 'https://www.youtube.com/watch?v=JyUqwkVpsi8',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['obliques', 'abs'],
      },
      {
        'name': 'Pilvo preso sutraukimas',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Gulėdami ant nugaros, lenkite viršutinę kūno dalį, keldami pečius nuo grindų.',
        'example': 'https://www.youtube.com/watch?v=Xyd_fa5zoEU',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['abs'],
      },
      {
        'name': 'Kojų kėlimas kabant',
        'equipment': [Equipment.gym],
        'description': 'Kabėdami ant skersinio, kelkite ištiesias kojas link krūtinės.',
        'example': 'https://www.youtube.com/watch?v=Pr1ieGZ5atk',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['lower_abs', 'hip_flexors'],
      },
      {
        'name': 'Atbulinė planka',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Remkitės rankomis už nugaros, keldami klubus, kad kūnas būtų tiesioje linijoje nuo pečių iki kulnų.',
        'example': 'https://www.youtube.com/watch?v=ZNAxdJ6Bt00',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['lower_back', 'abs', 'shoulders'],
      },
    ],
    'cardio': [
      {
        'name': 'Bėgimas',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Bėgimas nustatytu tempu ir laiku, lauke arba ant takelio.',
        'example': 'https://www.youtube.com/watch?v=_kGESn8ArrU',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['legs', 'heart'],
      },
      {
        'name': 'Dviratis',
        'equipment': [Equipment.gym],
        'description': 'Mynimas stacionariu dviračiu ar dviračio ergometru, keičiant intensyvumą.',
        'example': 'https://www.youtube.com/watch?v=fCVpHQrUFIM',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['legs', 'heart'],
      },
      {
        'name': 'Šokinėjimas per virvutę',
        'equipment': [Equipment.home, Equipment.minimal],
        'description': 'Šokinėjimas per virvutę nustatytu laiku ar kartais.',
        'example': 'https://www.youtube.com/watch?v=FJmRQ5iTXKE',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['calves', 'heart', 'shoulders'],
      },
      {
        'name': 'HIIT',
        'equipment': [Equipment.home, Equipment.gym, Equipment.minimal],
        'description': 'Aukšto intensyvumo intervalinė treniruotė, keičiant intensyvias pratimų serijas ir poilsio periodus.',
        'example': 'https://www.youtube.com/watch?v=ml6cT4AZdqI',
        'level': [Experience.intermediate, Experience.advanced],
        'muscles': ['full_body', 'heart'],
      },
      {
        'name': 'Elipsinis treniruoklis',
        'equipment': [Equipment.gym],
        'description': 'Treniruotė ant elipsinio treniruoklio, keičiant pasipriešinimą ir intensyvumą.',
        'example': 'https://www.youtube.com/watch?v=xLa_G7qVF5U',
        'level': [Experience.beginner, Experience.intermediate, Experience.advanced],
        'muscles': ['legs', 'heart', 'arms'],
      },
    ],
  };
  
  // Gauti visus pratimus pagal pasirinktą įrangą
  static List<Map<String, dynamic>> getExercisesByEquipment(Equipment equipment) {
    List<Map<String, dynamic>> result = [];
    
    exercises.forEach((muscleGroup, exerciseList) {
      for (var exercise in exerciseList) {
        if ((exercise['equipment'] as List<Equipment>).contains(equipment)) {
          result.add({...exercise, 'muscleGroup': muscleGroup});
        }
      }
    });
    
    return result;
  }
  
  // Gauti pratimus pagal raumenų grupę
  static List<Map<String, dynamic>> getExercisesByMuscleGroup(String muscleGroup, {Equipment? equipment}) {
    if (!exercises.containsKey(muscleGroup)) {
      return [];
    }
    
    List<Map<String, dynamic>> result = [...exercises[muscleGroup]!];
    
    if (equipment != null) {
      result = result.where((exercise) => 
        (exercise['equipment'] as List<Equipment>).contains(equipment)
      ).toList();
    }
    
    return result;
  }
  
  // Gauti visus pratimus pagal patirtį
  static List<Map<String, dynamic>> getExercisesByExperience(Experience experience) {
    List<Map<String, dynamic>> result = [];
    
    exercises.forEach((muscleGroup, exerciseList) {
      for (var exercise in exerciseList) {
        if ((exercise['level'] as List<Experience>).contains(experience)) {
          result.add({...exercise, 'muscleGroup': muscleGroup});
        }
      }
    });
    
    return result;
  }
  
  // Gauti pratimą pagal pavadinimą
  static Map<String, dynamic>? getExerciseByName(String name) {
    for (var muscleGroup in exercises.keys) {
      for (var exercise in exercises[muscleGroup]!) {
        if (exercise['name'] == name) {
          return {...exercise, 'muscleGroup': muscleGroup};
        }
      }
    }
    
    return null;
  }
} 