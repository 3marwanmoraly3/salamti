part of 'requestEmergency_bloc.dart';

final class RequestEmergencyState extends Equatable {
  const RequestEmergencyState({
    this.longitude = 35.876200,
    this.latitude = 32.023150,
    this.status = RequestEmergencyStatus.pickLocation,
    this.loading = false,
    this.autoCompleteList,
    this.emergencyType,
    this.questions,
    this.answers,
    this.errorMessage,
  });

  final double? longitude;
  final double? latitude;
  final RequestEmergencyStatus status;
  final bool? loading;
  final List<dynamic>? autoCompleteList;
  final String? emergencyType;
  final List<String>? questions;
  final List<String>? answers;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        status,
        loading,
        autoCompleteList,
        emergencyType,
        questions,
        answers,
        errorMessage,
      ];

  RequestEmergencyState copyWith({
    double? longitude,
    double? latitude,
    RequestEmergencyStatus? status,
    bool? loading,
    List<dynamic>? autoCompleteList,
    String? emergencyType,
    List<String>? questions,
    List<String>? answers,
    String? errorMessage,
  }) {
    return RequestEmergencyState(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      autoCompleteList: autoCompleteList ?? this.autoCompleteList,
      emergencyType: emergencyType ?? this.emergencyType,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum RequestEmergencyStatus {
  pickLocation,
  emergencyType,
  emergencyDetails,
  waiting
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
          "Is your/their patient’s condition worsening?"
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
          "question": "Are there any injuries individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1
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
          "dispatch": {"hazmat": 1}
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
          "question": "Are there any injuries individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1
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
          "dispatch": {"hazmat": 1}
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
          "question": "Are there any injuries individuals?",
          "dispatch": {"ambulance": 1}
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
          "question": "Are there any injuries individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1
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
          "question": "Are there any injuries individuals?",
          "dispatch": {"ambulance": 1},
          "perPerson": 1
        }
      },
      {
        "numAdd": {
          "question": "Are there any trapped individuals?",
          "dispatch": {"firetruck": 1},
          "perPerson": 5
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
    "initialDispatch": {},
    "questions": [
      "Is this emergency for someone else?",
      "Can you describe the victim and suspect?",
      "How long ago did the abduction occur?",
      "Was a vehicle involved? If so, provide details.",
      "Is the victim a child, adult, or vulnerable person?",
      "Do you have any information about their last known location?"
    ]
  },
  "burglary": {
    "initialDispatch": {},
    "questions": [
      "Is this emergency for someone else?",
      "Is the suspect still present at the location?",
      "Are there any weapons involved?",
      "Are there any injuries?",
      "Can you describe the suspect(s) and any vehicle involved?",
      "Has any property been taken?"
    ]
  },
  "assault": {
    "initialDispatch": {},
    "questions": [
      "Is this emergency for someone else?",
      "Are there any injuries? If so, what kind?",
      "Is the suspect still nearby?",
      "Was a weapon involved? If so, what type?",
      "How many people are involved in the altercation?",
      "Has the assault ceased, or is it ongoing?"
    ]
  },
  "domesticViolence": {
    "initialDispatch": {},
    "questions": [
      "Is this emergency for someone else?",
      "Is the suspect still on the scene?",
      "Are there any weapons involved?",
      "Are there any injuries, and is medical assistance needed?",
      "Have there been previous incidents of domestic violence?",
      "Are there children or other vulnerable people present?"
    ]
  },
  "trapped": {
    "initialDispatch": {},
    "questions": [
      "Is this emergency for someone else?",
      "What is causing the person to be trapped (e.g., collapsed building, elevator)?",
      "Are you/they injured, or do you/they require medical assistance?",
      "Can they communicate with you?",
      "Are there any immediate risks to your/their safety (e.g., fire, flooding)?",
      "Is there anyone else with you/them?"
    ]
  }
};
