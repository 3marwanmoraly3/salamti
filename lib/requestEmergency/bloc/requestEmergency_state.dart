part of 'requestEmergency_bloc.dart';

enum RequestEmergencyStatus {
  pickLocation,
  emergencyType,
  emergencyDetails,
  waiting
}

enum QuestionType { string, bool, num, boolMore, boolOr, boolAdd, numAdd }

class EmergencyQuestion {
  final String questionText;
  final QuestionType type;
  final Map<String, dynamic>? additionalData;

  const EmergencyQuestion({
    required this.questionText,
    required this.type,
    this.additionalData,
  });
}

final class RequestEmergencyState extends Equatable {
  const RequestEmergencyState({
    this.longitude = 35.876200,
    this.latitude = 32.023150,
    this.status = RequestEmergencyStatus.pickLocation,
    this.loading = false,
    this.autoCompleteList,
    this.emergencyType,
    this.originalQuestions,
    this.questions,
    this.answers = const {},
    this.espIds,
    this.errorMessage,
  });

  final double? longitude;
  final double? latitude;
  final RequestEmergencyStatus status;
  final bool? loading;
  final List<dynamic>? autoCompleteList;
  final String? emergencyType;
  final List<dynamic>? originalQuestions;
  final List<dynamic>? questions;
  final Map<int, dynamic> answers;
  final List<String>? espIds;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        status,
        loading,
        autoCompleteList,
        emergencyType,
        originalQuestions,
        questions,
        answers,
        espIds,
        errorMessage,
      ];

  RequestEmergencyState copyWith({
    double? longitude,
    double? latitude,
    RequestEmergencyStatus? status,
    bool? loading,
    List<dynamic>? autoCompleteList,
    String? emergencyType,
    List<dynamic>? originalQuestions,
    List<dynamic>? questions,
    Map<int, dynamic>? answers,
    List<String>? espIds,
    String? errorMessage,
  }) {
    return RequestEmergencyState(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      autoCompleteList: autoCompleteList ?? this.autoCompleteList,
      emergencyType: emergencyType ?? this.emergencyType,
      originalQuestions: originalQuestions ?? this.originalQuestions,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      espIds: espIds ?? this.espIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

Map<String, Map<String, dynamic>> emergencyQuestions = {
  "medical": {
    "initialDispatch": {"ambulance": 1},
    "questions": [
      {
        "boolMore": {
          "question": "Is this emergency for someone else?",
          "subQuestions": [
            {
              "string": [
                "What is the patient's age and gender? (If this emergency is not for you)",
                "Does the patient have any known medical conditions? (If this emergency is not for you)",
                "Is the patient conscious and breathing?"
              ]
            }
          ]
        }
      },
      {
        "string": [
          "What symptoms are you/they experiencing (e.g., chest pain, difficulty breathing, severe bleeding)?",
          "Is your/their condition worsening?"
        ]
      }
    ]
  },
  "carCrash": {
    "initialDispatch": {"police": 1},
    "questions": [
      {
        "num": {"question": "How many vehicles are involved?"}
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "boolOr": {
          "questions": [
            "Are there any trapped individuals?",
            "Is there a risk of fire or explosion?"
          ],
          "dispatch": {"firetruck": 1}
        }
      },
      {
        "boolAdd": {
          "question": "Are any hazardous materials involved?",
          "dispatch": {"hazmatUnit": 1}
        }
      },
    ]
  },
  "fire": {
    "initialDispatch": {"firetruck": 2},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "string": {
          "questions": [
            "What type of fire is it (e.g., building, forest, vehicle)?",
            "What is the specific location of the fire? (e.g., kitchen, garbage container)",
          ]
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "num": {
          "question": "Are there any trapped individuals?",
        }
      },
      {
        "boolAdd": {
          "question":
              "Are hazardous materials involved (e.g., gas, chemicals)?",
          "dispatch": {"hazmatUnit": 1}
        }
      },
    ]
  },
  "pedestrianCollision": {
    "initialDispatch": {"police": 1, "ambulance": 1},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "num": {
          "question": "How many people have been hit?",
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0,
        }
      },
      {
        "boolAdd": {
          "question":
              "Are there any hazards nearby (e.g., ongoing traffic, fuel leakage)?",
          "dispatch": {"police": 1}
        }
      },
      {
        "bool": {
          "question": "Is the vehicle still at the scene, or did it leave?",
        }
      },
    ]
  },
  "armedThreat": {
    "initialDispatch": {"police": 2},
    "questions": [
      {
        "boolAdd": {
          "question": "Is anyone currently being threatened?",
          "dispatch": {"tacticalUnit": 1}
        }
      },
      {
        "string": {
          "questions": [
            "Any other weapons (e.g., bat, knife)?",
          ]
        }
      },
      {
        "num": {
          "question": "How many suspects are there?",
        }
      },
      {
        "bool": {
          "question": "Is anyone currently being threatened?",
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "boolAdd": {
          "question": "Are the suspects on the move?",
          "dispatch": {"police": 1}
        }
      },
    ]
  },
  "naturalDisaster": {
    "initialDispatch": {"police": 1, "firetruck": 1, "ambulance": 1},
    "questions": [
      {
        "string": {
          "questions": [
            "What type of disaster is occurring (e.g., earthquake, flood)?",
            "Is there immediate danger to you or others nearby?",
          ]
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "numAdd": {
          "question": "Are there any trapped individuals?",
          "dispatch": {"firetruck": 1},
          "perPerson": 5,
          "minimumPeople": 0
        }
      },
      {
        "boolAdd": {
          "question": "Are any buildings or infrastructure affected?",
          "dispatch": {"engineeringUnit": 1}
        }
      },
      {
        "boolAdd": {
          "question": "Is there access to safe shelter?",
          "dispatch": {"transportUnit": 1}
        }
      },
    ]
  },
  "suicideAttempt": {
    "initialDispatch": {"police": 1},
    "questions": [
      {
        "boolAdd": {
          "question": "Is the person armed or in immediate danger?",
          "dispatch": {"tacticalUnit": 1}
        }
      },
      {
        "bool": {
          "question": "Can the person communicate or respond to questions?",
        }
      },
      {
        "boolAdd": {
          "question": "Has the person attempted self-harm?",
          "dispatch": {"ambulance": 1}
        }
      },
      {
        "string": {
          "questions": [
            "Does the person have a history of mental health issues or prior attempts?",
          ]
        }
      },
    ]
  },
  "abduction": {
    "initialDispatch": {"police": 2},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "string": {
          "questions": [
            "Can you describe the victim (age, gender, clothing)?",
            "Can you describe the suspect(s) (appearance, clothing)?",
            "How long ago did the abduction occur?",
            "Do you have information about their last known location?",
          ]
        }
      },
      {
        "boolAdd": {
          "question": "Was a vehicle involved in the abduction?",
          "dispatch": {"police": 1}
        }
      },
      {
        "bool": {
          "question": "Is the victim a child or vulnerable person?",
        }
      },
    ]
  },
  "burglary": {
    "initialDispatch": {"police": 1},
    "questions": [
      {
        "boolMore": {
          "question": "Are the suspect(s) still present at the location?",
          "subQuestions": [
            {
              "numAdd": {
                "question": "How many suspects are involved?",
                "dispatch": {"police": 1},
                "perPerson": 3,
                "minimumPeople": 3
              }
            },
            {
              "boolAdd": {
                "question": "Are there any weapons involved?",
                "dispatch": {"tacticalUnit": 1}
              }
            },
          ]
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "string": {
          "questions": [
            "Can you describe the suspect(s) and any vehicle involved?",
          ]
        }
      },
    ]
  },
  "assault": {
    "initialDispatch": {"police": 1},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "boolMore": {
          "question": "Is the suspect(s) still at the scene?",
          "subQuestions": [
            {
              "numAdd": {
                "question": "How many people are involved in the altercation?",
                "dispatch": {"police": 1},
                "perPerson": 3,
                "minimumPeople": 3
              }
            },
            {
              "bool": {
                "question": "Is the assault still ongoing?",
              }
            },
          ]
        }
      },
      {
        "boolAdd": {
          "question": "Are any weapons involved?",
          "dispatch": {"tacticalUnit": 1}
        }
      },
    ]
  },
  "domesticViolence": {
    "initialDispatch": {"police": 1},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "bool": {
          "question": "Is the suspect still present at the location?",
        }
      },
      {
        "boolAdd": {
          "question": "Are any weapons involved?",
          "dispatch": {"tacticalUnit": 1}
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "bool": {
          "question": "Are there children or vulnerable people present?",
        }
      },
      {
        "string": {
          "questions": [
            "Have there been previous incidents of domestic violence?",
          ]
        }
      },
    ]
  },
  "trapped": {
    "initialDispatch": {"firetruck": 1},
    "questions": [
      {
        "bool": {
          "question": "Is this emergency for someone else?",
        }
      },
      {
        "string": {
          "questions": [
            "What is causing the person to be trapped (e.g., collapsed building, elevator)?",
          ]
        }
      },
      {
        "numAdd": {
          "question": "Are there any injured individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1,
          "minimumPeople": 0
        }
      },
      {
        "bool": {
          "question": "Can the trapped person(s) communicate?",
        }
      },
      {
        "boolAdd": {
          "question": "Are there any immediate risks (e.g., fire, flooding)?",
          "dispatch": {"firetruck": 1}
        }
      },
      {
        "numAdd": {
          "question": "How many people are trapped?",
          "dispatch": {"firetruck": 1},
          "perPerson": 5,
          "minimumPeople": 5
        }
      },
    ]
  }
};
